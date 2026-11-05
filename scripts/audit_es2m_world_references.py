#!/usr/bin/env python3
"""ES2M 世界內容關聯審計：解析房間出口、NPC spawn、裝備引用；只產生待核對報告。"""
import argparse
import json
import posixpath
from pathlib import Path


def resolve(source, reference):
    target = reference.get("target")
    if not isinstance(target, str) or not target:
        return None
    if reference.get("relative"):
        return posixpath.normpath(posixpath.join(posixpath.dirname(source), target))
    return posixpath.normpath(target) if target.startswith("/") else None


def inspect(rows):
    by_path = {row["path"]: row for row in rows
               if isinstance(row, dict) and isinstance(row.get("path"), str)}
    findings = []
    for path, row in sorted(by_path.items()):
        typ = row.get("type")
        if typ == "room":
            for direction, link in (row.get("exits") or {}).items():
                if not isinstance(link, dict):
                    continue
                target = resolve(path, link)
                if target is None or target not in by_path:
                    findings.append({"source": path, "relation": "exit:" + direction,
                                     "target": target, "status": "UNRESOLVED_OR_DYNAMIC"})
            for ref in row.get("objects") or []:
                if not isinstance(ref, dict):
                    continue
                target = resolve(path, ref)
                if target is None or target not in by_path:
                    findings.append({"source": path, "relation": "room_object",
                                     "target": target, "status": "UNRESOLVED_OR_DYNAMIC"})
        if typ == "npc":
            for key in ("equipment", "merchandise"):
                for ref in row.get(key) or []:
                    if not isinstance(ref, dict):
                        continue
                    target = resolve(path, ref)
                    if target is None or target not in by_path:
                        findings.append({"source": path, "relation": key,
                                         "target": target, "status": "UNRESOLVED_OR_DYNAMIC"})
    return findings


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("catalog", type=Path)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    rows = json.loads(args.catalog.read_text(encoding="utf-8"))
    if not isinstance(rows, list):
        parser.error("catalog must be a list")
    findings = inspect(rows)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps({"findings": findings,
        "warning": "索引未解析的引用不一定是原始碼缺檔；動態 clone/符號常數需人工查證。"},
        ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"ES2M_WORLD_REFERENCES_REVIEW={len(findings)}; RUNTIME_NOT_TESTED")


if __name__ == "__main__":
    main()
