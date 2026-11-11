#!/usr/bin/env python3
"""ES2M 候選資料導入檢查：只驗證清冊，不改動 Original LPC 或遊戲 Runtime。"""
import argparse
import csv
from pathlib import Path

FIELDS = (
    "category", "es2m_source_path", "es2m_source_commit", "target_path",
    "target_source_commit", "evidence_class", "compatibility",
    "missing_refs", "manual_review", "decision", "targeted_test", "runtime_marker",
)
CATEGORIES = {"World/Map", "NPC", "Weapon/Equipment", "Skill"}
DECISIONS = {"IMPORT", "REFERENCE_ONLY", "BLOCKED", "ALREADY_PRESENT"}


def validate(path):
    errors = []
    with path.open(encoding="utf-8-sig", newline="") as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames is None or tuple(reader.fieldnames) != FIELDS:
            return ["CSV 欄位必須完全符合 ES2M_CONTENT_IMPORT_GATE_20261001.md"]
        for number, row in enumerate(reader, 2):
            prefix = f"line {number}"
            if row["category"] not in CATEGORIES:
                errors.append(f"{prefix}: unknown category")
            if row["decision"] not in DECISIONS:
                errors.append(f"{prefix}: unknown decision")
            if row["manual_review"].lower() not in {"true", "false"}:
                errors.append(f"{prefix}: manual_review must be true/false")
            if row["decision"] == "IMPORT":
                required = ("es2m_source_path", "es2m_source_commit", "target_path",
                            "target_source_commit", "evidence_class", "compatibility",
                            "targeted_test")
                if any(not row[field].strip() for field in required):
                    errors.append(f"{prefix}: IMPORT requires source, target, evidence and test")
                if row["manual_review"].lower() != "false":
                    errors.append(f"{prefix}: manual_review items cannot auto-import")
                if row["missing_refs"].strip():
                    errors.append(f"{prefix}: IMPORT cannot have unresolved references")
                if row["compatibility"].strip().lower() not in {"compatible", "same-version"}:
                    errors.append(f"{prefix}: IMPORT requires verified compatibility")
            if row["runtime_marker"].strip() and not row["targeted_test"].strip():
                errors.append(f"{prefix}: runtime marker requires targeted test reference")
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("inventory", type=Path, help="ES2M candidate inventory CSV")
    args = parser.parse_args()
    issues = validate(args.inventory)
    for issue in issues:
        print("FAIL:", issue)
    if issues:
        raise SystemExit(1)
    print("ES2M_INVENTORY_STATIC_PASS (inventory only; NOT runtime PASS)")


if __name__ == "__main__":
    main()
