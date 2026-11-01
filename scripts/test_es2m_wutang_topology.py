#!/usr/bin/env python3
"""五堂鎮（武當區域）來源與 Runtime 拓樸閘門；不代表 Gameplay PASS。"""
import argparse
import re
from pathlib import Path

OPPOSITE = {
    "north": "south", "south": "north", "east": "west", "west": "east",
    "northeast": "southwest", "southwest": "northeast",
    "northwest": "southeast", "southeast": "northwest", "up": "down", "down": "up",
    "in": "out", "out": "in", "northdown": "southup", "southup": "northdown",
}
ONE_WAY = {("temple_road_s", "dark_alley_e"), ("yan_gate", "temple_road_n"), ("temple_yard", "temple")}
BOAT_ROOMS = {"ferry_boat_huang", "ferry_boat_ro"}


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def exits(room: Path) -> dict[str, str]:
    match = re.search(r'set\("exits", \(\[(.*?)\]\)\);', read(room), re.S)
    if not match:
        return {}
    return dict(re.findall(r'"([a-z]+)"\s*:\s*(?:__DIR__)?"([^"]+)"', match.group(1)))


def literal_dependencies(path: Path, mudlib: Path) -> set[str]:
    code = read(path)
    dependencies = set()
    for item in re.findall(r'__DIR__\s*"([^"]+)"', code):
        candidate = path.parent / item
        if not candidate.suffix:
            candidate = candidate.with_suffix(".c")
        dependencies.add(candidate.relative_to(mudlib).as_posix())
    for item in re.findall(r'"(/(?:d|obj|custom)/[^"\\s]+)"', code):
        # 目錄前綴（例如 /d/wutang/）是區域常數，不是 LPC 檔案相依；
        # 不可把它錯誤補成 d/wutang/.c。只驗證實際檔案路徑。
        if item.endswith("/"):
            continue
        candidate = item.lstrip("/")
        if not Path(candidate).suffix:
            candidate += ".c"
        dependencies.add(candidate)
    return dependencies


