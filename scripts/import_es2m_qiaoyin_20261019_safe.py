#!/usr/bin/env python3
"""核對並只補入固定 2026-10-19 ES2M 橋隱區缺檔；兩個跨 pin 修改 NPC 明確 HOLD。"""
from __future__ import annotations

import argparse
import hashlib
import json
import posixpath
import re
import shutil
from pathlib import Path

EXPECTED_SOURCE_COMMIT = "63e932a2e46aa745a741df14e108df76bcd30f84"
SAFE_ZONE = Path("d/qiaoyin")
# 上游 compare 71693beb...63e932a2 明確顯示這兩個同名 NPC 有修改；先保留 Runtime 舊版，待三方審查。
HELD_UPSTREAM_CHANGES = {
    Path("d/qiaoyin/npc/keeper.c"): "modified_between_pins_keep_existing_runtime",
    Path("d/qiaoyin/npc/old_ho.c"): "modified_between_pins_keep_existing_runtime",
}
LITERAL_LOCAL = re.compile(r'__DIR__\s*"([^"]+)"')
LITERAL_ABSOLUTE = re.compile(r'"(/(?:d|custom|obj)/[^"\s]+)"')


class ImportBlocked(RuntimeError):
    """來源、衝突或相依性未通過時停止，不做部分匯入。"""


def git_blob_sha(data: bytes) -> str:
    """計算 Git blob SHA-1，與上游 manifest 的 blob ID 使用相同算法。"""
    header = f"blob {len(data)}\0".encode("ascii")
    return hashlib.sha1(header + data).hexdigest()


def normalize_target(source_rel: Path, raw: str) -> Path | None:
    raw = raw.strip()
    if not raw or raw.endswith("/"):
        return None
    if raw.startswith("/"):
        rel = Path(raw.lstrip("/"))
    else:
        rel = source_rel.parent / raw
    if rel.suffix == "":
        rel = rel.with_suffix(".c")
    normalized = posixpath.normpath(rel.as_posix())
    if normalized in (".", "..") or normalized.startswith("../") or normalized.startswith("/"):
        return None
    return Path(normalized)


def literal_dependencies(rel: Path, code: str) -> set[Path]:
    deps: set[Path] = set()
    for raw in LITERAL_LOCAL.findall(code):
        target = normalize_target(rel, raw)
        if target:
            deps.add(target)
    for raw in LITERAL_ABSOLUTE.findall(code):
        target = normalize_target(rel, raw)
        if target:
            deps.add(target)
    return deps


