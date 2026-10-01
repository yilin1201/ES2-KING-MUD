#!/usr/bin/env python3
"""驗證 Owner 已授權的 ES2M 振武軍營地圖與原始徵兵條件；非 Gameplay PASS。"""
from pathlib import Path
import sys

root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("es2m_snapshot/mudlib")
gate = root / "custom/zhenwu/room/gate.c"
stone = root / "custom/zhenwu/obj/recruit_stone.c"
lu = root / "custom/zhenwu/npc/lu_xinien.c"
soldier = root / "daemon/class/soldier.c"
errors = []
for p in (gate, stone, lu, soldier):
    if not p.is_file():
        errors.append(f"missing: {p}")
if not errors:
    g, s, l = gate.read_text(), stone.read_text(), lu.read_text()
    for label, content, needle in (
        ("gate", g, '"east" : "/d/snow/sgate"'),
        ("gate", g, '"west" : __DIR__"yard06"'),
        ("stone", s, 'origin_class != "commoner" && origin_class != "fighter"'),
        ("stone", s, 'me->query("gender") != "male"'),
        ("stone", s, 'me->set_class("soldier")'),
        ("stone", s, 'origin_class == "commoner"'),
        ("stone", s, 'set_skill("berserk", 1)'),
        ("stone", s, 'set_skill("powerblow", 1)'),
        ("stone", s, 'set_skill("heavy_parry", 1)'),
        ("stone", s, 'who->welcome_recruit(me)'),
        ("lu", l, 'void welcome_recruit(object who)'),
    ):
        if needle not in content:
            errors.append(f"{label}: missing original rule {needle}")
if errors:
    print("ES2M_ZHENWU_RECRUIT_FAIL\\n" + "\\n".join(errors))
    raise SystemExit(1)
print("ES2M_ZHENWU_RECRUIT_STATIC_PASS")