def validate_tree(mudlib: Path, require_runtime_link: bool, expected_room_count: int, expected_npc_count: int, expected_boat_count: int) -> None:
    area = mudlib / "d/wutang"
    all_root_files = sorted(area.glob("*.c"))
    boat_rooms = [p for p in all_root_files if p.stem in BOAT_ROOMS]
    rooms = [p for p in all_root_files if p.stem not in BOAT_ROOMS]
    npcs = sorted((area / "npc").glob("*.c"))
    objects = sorted((area / "obj").glob("*.c"))
    assert len(rooms) == expected_room_count, f"ES2M_WUTANG_ROOM_COUNT: {len(rooms)} expected={expected_room_count}"
    # 2026-10-10 新增的 may_yin_fong.c 是已確認的 ES2M 來源 NPC，納入固定清冊。
    assert len(npcs) == expected_npc_count, f"ES2M_WUTANG_NPC_COUNT: {len(npcs)} expected={expected_npc_count}"
    assert (area / "npc" / "may_yin_fong.c").is_file(), "ES2M_WUTANG_MAY_YIN_FONG_MISSING"
    assert len(objects) == 2, f"ES2M_WUTANG_OBJECT_COUNT: {len(objects)}"
    assert len(boat_rooms) == expected_boat_count, (
        f"ES2M_WUTANG_BOAT_ROOM_COUNT: {len(boat_rooms)} expected={expected_boat_count}"
    )
    for boat in boat_rooms:
        code = read(boat)
        assert 'set("map/area", "羿水");' in code, f"ES2M_WUTANG_BOAT_AREA_MISSING: {boat.name}"
        assert 'set("no_fight", 1);' in code, f"ES2M_WUTANG_BOAT_NO_FIGHT_MISSING: {boat.name}"
        assert 'set("map/layer", ' in code, f"ES2M_WUTANG_BOAT_LAYER_MISSING: {boat.name}"
        assert 'set("exits"' not in code, f"ES2M_WUTANG_BOAT_MUST_NOT_HAVE_EXITS: {boat.name}"

    room_names = {path.stem for path in rooms}
    for room in rooms:
        code = read(room)
        assert 'set("map/area", "五堂鎮");' in code, f"ES2M_WUTANG_AREA_MISSING: {room.name}"
        for direction, target in exits(room).items():
            if target.startswith("/"):
                external = mudlib / target.lstrip("/")
                if not external.suffix:
                    external = external.with_suffix(".c")
                assert external.is_file(), f"ES2M_WUTANG_EXTERNAL_EXIT_MISSING: {room.name}:{target}"
                continue
            assert target in room_names, f"ES2M_WUTANG_BROKEN_EXIT: {room.name}:{direction}:{target}"
            back = exits(area / f"{target}.c").get(OPPOSITE[direction])
            assert back == room.stem or (room.stem, target) in ONE_WAY or (target, room.stem) in ONE_WAY, \
                f"ES2M_WUTANG_ONE_WAY: {room.stem}:{direction}:{target}:{back}"
        for npc in re.findall(r'__DIR__"npc/([a-z_]+)"', code):
            assert (area / "npc" / f"{npc}.c").is_file(), f"ES2M_WUTANG_MISSING_NPC: {room.name}:{npc}"

    for source in sorted(area.rglob("*.c")):
        for dependency in literal_dependencies(source, mudlib):
            assert (mudlib / dependency).is_file(), f"ES2M_WUTANG_MISSING_DEPENDENCY: {source.name}:{dependency}"
    assert exits(area / "entrance.c").get("north") == "/custom/zhenwu/room/gate"
    if require_runtime_link:
        gate = read(mudlib / "custom/zhenwu/room/gate.c")
        assert '"south" : "/d/wutang/entrance"' in gate, "ES2M_WUTANG_ZHENWU_LINK_MISSING"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--runtime", type=Path)
    parser.add_argument("--current-source", type=Path, help="Latest ES2M source mirror for room inventory comparison")
    args = parser.parse_args()
    validate_tree(args.source, False, 56, 32, 0)
    runtime_room_count = 56
    runtime_npc_count = 32
    runtime_boat_count = 0
    if args.runtime:
        runtime_area = args.runtime / "d/wutang"
        runtime_boat_count = sum(1 for p in runtime_area.glob("*.c") if p.stem in BOAT_ROOMS)
        runtime_room_count = len(list(runtime_area.glob("*.c"))) - runtime_boat_count
        runtime_npc_count = len(list((runtime_area / "npc").glob("*.c")))
        if args.current_source:
            current_area = args.current_source / "d/wutang"
            current_boat_names = {p.name for p in current_area.glob("*.c") if p.stem in BOAT_ROOMS}
            current_room_names = {p.name for p in current_area.glob("*.c") if p.stem not in BOAT_ROOMS}
            current_npc_names = {p.name for p in (current_area / "npc").glob("*.c")}
            assert runtime_room_count == len(current_room_names), (
                f"ES2M_WUTANG_RUNTIME_ROOM_COUNT: {runtime_room_count} expected_current_source={len(current_room_names)}"
            )
            assert runtime_boat_count == len(current_boat_names), (
                f"ES2M_WUTANG_RUNTIME_BOAT_COUNT: {runtime_boat_count} expected_current_source={len(current_boat_names)}"
            )
            assert runtime_npc_count == len(current_npc_names), (
                f"ES2M_WUTANG_RUNTIME_NPC_COUNT: {runtime_npc_count} expected_current_source={len(current_npc_names)}"
            )
        else:
            assert runtime_room_count == 56, f"ES2M_WUTANG_RUNTIME_ROOM_COUNT: {runtime_room_count}"
            assert runtime_npc_count in (32, 33), f"ES2M_WUTANG_RUNTIME_NPC_COUNT: {runtime_npc_count}"
            assert runtime_boat_count in (0, 2), f"ES2M_WUTANG_RUNTIME_BOAT_COUNT: {runtime_boat_count}"
        validate_tree(args.runtime, True, runtime_room_count, runtime_npc_count, runtime_boat_count)
        if args.current_source:
            runtime_room_names = {p.name for p in runtime_area.glob("*.c") if p.stem not in BOAT_ROOMS}
            runtime_boat_names = {p.name for p in runtime_area.glob("*.c") if p.stem in BOAT_ROOMS}
            runtime_npc_names = {p.name for p in (runtime_area / "npc").glob("*.c")}
            assert runtime_room_names == current_room_names, "ES2M_WUTANG_RUNTIME_ROOM_INVENTORY_MISMATCH"
            assert runtime_boat_names == current_boat_names, "ES2M_WUTANG_RUNTIME_BOAT_INVENTORY_MISMATCH"
            assert runtime_npc_names == current_npc_names, "ES2M_WUTANG_RUNTIME_NPC_INVENTORY_MISMATCH"
    print(
        f"ES2M WUTANG TOPOLOGY PASS／歷史快照 56 房間、32 NPC；"
        f"Runtime {runtime_room_count} 鎮區房間、{runtime_npc_count} NPC、"
        f"{runtime_boat_count} 艘羿水渡船、2 物件及振武入口引用閉合。"
    )


if __name__ == "__main__":
    main()
