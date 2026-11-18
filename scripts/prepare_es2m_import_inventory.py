#!/usr/bin/env python3
"""ES2M 實際 catalog → 安全候選清冊：先驗來源，再產出可比對資料，不改遊戲檔。"""
import argparse
import csv
import json
from pathlib import Path

from audit_es2m_catalog_manifest import audit
from build_es2m_reference_candidates import build_candidates
from validate_es2m_import_inventory import FIELDS, validate


def prepare(catalog_dir, output):
    manifest = json.loads((catalog_dir / "manifest.json").read_text(encoding="utf-8"))
    rows = json.loads((catalog_dir / "all.json").read_text(encoding="utf-8"))
    errors = audit(manifest, rows)
    if errors:
        raise ValueError("ES2M catalog integrity failed: " + "; ".join(errors))
    # 版本只能取自已核對的 manifest，不能讓使用者誤填其他 upstream SHA。
    candidates = build_candidates(rows, manifest["git"]["commit"])
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(candidates)
    errors = validate(output)
    if errors:
        output.unlink(missing_ok=True)
        raise ValueError("ES2M candidate inventory invalid: " + "; ".join(errors))
    return candidates


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("catalog_dir", type=Path)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    try:
        candidates = prepare(args.catalog_dir, args.out)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        parser.error(str(exc))
    counts = {category: sum(c["category"] == category for c in candidates)
              for category in ("World/Map", "NPC", "Weapon/Equipment", "Skill")}
    print("ES2M_CANDIDATES_READY", counts, "IMPORT_APPROVED=0", "RUNTIME_NOT_TESTED")


if __name__ == "__main__":
    main()
