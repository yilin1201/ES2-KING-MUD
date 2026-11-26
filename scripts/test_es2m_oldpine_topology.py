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
    # ES2M 歷史快照與最新 main 的物件目錄不同：舊快照放 d/oldpine/obj，
    # 最新 main 將 NPC 裝備放 d/oldpine/npc/obj，通用消耗品移至 d/npc/obj。
    objects = sorted((area / "obj").glob("*.c"))
    npc_objects = sorted((area / "npc" / "obj").glob("*.c"))
    expected_root_objects = {
        "coarse_cloth.c", "dragon_pill.c", "head_cloth.c", "meat.c", "venison.c",
    }
    expected_npc_objects = {
        "animitta_kasaya.c", "head_cloth.c", "leather_vest.c", "venison.c",
        "violet_cloth.c", "violet_hairpin.c", "violet_shoes.c",
        "voliet_jade.c", "wither_zenstaff.c",
    }
    assert len(rooms) == 50, f"ES2M_OLDPINE_ROOM_COUNT: {len(rooms)}"
    assert len(npcs) == expected_npc_count, f"ES2M_OLDPINE_NPC_COUNT: {len(npcs)} expected={expected_npc_count}"
    if objects:
        assert {p.name for p in objects} == expected_root_objects, (
            f"ES2M_OLDPINE_ROOT_OBJECT_INVENTORY: {sorted(p.name for p in objects)}"
        )
        assert not npc_objects, f"ES2M_OLDPINE_UNEXPECTED_NPC_OBJECTS: {[p.name for p in npc_objects]}"
        dependencies = {
            "custom/armor/neck/psakaml.c",
            "custom/armor/head/violet_hairpin.c",
            "custom/armor/waist/voliet_jade.c",
        }
    else:
        assert {p.name for p in npc_objects} == expected_npc_objects, (
            f"ES2M_OLDPINE_NPC_OBJECT_INVENTORY: {sorted(p.name for p in npc_objects)}"
        )
        dependencies = {
            "d/npc/obj/psakaml.c",
            "d/npc/obj/coarse_cloth.c",
            "d/npc/obj/dragon_pill.c",
            "d/npc/obj/meat.c",
            "d/oldpine/npc/obj/violet_hairpin.c",
            "d/oldpine/npc/obj/voliet_jade.c",
        }

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

    # 最新 ES2M 已將老松林 NPC 裝備改放 d/oldpine/npc/obj；psakaml 則位於共用 d/npc/obj。
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
    source_npc_count = len(list((args.source / "d/oldpine/npc").glob("*.c")))
    validate_tree(args.source, False, source_npc_count)
    runtime_npc_count = source_npc_count
    if args.runtime:
        runtime_npc_count = len(list((args.runtime / "d/oldpine/npc").glob("*.c")))
        if args.current_source:
            current_npcs = {p.name for p in (args.current_source / "d/oldpine/npc").glob("*.c")}
            runtime_npc_names = {p.name for p in (args.runtime / "d/oldpine/npc").glob("*.c")}
            missing_current_npcs = sorted(current_npcs - runtime_npc_names)
            assert not missing_current_npcs, (
                f"ES2M_OLDPINE_RUNTIME_MISSING_CURRENT_NPCS: {missing_current_npcs}"
            )
            # KING Expansion 保留 goat/squirrel 兩名額外 NPC；不得因上游清冊縮減而刪除。
            king_extra_npcs = runtime_npc_names - current_npcs
            assert king_extra_npcs == {"goat.c", "squirrel.c"}, (
                f"ES2M_OLDPINE_UNCLASSIFIED_EXTRA_NPCS: {sorted(king_extra_npcs)}"
            )
            current_root_objects = {p.name for p in (args.current_source / "d/oldpine/obj").glob("*.c")}
            current_npc_objects = {p.name for p in (args.current_source / "d/oldpine/npc/obj").glob("*.c")}
            runtime_root_objects = {p.name for p in (args.runtime / "d/oldpine/obj").glob("*.c")}
            runtime_npc_objects = {p.name for p in (args.runtime / "d/oldpine/npc/obj").glob("*.c")}
            assert runtime_root_objects == current_root_objects, (
                f"ES2M_OLDPINE_RUNTIME_ROOT_OBJECT_MISMATCH: extra={sorted(runtime_root_objects-current_root_objects)} "
                f"missing={sorted(current_root_objects-runtime_root_objects)}"
            )
            assert runtime_npc_objects == current_npc_objects, (
                f"ES2M_OLDPINE_RUNTIME_NPC_OBJECT_MISMATCH: extra={sorted(runtime_npc_objects-current_npc_objects)} "
                f"missing={sorted(current_npc_objects-runtime_npc_objects)}"
            )
        else:
            assert runtime_npc_count == source_npc_count, f"ES2M_OLDPINE_RUNTIME_NPC_COUNT: {runtime_npc_count} expected={source_npc_count}"
        validate_tree(args.runtime, True, runtime_npc_count)
        source_npcs = {p.name for p in (args.source / "d/oldpine/npc").glob("*.c")}
        runtime_npcs = {p.name for p in (args.runtime / "d/oldpine/npc").glob("*.c")}
        reference_npcs = (
            {p.name for p in (args.current_source / "d/oldpine/npc").glob("*.c")}
            if args.current_source else source_npcs
        )
        extra_npcs = sorted(runtime_npcs - reference_npcs)
        missing_npcs = sorted(reference_npcs - runtime_npcs)
        assert not missing_npcs, f"ES2M_OLDPINE_RUNTIME_MISSING_NPC: {missing_npcs}"
        assert len(extra_npcs) == runtime_npc_count - len(reference_npcs), (
            f"ES2M_OLDPINE_RUNTIME_EXTRA_NPCS: {extra_npcs}"
        )
        if extra_npcs:
            print("ES2M_OLDPINE_RUNTIME_EXTRA_NPC:", ",".join(extra_npcs))
    source_objects = len(list((args.source / "d/oldpine/obj").glob("*.c"))) + len(list((args.source / "d/oldpine/npc/obj").glob("*.c")))
    runtime_objects = len(list(((args.runtime or args.source) / "d/oldpine/obj").glob("*.c"))) + len(list(((args.runtime or args.source) / "d/oldpine/npc/obj").glob("*.c")))
    print(
        f"ES2M OLDPINE TOPOLOGY PASS／50 房間、最新來源 {source_npc_count} NPC、Runtime {runtime_npc_count} NPC、"
        f"來源物件 {source_objects} 件、Runtime 物件 {runtime_objects} 件、雙向入口及拜師主線引用閉合。"
    )


if __name__ == "__main__":
    main()
