#!/usr/bin/env python3
"""ES2M 範圍式唯讀盤點器；只建立候選與證據，不直接覆蓋 Runtime。"""
from __future__ import annotations
import datetime as dt
import hashlib
import json
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM_URL = "https://github.com/wolfer168/es2-webmud.git"
UPSTREAM_BRANCH = "main"
INITIAL_BASE = "6574724aeac69c3f353fad5b2da90ccfab3714b1"
MIRROR_ROOT = ROOT / "es2m_source_mirror"
IMPORT_ROOT = ROOT / "es2m_import_candidate"
AUDIT_ROOT = ROOT / "docs" / "status"

def run(*args: str, cwd: Path | None = None) -> str:
    """執行命令並保留失敗時的 stdout/stderr。"""
    result = subprocess.run(list(args), cwd=cwd, check=False, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode:
        raise RuntimeError(
            f"命令失敗 exit={result.returncode}: {' '.join(args)}\n"
            f"--- stdout ---\n{result.stdout}\n--- stderr ---\n{result.stderr}")
    return result.stdout.strip()

def file_hash(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()

def tracked_files(repo: Path) -> list[str]:
    raw = subprocess.run(["git", "ls-files", "-z"], cwd=repo, check=True,
                         stdout=subprocess.PIPE).stdout
    return sorted(p.decode("utf-8", "surrogateescape")
                  for p in raw.split(b"\0") if p)

def copy_files(repo: Path, paths: list[str], destination: Path) -> list[dict]:
    """僅複製 Git 已追蹤檔案，避免把 .git 或暫存檔放進來源鏡像。"""
    destination.mkdir(parents=True, exist_ok=True)
    entries = []
    for rel in paths:
        source = (repo / rel).resolve()
        source.relative_to(repo.resolve())
        if not source.is_file():
            continue
        target = destination / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        entries.append({"path": rel, "size": target.stat().st_size,
                        "sha256": file_hash(target)})
    return entries

def replace_directory(staging: Path, destination: Path) -> None:
    """完整建置暫存目錄後才切換，避免發布半成品。"""
    backup = destination.with_name(destination.name + ".previous-tmp")
    if backup.exists():
        shutil.rmtree(backup)
    if destination.exists():
        destination.rename(backup)
    try:
        staging.rename(destination)
    except Exception:
        if backup.exists() and not destination.exists():
            backup.rename(destination)
        raise
    if backup.exists():
        shutil.rmtree(backup)

def is_build_artifact(path: str) -> bool:
    """排除建置輸出、快取與二進位建置產物。"""
    lower = path.lower()
    parts = lower.split("/")
    excluded_dirs = {".git", "build", "build-vs2022", "cmake-build-debug", "cmake-build-release", "node_modules", "dist", "out", "__pycache__", ".pytest_cache", ".mypy_cache"}
    if any(part in excluded_dirs for part in parts):
        return True
    return lower.endswith((".pyc", ".pyo", ".obj", ".o", ".a", ".so", ".dll", ".exe", ".pdb"))

def include_scoped_path(path: str) -> bool:
    """只保留遊戲重建所需來源、世界資料及必要文字文件。"""
    if is_build_artifact(path):
        return False
    if path.startswith("source/upstream/mudlib/"):
        return True
    if path.startswith(("catalog/", "data/", "maps/", "world/")):
        return True
    if path.startswith("docs/"):
        return Path(path).suffix.lower() in {".md", ".txt", ".rst", ".html", ".htm", ".json", ".yaml", ".yml"}
    return path in ("README.md", "CLAUDE.md")

def classify(path: str) -> str:
    if path.startswith("source/upstream/mudlib/"):
        return "MUDLIB_RUNTIME_REVIEW"
    if path.startswith(("catalog/", "data/", "maps/", "world/")):
        return "WORLD_DATA_IMPORT_CANDIDATE"
    if path.startswith(("docs/", "README", "CLAUDE.md")):
        return "DOCUMENTATION_IMPORT_CANDIDATE"
    return "SOURCE_EVIDENCE"

def main() -> None:
    stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%d")
    MIRROR_ROOT.mkdir(parents=True, exist_ok=True)
    IMPORT_ROOT.mkdir(parents=True, exist_ok=True)
    AUDIT_ROOT.mkdir(parents=True, exist_ok=True)
    # 暫存目錄放在 Repository 同一檔案系統，確保 rename 原子切換不會跨磁碟失敗。
    with tempfile.TemporaryDirectory(prefix=".es2m-full-import-", dir=ROOT) as tmp:
        temp = Path(tmp)
        upstream = temp / "upstream"
        run("git", "clone", "--no-tags", UPSTREAM_URL, str(upstream))
        run("git", "checkout", "--detach", f"origin/{UPSTREAM_BRANCH}", cwd=upstream)
        head = run("git", "rev-parse", "HEAD", cwd=upstream)
        head_file = MIRROR_ROOT / "UPSTREAM_HEAD.txt"
        previous = head_file.read_text(encoding="utf-8").strip() if head_file.is_file() else INITIAL_BASE
        # 舊版 mudlib-only Manifest 不可視為全倉庫已匯入。
        manifest_path = MIRROR_ROOT / "MANIFEST.json"
        full_manifest = {}
        if manifest_path.is_file():
            try:
                full_manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError):
                full_manifest = {}
        full_mirror_ready = (
            "tracked_scoped_file_count" in full_manifest
            and (MIRROR_ROOT / "repository").is_dir()
            and (IMPORT_ROOT / "repository").is_dir()
        )
        if previous == head and full_mirror_ready:
            print(f"ES2M SCOPED AUDIT NO-OP: source HEAD={head}")
            return
        if len(previous) != 40 or any(c not in "0123456789abcdef" for c in previous.lower()):
            raise RuntimeError(f"ES2M 基準 SHA 格式錯誤：{previous}")
        ancestry = subprocess.run(["git", "merge-base", "--is-ancestor", previous, head],
                                  cwd=upstream, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if ancestry.returncode:
            raise RuntimeError(f"ES2M 更新遭阻擋：基準 {previous} 不是 HEAD {head} 的祖先。")
        all_files = tracked_files(upstream)
        if not all_files:
            raise RuntimeError("ES2M 上游未回傳任何追蹤檔案。")
        files = [p for p in all_files if include_scoped_path(p)]
        excluded_count = len(all_files) - len(files)
        mudlib_paths = [p for p in files if p.startswith("source/upstream/mudlib/")]
        if not mudlib_paths:
            raise RuntimeError("ES2M 上游缺少 source/upstream/mudlib。")
        candidate_paths = list(files)
        repository_stage = temp / "scoped-source-mirror"
        mudlib_stage = temp / "mudlib-mirror"
        candidate_stage = temp / "import-candidates"
        repository_entries = copy_files(upstream, files, repository_stage)
        mudlib_entries = copy_files(upstream, mudlib_paths, mudlib_stage)
        candidate_entries = copy_files(upstream, candidate_paths, candidate_stage)
        replace_directory(repository_stage, MIRROR_ROOT / "repository")
        replace_directory(mudlib_stage, MIRROR_ROOT / "mudlib")
        replace_directory(candidate_stage, IMPORT_ROOT / "repository")
        commits = int(run("git", "rev-list", "--count", f"{previous}..{head}", cwd=upstream))
        raw_changes = run("git", "diff", "--name-status", "-M", previous, head, cwd=upstream)
        changes = []
        for line in raw_changes.splitlines():
            parts = line.split("\t")
            if len(parts) == 2:
                changes.append({"status": parts[0], "path": parts[1]})
            elif len(parts) == 3 and parts[0].startswith(("R", "C")):
                changes.append({"status": parts[0], "old_path": parts[1], "path": parts[2]})
            else:
                raise RuntimeError(f"無法解析上游差異列：{line!r}")
        manifest = {
            "purpose": "ES2M 範圍式唯讀來源鏡像與候選索引；不取代 Annihilator Original ES2。",
            "source_repository": "wolfer168/es2-webmud",
            "source_branch": UPSTREAM_BRANCH,
            "source_commit": head,
            "previous_source_commit": previous,
            "commits_since_previous": commits,
            "tracked_upstream_file_count": len(all_files),
            "tracked_scoped_file_count": len(repository_entries),
            "excluded_upstream_file_count": excluded_count,
            "mudlib_file_count": len(mudlib_entries),
            "import_candidate_file_count": len(candidate_entries),
            "hash_algorithm": "SHA-256",
            "repository_files": repository_entries,
            "mudlib_files": mudlib_entries,
            "import_candidate_files": candidate_entries,
            "changes": changes,
            "policy": [
                "ES2M 是後續重建與補齊的優先參考母版，來源身分標記為 ES2M 衍生版本。",
                "只鏡像 mudlib、catalog、data、maps、world 與必要文字文件；不保存整個上游倉庫。",
                "排除建置輸出、快取、二進位建置產物及大型建置目錄。",
                "本工作流程只產生 artifact，不會自動提交或推送匯入資料。",
                "正式 Runtime 依依賴與 Original/KING 差異逐批整合；不盲目覆蓋。",
                "刪除只記錄，不自動刪除 KING 檔案；PR #13 保持 OPEN / NOT MERGED。"
            ]}
        (MIRROR_ROOT / "MANIFEST.json").write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        head_file.write_text(head + "\n", encoding="utf-8")
        plan = {
            "source_commit": head,
            "generated_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
            "total_source_files": len(repository_entries),
            "candidate_files": [{"path": e["path"], "sha256": e["sha256"],
                                 "category": classify(e["path"])} for e in candidate_entries],
            "runtime_policy": "ES2M 優先母版；完整保存候選並驗證 SHA-256，依差異與測試逐批整合。"
        }
        (IMPORT_ROOT / "IMPORT_PLAN.json").write_text(
            json.dumps(plan, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        (IMPORT_ROOT / "UPSTREAM_HEAD.txt").write_text(head + "\n", encoding="utf-8")
        audit = [
            "# ES2M 全倉庫同步與匯入候選稽核", "",
            f"- UTC 日期：{stamp}", "- 來源：wolfer168/es2-webmud / main",
            f"- 更新前 HEAD：{previous}", f"- 更新後 HEAD：{head}",
            f"- 新增提交數：{commits}", f"- 上游追蹤檔案總數：{len(all_files)}",
            f"- 範圍內保留檔案：{len(repository_entries)}",
            f"- 排除檔案數：{excluded_count}",
            f"- Mudlib 檔案：{len(mudlib_entries)}",
            f"- 匯入候選檔案：{len(candidate_entries)}", f"- 差異路徑數：{len(changes)}",
            "- 完整 SHA-256 清單：es2m_source_mirror/MANIFEST.json",
            "- 候選索引：es2m_import_candidate/IMPORT_PLAN.json", "",
            "## 規則", "- ES2M 是優先參考母版，仍與 Original ES2 分層標記。",
            "- 僅保存 mudlib、catalog、data、maps、world 與必要文字文件。",
            "- 排除建置輸出與快取；此工作流程只產生 artifact，不自動提交。",
            "- 不直接覆蓋正式 Runtime；須保留 Original ES2 與 KING Expansion 差異。",
            "- PR #13 保持 OPEN / NOT MERGED。", ""
        ]
        (AUDIT_ROOT / f"ES2M_FULL_IMPORT_{stamp}.md").write_text("\n".join(audit), encoding="utf-8")
        print(f"ES2M SCOPED AUDIT PASS: head={head} repository={len(repository_entries)} "
              f"mudlib={len(mudlib_entries)} candidates={len(candidate_entries)} changes={len(changes)}")

if __name__ == "__main__":
    main()
