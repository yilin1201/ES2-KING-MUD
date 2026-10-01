#!/usr/bin/env python3
"""ES2M 李家村地圖證據稽核：只檢查快照，不推定為 Original Canon。"""
import json
import pathlib
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
