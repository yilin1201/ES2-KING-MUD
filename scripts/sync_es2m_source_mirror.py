#!/usr/bin/env python3
"""ES2M 上游同步器：封存差異並更新完整唯讀鏡像，不直接改寫遊戲 Runtime。"""
# 診斷版：Git 子程序失敗時輸出 stderr，並由 Workflow 上傳原始日誌。

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
BRANCH = "main"
HEAD_FILE = ROOT / "es2m_source_mirror" / "UPSTREAM_HEAD.txt"
MIRROR_SOURCE = ROOT / "es2m_source_mirror" / "mudlib"
AUDIT_DIR = ROOT / "docs" / "status"
ARCHIVE_ROOT = ROOT / "source" / "es2m_updates"
# 首次同步的已核對基準；後續以 HEAD_FILE 為準，不重複匯入。
INITIAL_BASE = "6574724aeac69c3f353fad5b2da90ccfab3714b1"


def run(*args: str, cwd: Path | None = None) -> str:
    """執行 Git 指令；失敗時保留 stdout/stderr，讓 Actions 可追溯真正根因。"""
    result = subprocess.run(
        list(args), cwd=cwd, check=False, text=True, stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        command = " ".join(args)
        details = (
            f"ES2M SYNC COMMAND FAIL：exit={result.returncode} command={command}\n"
            f"--- stdout ---\n{result.stdout}\n"
            f"--- stderr ---\n{result.stderr}"
        )
        print(details, flush=True)
        raise RuntimeError(details)
    return result.stdout.strip()


def safe_source_path(repo: Path, rel: str) -> Path:
    """限制封存來源路徑在上游倉庫內，避免異常路徑寫出倉庫。"""
    candidate = (repo / rel).resolve()
    candidate.relative_to(repo.resolve())
    return candidate


def parse_changes(raw: str) -> list[tuple[str, str, str | None]]:
    """解析新增、修改、刪除與重新命名；保留舊路徑作為證據。"""
    changes: list[tuple[str, str, str | None]] = []
    for line in raw.splitlines():
        fields = line.split("\t")
        if len(fields) == 2:
            changes.append((fields[0], fields[1], None))
        elif len(fields) == 3 and fields[0].startswith(("R", "C")):
            changes.append((fields[0], fields[2], fields[1]))
        else:
            raise RuntimeError(f"無法解析上游差異列：{line!r}")
    return changes


def main() -> None:
    HEAD_FILE.parent.mkdir(parents=True, exist_ok=True)
    previous = HEAD_FILE.read_text(encoding="utf-8").strip() if HEAD_FILE.is_file() else INITIAL_BASE
    if len(previous) != 40 or any(ch not in "0123456789abcdef" for ch in previous.lower()):
        raise SystemExit("ES2M SYNC FAIL：上游基準 SHA 格式不正確。")

    with tempfile.TemporaryDirectory(prefix="es2m-source-sync-") as tmp:
        upstream = Path(tmp) / "es2-webmud"
        run("git", "clone", "--no-tags", UPSTREAM_URL, str(upstream))
        run("git", "checkout", "--detach", f"origin/{BRANCH}", cwd=upstream)
        latest = run("git", "rev-parse", "HEAD", cwd=upstream)
        if latest == previous:
            print(f"ES2M SYNC NO-OP：上游未更新，HEAD={latest}")
            return

        # 只接受由已知基準向前的歷史；若上游改寫歷史，停止而非猜測。
        ancestry = subprocess.run(
            ["git", "merge-base", "--is-ancestor", previous, latest],
            cwd=upstream, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        if ancestry.returncode != 0:
            raise SystemExit(
                f"ES2M SYNC BLOCKED：基準 {previous} 不是最新 HEAD {latest} 的祖先；"
                "不自動覆蓋，需先人工核對上游歷史。"
            )

        changes = parse_changes(run(
            "git", "diff", "--name-status", "-M", previous, latest, cwd=upstream
        ))
        if not changes:
            raise SystemExit("ES2M SYNC FAIL：HEAD 不同但差異清單為空，停止更新。")

        stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%d")
        archive = ARCHIVE_ROOT / f"{stamp}_{latest[:7]}"
        # 失敗重跑時可能留下未完成的同名封存目錄；只有缺少 MANIFEST 的暫存目錄才允許清理。
        # 已有 MANIFEST 的封存視為完成證據，不自動覆蓋。
        if archive.exists():
            if (archive / "MANIFEST.md").is_file():
                raise SystemExit(f"ES2M SYNC BLOCKED：完整封存已存在：{archive.relative_to(ROOT)}")
            print(f"ES2M SYNC RECOVERY：清理未完成封存 {archive.relative_to(ROOT)}")
            shutil.rmtree(archive)
        archive_stage = archive.with_name(archive.name + ".sync-tmp")
        if archive_stage.exists():
            shutil.rmtree(archive_stage)
        archive_stage.mkdir(parents=True)

        print(f"ES2M SYNC STAGE：base={previous} latest={latest} paths={len(changes)}")
        archived = 0
        for status, rel, old_rel in changes:
            # 刪除檔不從 KING 刪除；只記錄刪除狀態，其餘保存上游最新原始檔。
            source = safe_source_path(upstream, rel)
            if status != "D" and source.is_file():
                destination = archive_stage / rel
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, destination)
                archived += 1
            elif status != "D":
                raise SystemExit(f"ES2M SYNC FAIL：差異列標示 {status}，但來源檔不存在：{rel}")

        # 只替換專用的上游證據鏡像；不碰 es2m_snapshot 或遊戲 Runtime。
        source_mudlib = upstream / "source" / "upstream" / "mudlib"
        if not source_mudlib.is_dir():
            raise SystemExit("ES2M SYNC FAIL：上游缺少 source/upstream/mudlib。")
        MIRROR_SOURCE.parent.mkdir(parents=True, exist_ok=True)
        temp_mirror = MIRROR_SOURCE.with_name("mudlib.sync-tmp")
        if temp_mirror.exists():
            shutil.rmtree(temp_mirror)
        shutil.copytree(source_mudlib, temp_mirror)
        if MIRROR_SOURCE.exists():
            shutil.rmtree(MIRROR_SOURCE)
        temp_mirror.rename(MIRROR_SOURCE)
        mudlib_count = sum(1 for path in MIRROR_SOURCE.rglob("*") if path.is_file())
        mudlib_files = sorted(path for path in MIRROR_SOURCE.rglob("*") if path.is_file())
        mirror_entries = []
        for path in mudlib_files:
            digest = hashlib.sha256(path.read_bytes()).hexdigest()
            mirror_entries.append({
                "path": path.relative_to(MIRROR_SOURCE).as_posix(),
                "size": path.stat().st_size,
                "sha256": digest,
            })

        commit_count = run("git", "rev-list", "--count", f"{previous}..{latest}", cwd=upstream)
        manifest_lines = [
            "# ES2M 上游更新封存清單", "",
            "- 來源：wolfer168/es2-webmud",
            f"- 分支：{BRANCH}",
            f"- 更新前 HEAD：{previous}",
            f"- 更新後 HEAD：{latest}",
            f"- 上游新增提交數：{commit_count}",
            f"- 差異路徑數：{len(changes)}",
            f"- 本次實際封存檔案數：{archived}",
            f"- 完整 mudlib 鏡像檔案數：{mudlib_count}",
            "- 分類：[Archived]／ES2M 衍生版本來源證據，不直接等同 Annihilator Original ES2。",
            "- Runtime：只更新來源鏡像與差異封存；不自動覆蓋 Original Runtime、KING Expansion 或凍結武學。",
            "", "## 差異路徑", "",
            "| 狀態 | 新路徑 | 舊路徑（重新命名時） |",
            "|---|---|---|",
        ]
        for status, rel, old_rel in changes:
            manifest_lines.append(f"| {status} | {rel} | {old_rel or ''} |")
        (archive_stage / "MANIFEST.md").write_text(
            "\n".join(manifest_lines) + "\n", encoding="utf-8"
        )
        # 只有封存清單完成後才公開正式目錄，避免半成品被誤認為已同步。
        archive_stage.rename(archive)
        print(f"ES2M SYNC STAGE：archive ready files={archived}")

        mirror_manifest = {
            "purpose": "ES2M 原始 Mudlib 完整唯讀鏡像；不得直接當成 KING runtime overlay。",
            "source_repository": "wolfer168/es2-webmud",
            "source_branch": BRANCH,
            "source_commit": latest,
            "previous_source_commit": previous,
            "source_path": "source/upstream/mudlib/",
            "mirror_path": "es2m_source_mirror/mudlib/",
            "file_count": len(mirror_entries),
            "hash_algorithm": "SHA-256",
            "files": mirror_entries,
            "policy": [
                "原始來源鏡像與 es2m_snapshot 工作快照分開保存。",
                "先逐檔比較、分類與驗證，再選擇性採用到 KING runtime。",
                "不得以全目錄覆蓋方式取代 KING 專屬修改。",
            ],
        }
        (MIRROR_SOURCE.parent / "MANIFEST.json").write_text(
            json.dumps(mirror_manifest, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

        HEAD_FILE.write_text(latest + "\n", encoding="utf-8")
        audit = AUDIT_DIR / f"ES2M_UPDATE_{stamp}_AUDIT.md"
        audit.write_text("\n".join([
            "# ES2M → ES2-KING 來源同步稽核", "",
            f"- 同步日期（UTC）：{stamp}",
            f"- ES2M 主來源：wolfer168/es2-webmud，分支 {BRANCH}",
            f"- 前次基準：{previous}",
            f"- 最新來源 HEAD：{latest}",
            f"- 上游新增提交：{commit_count}",
            f"- 差異路徑：{len(changes)}",
            f"- 原始檔封存：{archived}",
            f"- 完整 mudlib 鏡像檔案：{mudlib_count}",
            f"- 差異封存：{archive.relative_to(ROOT).as_posix()}/MANIFEST.md",
            f"- 最新完整 mudlib 鏡像：{MIRROR_SOURCE.relative_to(ROOT).as_posix()}/",
            "", "## 處理界線", "",
            "- 上游原始檔以原樣保存；不把 ES2M 衍生版本標成 Annihilator Original ES2。",
            "- 完整 mudlib 只同步到 es2m_source_mirror/mudlib/ 證據鏡像。",
            "- 新增、修改、刪除與重新命名路徑均記入 Manifest；刪除檔只記錄差異，不從 KING Runtime 刪檔。",
            "- 新地圖、NPC、技能或共用核心檔尚未自動套用至遊戲 Runtime；需逐項比對 Original、KING Expansion、依賴與測試後再移植。",
            "- PR #13 必須保持 OPEN / NOT MERGED。", "",
        ]), encoding="utf-8")
        print(
            "ES2M SYNC PASS："
            f"old={previous} new={latest} commits={commit_count} "
            f"paths={len(changes)} archived={archived} mudlib_files={mudlib_count}"
        )


if __name__ == "__main__":
    main()
