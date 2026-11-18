#!/usr/bin/env python3
"""驗證振武軍營 ES2M 原始階段與 KING Overlay 階段各自的徵兵規則；非 Gameplay PASS。"""
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
    king_overlay = 'me->set("custom_faction", "soldier.ber")' in s

    for label, content, needle in (
        ("gate", g, '"east" : "/d/snow/sgate"'),
        ("gate", g, '"west" : __DIR__"yard06"'),
        ("snow", n, '"west" : "/custom/zhenwu/room/gate"'),
        ("yard06", y, '"east" : __DIR__"gate"'),
        ("stone", s, 'origin_class != "commoner" && origin_class != "fighter"'),
        ("stone", s, 'me->query("gender") != "male"'),
        ("stone", s, 'me->set_class("soldier")'),
        ("stone", s, 'origin_class == "commoner"'),
        ("stone", s, 'me->set_skill("berserk", 1)'),
        ("stone", s, 'me->set_skill("powerblow", 1)'),
        ("lu", l, 'void welcome_recruit(object who)'),
    ):
        if needle not in content:
            errors.append(f"{label}: missing base rule {needle}")

    if king_overlay:
        # KING Overlay：保留派系、武者轉任標記，強力格擋改由米沛按軍功條件傳授。
        for label, content, needle in (
            ("stone", s, 'me->set("custom_faction", "soldier.ber")'),
            ("stone", s, 'me->set("soldier/from_fighter", 1)'),
            ("stone", s, '強力格擋改由米沛傳授'),
            ("mee", m, '#define HEAVY_PARRY_MERIT 100000'),
            ("mee", m, 'me->query_class() != "soldier"'),
            ("mee", m, 'me->query_level() < 40'),
            ("mee", m, 'me->query_learn("heavy_parry")'),
            ("mee", m, 'me->query("soldier/from_fighter")'),
            ("mee", m, 'me->query_score("military service") < HEAVY_PARRY_MERIT'),
            ("mee", m, 'me->improve_skill_exact("heavy_parry", 1)'),
        ):
            if needle not in content:
                errors.append(f"{label}: missing KING rule {needle}")
        if 'me->set_skill("heavy_parry", 1);' in s or 'me->set_learn("heavy_parry", 1);' in s:
            errors.append("stone: heavy_parry must remain gated by Mee Pei's military-merit teaching")
        print("ES2M_ZHENWU_RECRUIT_MODE: KING_OVERLAY")
    else:
        # ES2M 原始階段：驗證上游原始徵兵技能規則；KING 覆蓋尚未套用。
        if 'set_skill("heavy_parry", 1)' not in s or 'set_learn("heavy_parry", 1)' not in s:
            errors.append("stone: missing ES2M original heavy_parry enlist rule")
        print("ES2M_ZHENWU_RECRUIT_MODE: ORIGINAL_ES2M")

if errors:
    print("ES2M_ZHENWU_RECRUIT_FAIL\\n" + "\\n".join(errors))
    raise SystemExit(1)
print("ES2M_ZHENWU_RECRUIT_STATIC_PASS")
