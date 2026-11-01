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


def validate_tree(mudlib: Path, require_snow_link: bool, expected_npc_count: int) -> None:
    area = mudlib / "d/oldpine"
    rooms = sorted(area.glob("*.c"))
    npcs = sorted((area / "npc").glob("*.c"))
    objects = sorted((area / "obj").glob("*.c"))
    assert len(rooms) == 50, f"ES2M_OLDPINE_ROOM_COUNT: {len(rooms)}"
    assert len(npcs) == expected_npc_count, f"ES2M_OLDPINE_NPC_COUNT: {len(npcs)} expected={expected_npc_count}"
    assert len(objects) == 5, f"ES2M_OLDPINE_OBJECT_COUNT: {len(objects)}"

    room_names = {p.stem for p in rooms}
    for room in rooms:
        code = read(room)
        assert 'set("map/area", ' in code, f"ES2M_OLDPINE_AREA_MISSING: {room.name}"
        for direction, target in exits(room).items():
            if target.startswith("/"):
                external = mudlib / target.lstrip("/")
                if not external.suffix:
                    external = external.with_suffix(".c")
                assert external.is_file(), f"ES2M_OLDPINE_EXTERNAL_EXIT_MISSING: {room.name}:{direction}:{target}"
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
    parser.add_argument("--current-source", type=Path, help="Latest ES2M source mirror for inventory comparison")
    args = parser.parse_args()
    validate_tree(args.source, False, 17)
    runtime_npc_count = 17
    if args.runtime:
        runtime_npc_count = len(list((args.runtime / "d/oldpine/npc").glob("*.c")))
        if args.current_source:
            current_npcs = {p.name for p in (args.current_source / "d/oldpine/npc").glob("*.c")}
            assert runtime_npc_count == len(current_npcs), (
                f"ES2M_OLDPINE_RUNTIME_NPC_COUNT: {runtime_npc_count} expected_current_source={len(current_npcs)}"
            )
        else:
            assert runtime_npc_count in (17, 18), f"ES2M_OLDPINE_RUNTIME_NPC_COUNT: {runtime_npc_count}"
        validate_tree(args.runtime, True, runtime_npc_count)
        source_npcs = {p.name for p in (args.source / "d/oldpine/npc").glob("*.c")}
        runtime_npcs = {p.name for p in (args.runtime / "d/oldpine/npc").glob("*.c")}
        extra_npcs = sorted(runtime_npcs - source_npcs)
        missing_npcs = sorted(source_npcs - runtime_npcs)
        assert not missing_npcs, f"ES2M_OLDPINE_RUNTIME_MISSING_NPC: {missing_npcs}"
        if args.current_source:
            current_npcs = {p.name for p in (args.current_source / "d/oldpine/npc").glob("*.c")}
            assert runtime_npcs == current_npcs, (
                f"ES2M_OLDPINE_RUNTIME_SOURCE_MISMATCH: extra={sorted(runtime_npcs-current_npcs)} "
                f"missing={sorted(current_npcs-runtime_npcs)}"
            )
        assert len(extra_npcs) == runtime_npc_count - len(source_npcs), f"ES2M_OLDPINE_RUNTIME_EXTRA_NPCS: {extra_npcs}"
        if extra_npcs:
            print("ES2M_OLDPINE_RUNTIME_EXTRA_NPC:", ",".join(extra_npcs))
    print(f"ES2M OLDPINE TOPOLOGY PASS／50 房間、歷史快照 17 NPC、Runtime {runtime_npc_count} NPC、5 物件、雙向入口及拜師主線引用閉合。")


if __name__ == "__main__":
    main()
