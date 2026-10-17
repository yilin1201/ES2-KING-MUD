#!/usr/bin/env python3
"""Import missing files from the pinned latest ES2M source without overwriting KING.

本工具只做加法式補檔；既有同名內容保留並列入衝突清冊，不能視為完整移植。"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
from pathlib import Path

EXPECTED_COMMIT = "71693beb79ced81d51719ea1ccf7c02c641ca9b0"
TIMESTAMP_BACKUP = re.compile(r"\.\d{10,}$")

def git_blob_sha(path: Path) -> str:
    """計算 Git blob SHA-1；manifest 的 40 位 sha 是 Git blob ID，不是 SHA-256。"""
    data = path.read_bytes()
    return hashlib.sha1(b"blob " + str(len(data)).encode("ascii") + b"\0" + data).hexdigest()

def excluded(relative: str) -> str | None:
    """不複製執行期狀態、編譯物件或帶時間戳的編輯備份。"""
    parts = Path(relative).parts
    if parts and parts[0] in {"data", "log"}:
        return "runtime_state_or_compiled_data"
    if relative.endswith(".o"):
        return "compiled_object"
    if TIMESTAMP_BACKUP.search(relative):
        return "timestamped_backup"
    return None

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--runtime", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    source_root = args.source_root.resolve()
    runtime = args.runtime.resolve()
    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    if manifest.get("source_commit") != EXPECTED_COMMIT:
        raise SystemExit(f"ES2M_LATEST_IMPORT_FAIL: unexpected source commit {manifest.get('source_commit')}")

    report = {
        "status": "ADDITIVE_IMPORT_ONLY_NOT_FULL_MIGRATION_OR_GAMEPLAY_PASS",
        "source_commit": EXPECTED_COMMIT,
        "source_file_count": len(manifest.get("files", [])),
        "copied": [], "identical": [], "preserved_conflicts": [], "excluded": [],
    }
    seen = set()
    for entry in manifest.get("files", []):
        relative = entry.get("path", "")
        rel = Path(relative)
        if not relative or rel.is_absolute() or ".." in rel.parts or relative in seen:
            raise SystemExit(f"ES2M_LATEST_IMPORT_FAIL: unsafe or duplicate manifest path {relative!r}")
        seen.add(relative)
        why = excluded(relative)
        if why:
            report["excluded"].append({"path": relative, "reason": why})
            continue
        src = (source_root / rel).resolve()
        if not src.is_relative_to(source_root) or not src.is_file():
            raise SystemExit(f"ES2M_LATEST_IMPORT_FAIL: source file missing or escaped root: {relative}")
        actual_source_sha = git_blob_sha(src)
        if actual_source_sha != entry.get("sha"):
            raise SystemExit(f"ES2M_LATEST_IMPORT_FAIL: source SHA mismatch: {relative}")
        dst = runtime / rel
        if not dst.resolve(strict=False).is_relative_to(runtime):
            raise SystemExit(f"ES2M_LATEST_IMPORT_FAIL: runtime path escaped root: {relative}")
        if dst.is_file():
            if git_blob_sha(dst) == actual_source_sha:
                report["identical"].append(relative)
            else:
                report["preserved_conflicts"].append({
                    "path": relative, "source_git_blob_sha": actual_source_sha,
                    "runtime_git_blob_sha": git_blob_sha(dst), "status": "PRESERVED_NOT_OVERWRITTEN_HOLD",
                })
            continue
        if dst.exists():
            report["preserved_conflicts"].append({
                "path": relative, "source_sha256": actual_source_sha,
                "runtime_git_blob_sha": None, "status": "NON_FILE_TARGET_PRESERVED_HOLD",
            })
            continue
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        report["copied"].append(relative)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    summary = {
        "source_files": report["source_file_count"], "copied": len(report["copied"]),
        "identical": len(report["identical"]), "preserved_conflicts": len(report["preserved_conflicts"]),
        "excluded": len(report["excluded"]),
    }
    print("ES2M_LATEST_ADDITIVE_IMPORT", json.dumps(summary, ensure_ascii=False))
    print("ES2M_LATEST_ADDITIVE_IMPORT_REPORT", args.output)

if __name__ == "__main__":
    main()
