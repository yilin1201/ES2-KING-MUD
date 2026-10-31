#!/usr/bin/env python3
"""核對已取得的 ES2M 雪亭鎮世界切片；缺依賴時阻止宣告可導入。"""
import argparse
import json
from pathlib import Path


def inspect_slice(data, available_paths, available_symbols=()):
    errors = []
    rooms = {room["path"]: room for room in data["rooms"]}
    npcs = {npc["path"]: npc for npc in data["npcs"]}
    available = set(available_paths)
    symbols = set(available_symbols)
    for room in rooms.values():
        if room["path"] not in available:
            errors.append(f"MISSING_ROOM {room['path']}")
        if room["inherit"] not in symbols:
            errors.append(f"MISSING_INHERIT {room['inherit']} for {room['path']}")
        for direction, target in room["exits"].items():
            if target not in available:
                errors.append(f"BROKEN_EXIT {room['path']} {direction} -> {target}")
        for target in room["spawns"]:
            if target not in available:
                errors.append(f"MISSING_SPAWN {room['path']} -> {target}")
    for npc in npcs.values():
        if npc["path"] not in available:
            errors.append(f"MISSING_NPC {npc['path']}")
        for symbol in npc["inherits"]:
            if symbol not in symbols:
                errors.append(f"MISSING_INHERIT {symbol} for {npc['path']}")
        for target in npc["merchandise"]:
            if target not in available:
                errors.append(f"MISSING_MERCHANDISE {npc['path']} -> {target}")
        if npc["worn_object"] not in available:
            errors.append(f"MISSING_EQUIPMENT {npc['path']} -> {npc['worn_object']}")
    return sorted(set(errors))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("slice", type=Path)
    parser.add_argument("--available", type=Path, required=True,
                        help="已確認目標版本存在的 LPC canonical path JSON 字串陣列")
    parser.add_argument("--symbols", type=Path,
                        help="已確認目標版本可解析的繼承常數 JSON 字串陣列")
    args = parser.parse_args()
    data = json.loads(args.slice.read_text(encoding="utf-8"))
    available = json.loads(args.available.read_text(encoding="utf-8"))
    symbols = json.loads(args.symbols.read_text(encoding="utf-8")) if args.symbols else []
    issues = inspect_slice(data, available, symbols)
    for issue in issues:
        print("BLOCKED:", issue)
    if issues:
        raise SystemExit(1)
    print("SLICE_DEPENDENCY_STATIC_PASS; REQUIRES_SOURCE_DIFF_AND_RUNTIME_VALIDATION")


if __name__ == "__main__":
    main()
