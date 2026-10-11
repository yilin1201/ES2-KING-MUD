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
    for item in re.findall(r'"(/(?:d|obj|custom)/[^"\s]+)"', code):
        candidate = item.lstrip("/")
        if not Path(candidate).suffix:
            candidate += ".c"
        dependencies.add(candidate)
    return dependencies


def validate_tree(mudlib: Path, require_runtime_link: bool) -> None:
    area = mudlib / "d/wutang"
    rooms = sorted(area.glob("*.c"))
    npcs = sorted((area / "npc").glob("*.c"))
    objects = sorted((area / "obj").glob("*.c"))
    assert len(rooms) == 56, f"ES2M_WUTANG_ROOM_COUNT: {len(rooms)}"
    # 2026-10-10 新增的 may_yin_fong.c 是已確認的 ES2M 來源 NPC，納入固定清冊。
    assert len(npcs) == 32, f"ES2M_WUTANG_NPC_COUNT: {len(npcs)}"
    assert (area / "npc" / "may_yin_fong.c").is_file(), "ES2M_WUTANG_MAY_YIN_FONG_MISSING"
    assert len(objects) == 2, f"ES2M_WUTANG_OBJECT_COUNT: {len(objects)}"

    room_names = {path.stem for path in rooms}
    for room in rooms:
        code = read(room)
        assert 'set("map/area", "五堂鎮");' in code, f"ES2M_WUTANG_AREA_MISSING: {room.name}"
        for direction, target in exits(room).items():
            if target.startswith("/"):
                assert target == "/custom/zhenwu/room/gate", f"ES2M_WUTANG_EXTERNAL_EXIT: {room.name}:{target}"
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
    args = parser.parse_args()
    validate_tree(args.source, False)
    if args.runtime:
        validate_tree(args.runtime, True)
    print("ES2M WUTANG TOPOLOGY PASS／56 房間、32 NPC（含 may_yin_fong）、2 物件及振武入口引用閉合。")


if __name__ == "__main__":
    main()
