#!/usr/bin/env python3
"""核對 ES2M catalog manifest 與 all.json，避免誤用未固定來源的資料。"""
import argparse
import collections
import json
from pathlib import Path

EXPECTED_SOURCE = "https://github.com/taedlar/es2_mudlib"


def audit(manifest, rows):
    errors = []
    git = manifest.get("git") or {}
    if manifest.get("source") != EXPECTED_SOURCE:
        errors.append("unexpected upstream source")
    commit = git.get("commit")
    if not isinstance(commit, str) or len(commit) != 40 or any(c not in "0123456789abcdef" for c in commit):
        errors.append("upstream source commit must be a 40-character lowercase SHA")
    if not isinstance(rows, list):
        return errors + ["catalog all.json must be an array"]
    if manifest.get("total_files") != len(rows):
        errors.append("manifest total_files does not match catalog")
    actual = collections.Counter()
    seen = set()
    for i, row in enumerate(rows):
        if not isinstance(row, dict) or not isinstance(row.get("path"), str):
            errors.append(f"invalid catalog row {i}")
            continue
        path = row["path"]
        if path in seen:
            errors.append(f"duplicate path {path}")
        seen.add(path)
        actual[row.get("type", "unknown")] += 1
    if dict(actual) != manifest.get("counts"):
        errors.append("manifest type counts do not match catalog")
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("catalog_dir", type=Path)
    args = parser.parse_args()
    directory = args.catalog_dir
    manifest = json.loads((directory / "manifest.json").read_text(encoding="utf-8"))
    rows = json.loads((directory / "all.json").read_text(encoding="utf-8"))
    issues = audit(manifest, rows)
    if issues:
        for issue in issues:
            print("FAIL:", issue)
        raise SystemExit(1)
    print(f"ES2M_CATALOG_STATIC_PASS source_commit={manifest['git']['commit']} entries={len(rows)}; NOT RUNTIME PASS")


if __name__ == "__main__":
    main()
