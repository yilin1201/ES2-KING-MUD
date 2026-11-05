#!/usr/bin/env python3
"""ES2M/KING immutable Git Trees comparison; only produces evidence, never imports code.

用法：python3 scripts/audit_es2m_tree_delta.py es2m-tree.json king-tree.json > delta.csv
輸入為 GitHub Git Trees API recursive=1 原始 JSON；若 truncated=true 則拒絕輸出。
"""
import csv
import json
import sys

SOURCE_PREFIX = "source/upstream/mudlib/"
TARGET_PREFIX = "es2m_snapshot/mudlib/"


def load(path):
    with open(path, encoding="utf-8") as handle:
        data = json.load(handle)
    if data.get("truncated") is not False or not isinstance(data.get("tree"), list):
        raise ValueError(f"{path}: incomplete or invalid recursive Git tree")
    return data


def category(path):
    # 地圖→NPC→武功→裝備→其他；只決定審核順序，不自動准許移植。
    if path.startswith("d/") and "/npc/" not in path and "/obj/" not in path:
        return (1, "World/Map")
    if "/npc/" in path:
        return (2, "NPC")
    if path.startswith("daemon/skill/") or "/skill/" in path:
        return (3, "Skill")
    if path.startswith(("custom/armor/", "custom/weapon/", "obj/")) or "/obj/" in path:
        return (4, "Equipment/Item")
    return (5, "Other")


def compare(source, target):
    upstream = {
        entry["path"][len(SOURCE_PREFIX):]: entry["sha"]
        for entry in source["tree"]
        if entry.get("type") == "blob" and entry.get("path", "").startswith(SOURCE_PREFIX)
    }
    existing = {
        entry["path"][len(TARGET_PREFIX):]: entry["sha"]
        for entry in target["tree"]
        if entry.get("type") == "blob" and entry.get("path", "").startswith(TARGET_PREFIX)
    }
    rows = []
    for path, sha in upstream.items():
        status = ("MISSING" if path not in existing else
                  "ALREADY_PRESENT" if sha == existing[path] else "CONTENT_DIFF")
        priority, group = category(path)
        rows.append((priority, group, path, sha, existing.get(path, ""), status,
                     "MANUAL_REVIEW" if status != "ALREADY_PRESENT" else "SKIP"))
    return sorted(rows, key=lambda row: (row[0], row[2]))


def main():
    if len(sys.argv) != 3:
        raise SystemExit("usage: audit_es2m_tree_delta.py es2m-tree.json king-tree.json")
    rows = compare(load(sys.argv[1]), load(sys.argv[2]))
    writer = csv.writer(sys.stdout)
    writer.writerow(("priority", "category", "relative_path", "es2m_blob_sha",
                     "king_snapshot_blob_sha", "file_status", "import_gate"))
    writer.writerows(rows)
    # 統計寫 stderr，避免污染機器可讀 CSV。
    from collections import Counter
    print(dict(Counter(row[5] for row in rows)), file=sys.stderr)


if __name__ == "__main__":
    main()
