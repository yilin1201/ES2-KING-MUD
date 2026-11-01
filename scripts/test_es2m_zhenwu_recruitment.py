#!/usr/bin/env python3
"""驗證振武軍營 ES2M 地圖拓樸與 KING 已定案的徵兵／強力格擋傳授規則；非 Gameplay PASS。"""
from pathlib import Path
import sys

root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("es2m_snapshot/mudlib")
gate = root / "custom/zhenwu/room/gate.c"
snow = root / "d/snow/sgate.c"
yard = root / "custom/zhenwu/room/yard06.c"
stone = root / "custom/zhenwu/obj/recruit_stone.c"
lu = root / "custom/zhenwu/npc/lu_xinien.c"
mee = root / "custom/zhenwu/npc/mee_pei.c"
soldier = root / "daemon/class/soldier.c"
errors = []
for p in (gate, snow, yard, stone, lu, mee, soldier):
    if not p.is_file():
        errors.append(f"missing: {p}")
if not errors:
    g, s, l = gate.read_text(), stone.read_text(), lu.read_text()
    n, y, m = snow.read_text(), yard.read_text(), mee.read_text()
    for label, content, needle in (
        ("gate", g, '"east" : "/d/snow/sgate"'),
        ("gate", g, '"west" : __DIR__"yard06"'),
        ("snow", n, '"west" : "/custom/zhenwu/room/gate"'),
        ("yard06", y, '"east" : __DIR__"gate"'),
        ("stone", s, 'origin_class != "commoner" && origin_class != "fighter"'),
        ("stone", s, 'me->query("gender") != "male"'),
        ("stone", s, 'me->set_class("soldier")'),
        ("stone", s, 'me->set("custom_faction", "soldier.ber")'),
        ("stone", s, 'me->set("soldier/from_fighter", 1)'),
        ("stone", s, 'origin_class == "commoner"'),
        ("stone", s, 'me->set_skill("berserk", 1)'),
        ("stone", s, 'me->set_skill("powerblow", 1)'),
        ("stone", s, '強力格擋改由米沛傳授'),
        ("lu", l, 'void welcome_recruit(object who)'),
        ("mee", m, '#define HEAVY_PARRY_MERIT 100000'),
        ("mee", m, 'me->query_class() != "soldier"'),
        ("mee", m, 'me->query_level() < 40'),
        ("mee", m, 'me->query_learn("heavy_parry")'),
        ("mee", m, 'me->query("soldier/from_fighter")'),
        ("mee", m, 'me->query_score("military service") < HEAVY_PARRY_MERIT'),
        ("mee", m, 'me->improve_skill_exact("heavy_parry", 1)'),
    ):
        if needle not in content:
            errors.append(f"{label}: missing KING/ES2M rule {needle}")
    # 強力格擋不可由徵兵石直接授予；保留米沛的等級、軍功與出身條件。
    if 'me->set_skill("heavy_parry", 1);' in s or 'me->set_learn("heavy_parry", 1);' in s:
        errors.append("stone: heavy_parry must remain gated by Mee Pei's military-merit teaching")
if errors:
    print("ES2M_ZHENWU_RECRUIT_FAIL\\n" + "\\n".join(errors))
    raise SystemExit(1)
print("ES2M_ZHENWU_RECRUIT_STATIC_PASS")
