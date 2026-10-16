#!/usr/bin/env python3
"""ES2M 物件保守導入：只補缺檔；同名異版一律保留 Runtime 並輸出衝突。"""
import argparse
import json
import shutil
from pathlib import Path
from audit_es2m_equipment_import import candidates, digest

# 只有明確繼承物件基類、且非 NPC／場景腳本的檔案才可自動補入。
BASES = ("inherit ITEM", "inherit WEAPON", "inherit ARMOR", "inherit EQUIP")


def stage(snapshot, runtime):
    if not snapshot.is_dir() or not runtime.is_dir():
        raise FileNotFoundError("ES2M_EQUIPMENT_IMPORT_ROOT_MISSING")
    result = {"staged": [], "identical": [], "conflicts_review": [],
              "dependency_review": [], "status": "FILE_STAGE_ONLY_NOT_GAMEPLAY_PASS"}
    for rel in sorted(candidates(snapshot)):
        source = snapshot / rel
        target = runtime / rel
        if target.exists():
            key = "identical" if digest(source) == digest(target) else "conflicts_review"
            result[key].append(rel)
            continue
        text = source.read_text(encoding="utf-8", errors="replace")
        # 不臆測依賴：相對 inherit、自訂物件基類與未知類型一律待審。
        inherits = [line.strip() for line in text.splitlines()
                    if line.strip().startswith("inherit ")]
        if len(inherits) != 1 or not any(inherits[0].startswith(base + ";") for base in BASES):
            result["dependency_review"].append(rel)
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        result["staged"].append(rel)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--snapshot", type=Path, required=True)
    parser.add_argument("--runtime", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    report = stage(args.snapshot, args.runtime)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("ES2M_EQUIPMENT_IMPORT", json.dumps({k: len(v) for k, v in report.items() if isinstance(v, list)}, ensure_ascii=False))


if __name__ == "__main__":
    main()
