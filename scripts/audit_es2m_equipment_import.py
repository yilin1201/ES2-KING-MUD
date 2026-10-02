#!/usr/bin/env python3
"""ES2M 武器／防具／裝備檔案層盤點；只讀，不宣稱 Gameplay PASS。"""
import argparse
import hashlib
import json
from pathlib import Path

# 保守分類：先以 obj 目錄及可確認的物件繼承判定；不把地圖與 NPC 誤算為裝備。
OBJECT_DIRS = ("/obj/", "/object/", "/weapon/", "/armor/", "/armour/")
EQUIPMENT_MARKERS = ("inherit WEAPON", "inherit ARMOR", "inherit EQUIP", "inherit ITEM")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def candidates(root):
    found = {}
    for path in sorted(root.rglob("*.c")):
        rel = path.relative_to(root).as_posix()
        # 目錄命中僅代表裝備／道具候選，不等同可穿戴裝備。
        if any(part in "/" + rel.lower() for part in OBJECT_DIRS):
            found[rel] = "OBJECT_OR_EQUIPMENT_CANDIDATE"
            continue
        # 不掃描 NPC/地圖內的物件建立敘述，以免把引用誤當成裝備定義。
        if rel.startswith(("obj/", "weapon/", "armor/", "armour/")):
            found[rel] = "OBJECT_OR_EQUIPMENT_CANDIDATE"
            continue
        if rel.startswith(("d/", "daemon/")) and "/npc/" not in "/" + rel:
            text = path.read_text(encoding="utf-8", errors="replace")
            if any(marker in text for marker in EQUIPMENT_MARKERS):
                found[rel] = "EQUIPMENT_INHERIT_CANDIDATE"
    return found


def audit(snapshot, original, runtime):
    for root in (snapshot, original, runtime):
        if not root.is_dir():
            raise FileNotFoundError(f"ES2M_EQUIPMENT_ROOT_MISSING: {root}")
    source = candidates(snapshot)
    base = candidates(original)
    live = candidates(runtime)
    report = {"status": "FILE_AUDIT_ONLY_NOT_GAMEPLAY_PASS",
              "source_candidates": len(source),
              "source_only_missing_runtime": [],
              "source_identical_runtime": [],
              "source_conflicts_runtime": [],
              "runtime_only_candidates": sorted(set(live) - set(source))}
    for rel, kind in sorted(source.items()):
        row = {"path": rel, "kind": kind, "in_original": rel in base}
        if rel not in live:
            report["source_only_missing_runtime"].append(row)
        elif digest(snapshot / rel) == digest(runtime / rel):
            report["source_identical_runtime"].append(row)
        else:
            row["source_sha256"] = digest(snapshot / rel)
            row["runtime_sha256"] = digest(runtime / rel)
            row["original_sha256"] = digest(original / rel) if (original / rel).is_file() else None
            row["decision"] = "OWNER_REVIEW_NO_OVERWRITE"
            report["source_conflicts_runtime"].append(row)
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--snapshot", required=True, type=Path)
    parser.add_argument("--original", required=True, type=Path)
    parser.add_argument("--runtime", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    report = audit(args.snapshot, args.original, args.runtime)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("ES2M_EQUIPMENT_FILE_AUDIT", json.dumps({
        "source_candidates": report["source_candidates"],
        "missing": len(report["source_only_missing_runtime"]),
        "identical": len(report["source_identical_runtime"]),
        "conflicts_review": len(report["source_conflicts_runtime"]),
        "report": str(args.output)
    }, ensure_ascii=False))
    # Render 建置日誌直接列出同名衝突路徑，便於逐檔審查；不覆蓋原始資料。
    print("ES2M_EQUIPMENT_CONFLICT_PATHS", json.dumps(\n        [row["path"] for row in report["source_conflicts_runtime"]], ensure_ascii=False))
    # 缺檔或衝突均列清冊供後續有證據的批次導入；此階段不覆蓋 Original。
if __name__ == "__main__":
    main()
