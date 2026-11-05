#!/usr/bin/env python3
"""檢查已隨固定 ES2M baseline 提供的雪亭鎮內容，避免重複匯入造成覆蓋。"""
import argparse
from pathlib import Path


REQUIRED = {
    "d/snow/bazar.c": ('inherit BANK;', '"west" : __DIR__"sstreet1"', '__DIR__"npc/yu": 1'),
    "d/snow/sstreet1.c": ('inherit ROOM;', '"east" : __DIR__"bazar"', '"south" : __DIR__"sgate"'),
    "d/snow/npc/yu.c": ('inherit F_VILLAGER;', 'inherit F_VENDOR;', '"/d/snow/npc/obj/blue_jacket": 5'),
    "d/snow/npc/obj/blue_jacket.c": ('inherit F_CLOTH;', 'set_name("藍衣套"', '"armor": 2'),
    "d/snow/sgate.c": ('inherit ROOM;', '"north" : __DIR__"sstreet1"'),
    "d/snow/square_s.c": ('inherit ROOM;', '"south" : __DIR__"sstreet1"'),
    "d/snow/store.c": ('inherit ROOM;', '"east" : __DIR__"sstreet1"', '__DIR__"npc/foreman": 1'),
}


def check(root):
    issues = []
    for relative, needles in REQUIRED.items():
        file = root / relative
        if not file.is_file():
            issues.append(f"MISSING {relative}")
            continue
        data = file.read_text(encoding="utf-8")
        for needle in needles:
            if needle not in data:
                issues.append(f"CHANGED {relative}: {needle}")
    return issues


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("runtime", type=Path, help="已建置的 ES2 Runtime 根目錄")
    args = parser.parse_args()
    issues = check(args.runtime / "mudlib")
    for issue in issues:
        print("ES2M_SNOW_BASELINE_FAIL", issue)
    if issues:
        raise SystemExit(1)
    print("ES2M_SNOW_BASELINE_STATIC_PASS; DRIVER_RUNTIME_NOT_TESTED")


if __name__ == "__main__":
    main()
