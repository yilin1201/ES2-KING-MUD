#!/usr/bin/env python3
"""ES2M 技能三方 SHA-256 稽核：來源／固定 Original／生成 Runtime；不自動覆蓋。"""
import argparse
import hashlib
import json
from pathlib import Path

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None

def audit(snapshot, original, runtime):
    root = Path("daemon/skill")
    names = sorted(p.name for p in (snapshot / root).glob("*.c"))
    if not names:
        raise ValueError("ES2M_SKILL_SOURCE_EMPTY")
    records = []
    for name in names:
        rel = root / name
        src, org, dst = (base / rel for base in (snapshot, original, runtime))
        hashes = dict(source=digest(src), original=digest(org), runtime=digest(dst))
        if not hashes["runtime"]:
            status = "MISSING_RUNTIME"
        elif hashes["runtime"] == hashes["source"]:
            status = "ES2M_IDENTICAL"
        elif hashes["original"] and hashes["runtime"] == hashes["original"]:
            status = "ORIGINAL_PRESERVED_ES2M_CONFLICT_REVIEW"
        else:
            status = "RUNTIME_VARIANT_REVIEW"
        records.append(dict(skill=name, status=status, sha256=hashes))
    return dict(status="STATIC_AUDIT_ONLY_NOT_GAMEPLAY_PASS", count=len(records),
                records=records)

def main():
    p = argparse.ArgumentParser()
    for name in ("snapshot", "original", "runtime", "output"):
        p.add_argument("--" + name, required=True, type=Path)
    a = p.parse_args()
    report = audit(a.snapshot, a.original, a.runtime)
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(report, ensure_ascii=False, indent=2)+"\n")
    counts = {status: sum(row["status"] == status for row in report["records"])
              for status in sorted({row["status"] for row in report["records"]})}
    print("ES2M_SKILL_THREE_WAY_AUDIT", json.dumps(counts, ensure_ascii=False))
    if any(row["status"] == "MISSING_RUNTIME" for row in report["records"]):
        raise SystemExit("ES2M_SKILL_RUNTIME_MISSING")
if __name__ == "__main__":
    main()
