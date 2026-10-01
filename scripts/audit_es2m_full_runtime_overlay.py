#!/usr/bin/env python3
"""完整 ES2M Runtime 清冊：記錄 KING overlay 覆蓋與新增內容，不把檔案存在誤報成遊戲通過。"""
import argparse
import hashlib
import json
from pathlib import Path


def inventory(root):
    if not root.is_dir():
        raise SystemExit(f"ES2M inventory root missing: {root}")
    return {
        str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
        for p in sorted(root.rglob("*"))
        if p.is_file()
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("original", type=Path, help="未套用 KING overlay 的固定版 ES2M mudlib")
    parser.add_argument("runtime", type=Path, help="已套用 KING overlay 的 mudlib")
    parser.add_argument("output", type=Path, help="輸出 JSON 清冊")
    parser.add_argument("--snapshot", type=Path, help="Repository 內補充 ES2M snapshot mudlib")
    args = parser.parse_args()
    before, after = inventory(args.original), inventory(args.runtime)
    report = {
        "status": "SOURCE_INVENTORY_ONLY_NOT_GAMEPLAY_PASS",
        "original_count": len(before),
        "runtime_count": len(after),
        "preserved": sorted(k for k in before.keys() & after.keys() if before[k] == after[k]),
        "overridden": sorted(k for k in before.keys() & after.keys() if before[k] != after[k]),
        "missing": sorted(before.keys() - after.keys()),
        "added": sorted(after.keys() - before.keys()),
    }
    if args.snapshot is not None:
        supplement = inventory(args.snapshot)
        report["snapshot_count"] = len(supplement)
        report["snapshot_only"] = sorted(supplement.keys() - before.keys())
        report["snapshot_matches_base"] = sorted(
            k for k in supplement.keys() & before.keys() if supplement[k] == before[k]
        )
        report["snapshot_conflicts_base"] = sorted(
            k for k in supplement.keys() & before.keys() if supplement[k] != before[k]
        )
        report["snapshot_missing_in_runtime"] = sorted(supplement.keys() - after.keys())
        report["snapshot_matches_runtime"] = sorted(
            k for k in supplement.keys() & after.keys() if supplement[k] == after[k]
        )
        report["snapshot_conflicts_runtime"] = sorted(
            k for k in supplement.keys() & after.keys() if supplement[k] != after[k]
        )
        # 分類衝突供 Owner 逐類決策；清冊只讀，不修改任何來源。
        def classify(path):
            if path.startswith("d/"):
                if "/npc/" in path:
                    return "npc"
                if "/obj/" in path or "/object/" in path:
                    return "equipment_or_items"
                return "world_maps"
            if path.startswith("daemon/skill/"):
                return "martial_skills"
            if path.startswith("daemon/class/"):
                return "classes"
            if path.startswith("daemon/race/"):
                return "races"
            if path.startswith("custom/"):
                return "custom_content"
            if path.startswith(("adm/", "feature/", "include/", "cmds/")):
                return "shared_engine"
            return "other"

        report["owner_review_queue"] = {}
        for path in report["snapshot_conflicts_runtime"]:
            category = classify(path)
            report["owner_review_queue"].setdefault(category, []).append(path)
        report["owner_review_required"] = bool(report["snapshot_conflicts_runtime"])
        # 同名但內容不同屬待審議衝突，不在未經 Owner 決策時覆蓋。
        print("ES2M_SNAPSHOT_CONFLICT_REVIEW", json.dumps({
            "snapshot": len(supplement),
            "base_conflicts": len(report["snapshot_conflicts_base"]),
            "runtime_conflicts": len(report["snapshot_conflicts_runtime"]),
            "snapshot_missing_in_runtime": len(report["snapshot_missing_in_runtime"]),
            "base_conflict_paths": report["snapshot_conflicts_base"][:20],
        }, ensure_ascii=False))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("ES2M_FULL_RUNTIME_INVENTORY", json.dumps({
        "original": report["original_count"], "runtime": report["runtime_count"],
        "overridden": len(report["overridden"]), "missing": len(report["missing"]),
        "added": len(report["added"]), "report": str(args.output),
    }, ensure_ascii=False))
    if report["missing"]:
        raise SystemExit("ES2M_RUNTIME_MISSING_ORIGINAL_FILES: inspect inventory before release")


if __name__ == "__main__":
    main()
