#!/usr/bin/env python3
"""ES2M 振武軍營拓樸／靜態證據檢查；不擅自改寫雪亭原始出口。"""
from pathlib import Path
import re
import sys

root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("es2m_snapshot/mudlib")
zone = root / "custom/zhenwu"
expected = [
    *(f"room/yard{n:02d}.c" for n in range(2, 15)),
    "room/gate.c", "room/camp.c", "room/shed.c", "room/big_tent.c",
    "npc/lu_xinien.c", "npc/mee_pei.c", "npc/soldier.c",
    "npc/target_stake.c", "npc/zhenwu_soldier.c",
    "obj/fire_gauntlets.c", "obj/great_axe_of_mighty.c",
    "obj/recruit_stone.c", "obj/short_pike.c",
    "obj/steel_armor.c", "obj/steel_boots.c",
]
missing = [p for p in expected if not (zone / p).is_file()]
errors = [f"missing: {p}" for p in missing]
for path in sorted((zone / "room").glob("*.c")):
    source = path.read_text()
    # 只驗證可確定的 __DIR__ 房間連結；外部地圖由獨立衝突清冊處理。
    for target in re.findall(r'__DIR__\\s*"([a-z0-9_]+)"', source):
        if not (zone / "room" / (target + ".c")).is_file():
            errors.append(f"{path.name}: missing internal room {target}")
for path in sorted(zone.rglob("*.c")):
    source = path.read_text()
    for target in re.findall(r'"/custom/zhenwu/(npc|obj|room)/([a-z0-9_]+)"', source):
        if not (zone / target[0] / (target[1] + ".c")).is_file():
            errors.append(f"{path.relative_to(zone)}: missing {target[0]}/{target[1]}")
if errors:
    print("ES2M_ZHENWU_TOPOLOGY_FAIL\n" + "\n".join(errors))
    raise SystemExit(1)
print(f"ES2M_ZHENWU_TOPOLOGY_PASS files={len(expected)}")
