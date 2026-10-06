#!/usr/bin/env python3
"""老松林來源與 Runtime 拓樸閘門；Static PASS 不等於 Gameplay PASS。"""
import argparse
import re
from pathlib import Path

OPPOSITE = {
    "north": "south", "south": "north", "east": "west", "west": "east",
    "northeast": "southwest", "southwest": "northeast",
    "northwest": "southeast", "southeast": "northwest", "up": "down", "down": "up",
}
RECIPROCAL_SKIP = {"reeds", "reeds2", "reeds3", "reeds4", "reeds5", "reeds_exit", "wood3", "ledge"}


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def exits(room: Path) -> dict[str, str]:
    match = re.search(r'set\("exits", \(\[(.*?)\]\)\);', read(room), re.S)
    if not match:
        return {}
    return dict(re.findall(r'"([a-z]+)"\s*:\s*(?:__DIR__)?"([^"]+)"', match.group(1)))


def validate_tree(mudlib: Path, require_snow_link: bool) -> None:
    area = mudlib / "d/oldpine"
    rooms = sorted(area.glob("*.c"))
    npcs = sorted((area / "npc").glob("*.c"))
    objects = sorted((area / "obj").glob("*.c"))
    assert len(rooms) == 50, f"ES2M_OLDPINE_ROOM_COUNT: {len(rooms)}"
    assert len(npcs) == 17, f"ES2M_OLDPINE_NPC_COUNT: {len(npcs)}"
    assert len(objects) == 5, f"ES2M_OLDPINE_OBJECT_COUNT: {len(objects)}"

    room_names = {p.stem for p in rooms}
    for room in rooms:
        code = read(room)
        assert 'set("map/area", ' in code, f"ES2M_OLDPINE_AREA_MISSING: {room.name}"
        for direction, target in exits(room).items():
            if target.startswith("/"):
                assert target == "/d/snow/sgate", f"ES2M_OLDPINE_EXTERNAL_EXIT: {room.name}:{direction}:{target}"
                continue
            assert target in room_names, f"ES2M_OLDPINE_BROKEN_EXIT: {room.name}:{direction}:{target}"
            if room.stem not in RECIPROCAL_SKIP and direction in OPPOSITE:
                back = exits(area / f"{target}.c").get(OPPOSITE[direction])
                assert back == room.stem, f"ES2M_OLDPINE_ONE_WAY: {room.stem}:{direction}:{target}:{back}"
        for npc in re.findall(r'__DIR__"npc/([a-z_]+)"', code):
            assert (area / "npc" / f"{npc}.c").is_file(), f"ES2M_OLDPINE_MISSING_NPC: {room.name}:{npc}"

    dependencies = {
        "custom/armor/neck/psakaml.c",
        "custom/armor/head/violet_hairpin.c",
        "custom/armor/waist/voliet_jade.c",
    }
    for rel in dependencies:
        assert (mudlib / rel).is_file(), f"ES2M_OLDPINE_MISSING_DEPENDENCY: {rel}"
    assert exits(area / "entrance.c").get("northwest") == "/d/snow/sgate"
    if require_snow_link:
        snow = read(mudlib / "d/snow/sgate.c")
        assert '"southeast" : "/d/oldpine/entrance"' in snow, "ES2M_OLDPINE_SNOW_LINK_MISSING"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--runtime", type=Path)
    args = parser.parse_args()
    validate_tree(args.source, False)
    if args.runtime:
        validate_tree(args.runtime, True)
    print("ES2M OLDPINE TOPOLOGY PASS／50 房間、17 NPC、5 物件、雙向入口及高慎虎刀門拜師主線引用閉合。")


if __name__ == "__main__":
    main()
