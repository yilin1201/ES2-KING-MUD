#!/usr/bin/env python3
"""Three-way merge ES2M updates into generated KING Runtime without clobbering KING edits.

使用固定 Original ES2 作為 merge base；只有無衝突的差異才寫入 Runtime。衝突保留 KING 版本並輸出 HOLD 清冊。"""
from __future__ import annotations
import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

EXPECTED_COMMIT = "71693beb79ced81d51719ea1ccf7c02c641ca9b0"
TIMESTAMP_BACKUP = re.compile(r"\.\d{10,}$")

def git_blob_sha_bytes(data: bytes) -> str:
    """計算 Git blob SHA-1，與固定 manifest 的 40 位 blob ID 比對。"""
    return hashlib.sha1(b"blob " + str(len(data)).encode("ascii") + b"\0" + data).hexdigest()

def git_blob_sha(path: Path) -> str:
    return git_blob_sha_bytes(path.read_bytes())

def excluded(relative: str) -> str | None:
    parts = Path(relative).parts
    if parts and parts[0] in {"data", "log"}:
        return "runtime_state_or_compiled_data"
    if relative.endswith(".o"):
        return "compiled_object"
    if TIMESTAMP_BACKUP.search(relative):
        return "timestamped_backup"
    return None

def safe_file(root: Path, relative: str) -> Path:
    rel = Path(relative)
    if not relative or rel.is_absolute() or ".." in rel.parts:
        raise SystemExit(f"ES2M_THREE_WAY_FAIL: unsafe manifest path {relative!r}")
    path = (root / rel).resolve()
    if not path.is_relative_to(root.resolve()):
        raise SystemExit(f"ES2M_THREE_WAY_FAIL: path escaped root: {relative}")
    return path

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--original-root", type=Path, required=True)
    parser.add_argument("--runtime", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    source_root = args.source_root.resolve(); original_root = args.original_root.resolve(); runtime = args.runtime.resolve()
    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    if manifest.get("source_commit") != EXPECTED_COMMIT:
        raise SystemExit(f"ES2M_THREE_WAY_FAIL: unexpected source commit {manifest.get('source_commit')}")
    report = {
        "status": "THREE_WAY_MERGE_WITH_CONFLICTS_HELD_NOT_FULL_MIGRATION_OR_GAMEPLAY_PASS",
        "source_commit": EXPECTED_COMMIT, "eligible_files": 0, "source_replaced": [],
        "already_source": [], "merged": [], "preserved_conflicts": [],
        "added_missing_runtime": [], "excluded": [],
    }
    seen = set()
    for entry in manifest.get("files", []):
        if entry.get("original_status") != "CHANGED_FROM_PINNED_ORIGINAL":
            continue
        relative = entry.get("path", "")
        if relative in seen:
            raise SystemExit(f"ES2M_THREE_WAY_FAIL: duplicate manifest path {relative}")
        seen.add(relative)
        why = excluded(relative)
        if why:
            report["excluded"].append({"path": relative, "reason": why})
            continue
        source = safe_file(source_root, relative)
        original = safe_file(original_root, relative)
        target = safe_file(runtime, relative)
        if not source.is_file() or not original.is_file():
            raise SystemExit(f"ES2M_THREE_WAY_FAIL: source/original file missing: {relative}")
        source_sha = git_blob_sha(source)
        original_sha = git_blob_sha(original)
        if source_sha != entry.get("sha"):
            raise SystemExit(f"ES2M_THREE_WAY_FAIL: ES2M source blob mismatch: {relative}")
        if original_sha != entry.get("original_sha"):
            raise SystemExit(f"ES2M_THREE_WAY_FAIL: Original ES2 baseline blob mismatch: {relative}")
        report["eligible_files"] += 1
        if not target.exists():
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(source.read_bytes())
            report["added_missing_runtime"].append(relative)
            continue
        if not target.is_file():
            report["preserved_conflicts"].append({"path": relative, "reason": "runtime_target_not_regular_file"})
            continue
        target_sha = git_blob_sha(target)
        if target_sha == source_sha:
            report["already_source"].append(relative)
            continue
        if target_sha == original_sha:
            target.write_bytes(source.read_bytes())
            report["source_replaced"].append(relative)
            continue
        proc = subprocess.run([
            "git", "merge-file", "-p",
            "-L", "KING Runtime", "-L", "Original ES2", "-L", "ES2M 71693beb",
            str(target), str(original), str(source),
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
        if proc.returncode == 0:
            target.write_bytes(proc.stdout)
            report["merged"].append(relative)
        elif proc.returncode == 1:
            report["preserved_conflicts"].append({
                "path": relative, "reason": "three_way_conflict_preserved_KING",
                "source_git_blob": source_sha, "original_git_blob": original_sha,
                "runtime_git_blob": target_sha,
            })
        else:
            raise SystemExit(f"ES2M_THREE_WAY_FAIL: git merge-file error for {relative}: {proc.stderr.decode('utf-8', errors='replace')}")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    summary = {key: (len(value) if isinstance(value, list) else value) for key, value in report.items() if key not in {"status", "source_commit"}}
    print("ES2M_LATEST_THREE_WAY_MERGE", json.dumps(summary, ensure_ascii=False))
    for conflict in report["preserved_conflicts"]:
        print("ES2M_THREE_WAY_HOLD", conflict["path"], conflict.get("reason", "conflict"))
    print("ES2M_LATEST_THREE_WAY_REPORT", args.output)

if __name__ == "__main__":
    main()
