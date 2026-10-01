#!/usr/bin/env python3
"""ES2M 李家村地圖證據稽核：只檢查快照，不推定為 Original Canon。"""
import json
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parents[1]
area = root / "es2m_snapshot/mudlib/d/lee"
topology = json.loads((area / "LEE_TOPOLOGY.json").read_text(encoding="utf-8"))
rooms = topology["rooms"]
source_rooms = {p.stem for p in area.glob("*.c")}
errors = []
if topology["room_count"] != len(rooms):
    errors.append("room_count 與 topology rooms 數量不符")
for name, record in rooms.items():
    if name not in source_rooms:
        errors.append(f"缺少地圖程式：{name}.c")
    for direction, destination in record.get("exits", {}).items():
        if destination not in rooms:
            errors.append(f"拓撲未登錄出口：{name}.{direction} -> {destination}")
            if destination not in source_rooms:
                errors.append(f"出口目標缺少程式：{destination}.c")
# Runtime Paths／拓撲登錄與實際 LPC 出口需分開驗證。
# 動態出口或尚未整理的房間只回報差異，不擅自修補原始資料。
for room_name, record in rooms.items():
    source = (area / (room_name + ".c"))
    if not source.is_file():
        continue
    content = source.read_text(encoding="utf-8")
    for direction, target in record.get("exits", {}).items():
        # 支援 __DIR__"room" 與絕對路徑 /d/lee/room 兩種靜態出口。
        quote = """["']"""
        pattern = (quote + re.escape(direction)
                   + quote + r'\s*:\s*(?:__DIR__\s*' + quote
                   + re.escape(target) + quote + '|' + quote + '/d/lee/'
                   + re.escape(target) + quote + ')')
        if not re.search(pattern, content):
            finding = f"{room_name}.{direction} -> {target}"
            if record.get("status") == "USER_DIRECTIVE_RECONSTRUCTION":
                errors.append(f"已確認重建房間出口與拓撲不一致：{finding}")
            else:
                print(f"ES2M_LEE_EXIT_REVIEW: {finding}")
# 已由實際房間程式確認的關鍵雙向路線，必須阻擋意外斷線。
# 此處只鎖定本專案已核實的路線，不推定其他 UNKNOWN 出口。
critical_links = {
    "wroad3": {"east": "wroad4"},
    "wroad4": {"west": "wroad3", "east": "square_w"},
    "square_w": {"west": "wroad4"},
    "shrine": {"in": "nie_backroom"},
    "nie_backroom": {"out": "shrine"},
}
for room_name, links in critical_links.items():
    source_path = area / (room_name + ".c")
    if not source_path.is_file():
        errors.append(f"關鍵路線缺少房間：{room_name}.c")
        continue
    source = source_path.read_text(encoding="utf-8")
    for direction, destination in links.items():
        if rooms.get(room_name, {}).get("exits", {}).get(direction) != destination:
            errors.append(f"關鍵拓撲斷線：{room_name}.{direction} -> {destination}")
        # 已確認的六條路線均使用 __DIR__ 靜態出口。
        expected = (r"""["']""" + re.escape(direction)
                    + r"""["']\s*:\s*__DIR__\s*["']"""
                    + re.escape(destination) + r"""["']""")
        if not re.search(expected, source):
            errors.append(f"關鍵房間出口斷線：{room_name}.{direction} -> {destination}")
# NPC Evidence／掃描房間實際引用的 NPC；缺檔直接阻擋匯入，未使用 NPC 只列待考證。
npc_dir = area / "npc"
npc_sources = {p.stem for p in npc_dir.glob("*.c")}
referenced_npcs = set()
for room_file in area.glob("*.c"):
    source = room_file.read_text(encoding="utf-8")
    for npc in re.findall(r"""(?:["']/?d/lee/npc/|__DIR__\s*["']npc/)([a-zA-Z0-9_]+)["']""", source):
        referenced_npcs.add(npc)
        if npc not in npc_sources:
            errors.append(f"房間 {room_file.stem} 引用不存在 NPC：{npc}.c")
print("ES2M_LEE_NPC_SOURCE:", len(npc_sources))
print("ES2M_LEE_NPC_REFERENCED:", len(referenced_npcs))
print("ES2M_LEE_NPC_UNREFERENCED:", ",".join(sorted(npc_sources-referenced_npcs)) or "none")
# Equipment Evidence／房間及 NPC 可能引用 obj/ 物件；先稽核來源，不擅自生成武器裝備。
object_sources = {p.stem for p in (area / "obj").glob("*.c")}
referenced_objects = set()
for source_file in list(area.glob("*.c")) + list(npc_dir.glob("*.c")):
    source = source_file.read_text(encoding="utf-8")
    for obj in re.findall(r"""(?:["']/?d/lee/obj/|__DIR__\s*["']obj/)([a-zA-Z0-9_]+)["']""", source):
        referenced_objects.add(obj)
        if obj not in object_sources:
            errors.append(f"{source_file.relative_to(area)} 引用不存在物件：{obj}.c")
print("ES2M_LEE_OBJECT_SOURCE:", len(object_sources))
print("ES2M_LEE_OBJECT_REFERENCED:", len(referenced_objects))
print("ES2M_LEE_OBJECT_UNREFERENCED:", ",".join(sorted(object_sources-referenced_objects)) or "none")
# Snapshot 中有但 topology 未登錄者只能列為待考證，不擅自補入地圖。
unindexed = sorted(source_rooms - rooms.keys())
print("ES2M_LEE_TOPOLOGY_ROOMS:", len(rooms))
print("ES2M_LEE_SOURCE_ROOMS:", len(source_rooms))
print("ES2M_LEE_UNINDEXED_SOURCE:", ",".join(unindexed) if unindexed else "none")
for error in errors:
    print("ES2M_LEE_TOPOLOGY_FAIL:", error, file=sys.stderr)
if errors:
    sys.exit(1)
print("ES2M_LEE_TOPOLOGY_STATIC_PASS")