def stage_import(source_root: Path, runtime: Path, manifest_path: Path, output_path: Path) -> dict:
    source_root = source_root.resolve()
    runtime = runtime.resolve()
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if manifest.get("source_commit") != EXPECTED_SOURCE_COMMIT:
        raise ImportBlocked(
            "ES2M_QIAOYIN_IMPORT_FAIL：manifest source_commit 不符合固定來源 "
            + EXPECTED_SOURCE_COMMIT
        )

    entries = {row["path"]: row for row in manifest.get("files", [])}
    seeds = sorted(
        Path(path) for path, row in entries.items()
        if path.startswith("d/qiaoyin/")
        and path.endswith(".c")
        and row.get("status") == "NEW_TO_EXISTING_ES2M_SNAPSHOT"
        and Path(path) not in HELD_UPSTREAM_CHANGES
    )
    if not seeds:
        raise ImportBlocked("ES2M_QIAOYIN_IMPORT_FAIL：manifest 找不到新增橋隱區房間")

    planned: set[Path] = set(seeds)
    queue = list(seeds)
    identical: list[str] = []
    staged: list[str] = []
    conflicts: list[str] = []
    unresolved: list[dict] = []
    resolved: list[dict] = []
    verified: set[Path] = set()

    def source_file(rel: Path) -> Path:
        candidate = (source_root / rel).resolve()
        if not candidate.is_relative_to(source_root):
            raise ImportBlocked(f"ES2M_QIAOYIN_IMPORT_FAIL：來源路徑越界：{rel}")
        if not candidate.is_file():
            raise ImportBlocked(f"ES2M_QIAOYIN_IMPORT_FAIL：來源缺檔：{rel}")
        row = entries.get(rel.as_posix())
        if row is None:
            raise ImportBlocked(f"ES2M_QIAOYIN_IMPORT_FAIL：manifest 缺少相依檔案：{rel}")
        data = candidate.read_bytes()
        if git_blob_sha(data) != row.get("sha"):
            raise ImportBlocked(f"ES2M_QIAOYIN_IMPORT_FAIL：Git blob SHA 不符：{rel}")
        verified.add(rel)
        return candidate

    held_upstream_changes = []
    for rel, reason in HELD_UPSTREAM_CHANGES.items():
        # 即使不匯入，也核對新來源的實際 blob SHA，保留可追溯證據。
        source_file(rel)
        held_upstream_changes.append({"path": rel.as_posix(), "reason": reason})

    while queue:
        rel = queue.pop(0)
        src = source_file(rel)
        dst = runtime / rel
        if dst.is_file():
            if git_blob_sha(dst.read_bytes()) == entries[rel.as_posix()]["sha"]:
                identical.append(rel.as_posix())
            elif rel in seeds:
                conflicts.append(rel.as_posix())
        else:
            staged.append(rel.as_posix())

        code = src.read_text(encoding="utf-8", errors="strict")
        for dep in sorted(literal_dependencies(rel, code)):
            dep_runtime = runtime / dep
            if dep_runtime.is_file():
                # Existing KING/Original Runtime dependency wins; never replace it with the new upstream copy.
                resolved.append({"source": rel.as_posix(), "target": dep.as_posix(), "location": "existing_runtime_preserved"})
                continue

            dep_source = source_root / dep
            dep_entry = entries.get(dep.as_posix())
            if (
                dep_source.is_file()
                and dep.as_posix().startswith("d/qiaoyin/")
                and dep_entry
                and dep_entry.get("status") == "NEW_TO_EXISTING_ES2M_SNAPSHOT"
                and dep not in HELD_UPSTREAM_CHANGES
            ):
                if dep not in planned:
                    planned.add(dep)
                    queue.append(dep)
                resolved.append({"source": rel.as_posix(), "target": dep.as_posix(), "location": "verified_new_qiaoyin_source"})
            else:
                unresolved.append({
                    "source": rel.as_posix(),
                    "target": dep.as_posix(),
                    "reason": "missing_from_runtime_or_outside_new_qiaoyin_allowlist",
                })

    if conflicts or unresolved:
        details = []
        if conflicts:
            details.append("同名衝突=" + ",".join(sorted(conflicts)))
        if unresolved:
            details.append("未解相依=" + ",".join(
                f'{row["source"]}->{row["target"]}' for row in unresolved
            ))
        raise ImportBlocked("ES2M_QIAOYIN_IMPORT_BLOCKED：" + "；".join(details))

    # 只有全部來源 SHA、衝突與字面相依通過後，才一次性補入缺檔。
    for rel_text in sorted(staged):
        rel = Path(rel_text)
        src = source_file(rel)
        dst = runtime / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)

    report = {
        "status": "FILE_STAGE_ONLY_NOT_GAMEPLAY_PASS",
        "source_commit": EXPECTED_SOURCE_COMMIT,
        "manifest": str(manifest_path),
        "zone": str(SAFE_ZONE),
        "seed_files": len(seeds),
        "verified_source_files": len(verified),
        "staged": sorted(staged),
        "identical": sorted(identical),
        "conflicts_review": sorted(conflicts),
        "held_upstream_changes": held_upstream_changes,
        "resolved_dependencies": resolved,
        "unresolved_dependencies": unresolved,
        "gameplay_runtime_pass": False,
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("ES2M_QIAOYIN_20261019_FILE_STAGE", json.dumps({
        "source_commit": EXPECTED_SOURCE_COMMIT,
        "seed_files": len(seeds),
        "staged": len(staged),
        "identical": len(identical),
        "held_upstream_changes": len(held_upstream_changes),
        "resolved_dependencies": len(resolved),
        "gameplay_runtime_pass": False,
    }, ensure_ascii=False))
    return report


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, required=True, help="固定 2026-10-19 ES2M mudlib")
    parser.add_argument("--runtime", type=Path, required=True, help="生成的 KING Runtime mudlib")
    parser.add_argument("--manifest", type=Path, required=True, help="2026-10-19 source blob manifest")
    parser.add_argument("--output", type=Path, required=True, help="檔案層匯入報告")
    args = parser.parse_args()
    try:
        stage_import(args.source_root, args.runtime, args.manifest, args.output)
    except (ImportBlocked, OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise SystemExit(str(exc)) from exc


if __name__ == "__main__":
    main()
