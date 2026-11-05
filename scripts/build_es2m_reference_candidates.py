#!/usr/bin/env python3
"""從 ES2M all.json 產生待人工核對候選清冊；絕不自動批准 IMPORT。"""
import argparse
import csv
import json
from pathlib import Path

from validate_es2m_import_inventory import FIELDS, validate

TYPE_MAP = {"room": "World/Map", "npc": "NPC", "item": "Weapon/Equipment",
            "weapon": "Weapon/Equipment", "armor": "Weapon/Equipment", "skill": "Skill"}
ORDER = {"World/Map": 0, "NPC": 1, "Weapon/Equipment": 2, "Skill": 3}


def build_candidates(rows, source_commit):
    if not source_commit.strip():
        raise ValueError("必須提供 ES2M upstream source commit，不得使用未固定版本")
    candidates = []
    seen = set()
    for row in rows:
        if not isinstance(row, dict):
            continue
        category = TYPE_MAP.get(row.get("type"))
        path = row.get("path")
        if not category or not isinstance(path, str) or not path.startswith("/"):
            continue
        if path in seen:
            raise ValueError(f"ES2M catalog duplicate path: {path}")
        seen.add(path)
        candidate = dict.fromkeys(FIELDS, "")
        candidate.update(category=category, es2m_source_path=path,
                         es2m_source_commit=source_commit,
                         evidence_class="ES2M_CATALOG_REFERENCE",
                         compatibility="unknown",
                         manual_review="true", decision="REFERENCE_ONLY")
        candidates.append(candidate)
    return sorted(candidates, key=lambda x: (ORDER[x["category"]], x["es2m_source_path"]))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("catalog", type=Path, help="ES2M catalog/generated/all.json")
    parser.add_argument("--source-commit", required=True, help="索引所用 upstream LPC commit SHA")
    parser.add_argument("--out", type=Path, required=True, help="輸出 CSV 路徑")
    args = parser.parse_args()
    rows = json.loads(args.catalog.read_text(encoding="utf-8"))
    if not isinstance(rows, list):
        parser.error("all.json root must be an array")
    try:
        candidates = build_candidates(rows, args.source_commit)
    except ValueError as exc:
        parser.error(str(exc))
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(candidates)
    issues = validate(args.out)
    if issues:
        parser.error("; ".join(issues))
    print(f"ES2M_REFERENCE_CANDIDATES={len(candidates)}; IMPORT_APPROVED=0; RUNTIME_NOT_TESTED")


if __name__ == "__main__":
    main()
