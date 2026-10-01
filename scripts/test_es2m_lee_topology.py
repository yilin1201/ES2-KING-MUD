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
        pattern = (r'["\\']' + re.escape(direction)
                   + r'["\\']\\s*:\\s*(?:__DIR__\\s*["\\']'
                   + re.escape(target) + r'["\\']|["\\']/d/lee/'
                   + re.escape(target) + r'["\\'])')
        if not re.search(pattern, content):
            print(f"ES2M_LEE_EXIT_REVIEW: {room_name}.{direction} -> {target}")
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
