#!/usr/bin/env python3
"""KING 武學傷害 V0：四套武學靜態回歸閘門；非實際戰鬥傷害驗證。"""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SKILLS = {
    "冷梅劍法（含鏡境進階招式）": ("es2_king_expansion/runtime/mudlib/d/arena/skill/lunmay.c", 7),
    "傲梅暗劍訣（左手劍）": ("es2_king_expansion/runtime/mudlib/d/arena/skill/advance_lunmay.c", 1),
    "傲劍訣（七式及劍領風騷六段模板）": ("es2_king_expansion/runtime/mudlib/daemon/skill/au-chan_sword.c", 8),
    "如來神掌": ("es2_king_expansion/runtime/mudlib/d/arena/skill/rulai_shenzhang.c", 11),
}
PATTERN = re.compile(r'"attack":\s*(\d+),\s*"force":\s*(\d+),\s*"defense":\s*(\d+)')
for name, (path, expected) in SKILLS.items():
    source = (ROOT / path).read_text(encoding="utf-8")
    values = [tuple(map(int, x)) for x in PATTERN.findall(source)]
    assert len(values) == expected, f"{name}: expected {expected} V0 templates, got {len(values)}"
    for attack, force, defense in values:
        assert 10 <= attack <= 20, f"{name}: attack {attack} outside V0"
        assert 10 <= force <= 20, f"{name}: force {force} outside V0"
        assert 0 <= defense <= 20, f"{name}: defense {defense} outside V0"
    assert "COMBAT_D->fight(" in source, f"{name}: original combat entry missing"
    print(f"V0_STATIC_PASS {name}: {len(values)} templates")
# 驗證武學實際入口及劍領風騷六段迴圈，避免只有模板係數正確、戰鬥入口卻未使用。
martial = (ROOT / "es2_king_expansion/runtime/mudlib/adm/daemons/kingmartiald.c").read_text(encoding="utf-8")
for learned, loaded in (
    ('actor->set_skill("lunmay", level);', 'load_object("/d/arena/skill/lunmay");'),
    ('actor->set_skill("advance_lunmay", level);', 'load_object("/d/arena/skill/advance_lunmay");'),
    ('actor->set_skill("au-chan sword", level);', 'load_object("/daemon/skill/au-chan_sword");'),
    ('actor->set_skill("rulai shenzhang", level);', 'load_object("/d/arena/skill/rulai_shenzhang");'),
):
    assert learned in martial and loaded in martial, f"V0 martial routing missing: {learned}"

sword = (ROOT / SKILLS["傲劍訣（七式及劍領風騷六段模板）"][0]).read_text(encoding="utf-8")
assert 'i < sizeof(jianling_forms)' in sword and 'COMBAT_D->fight(me, opponent, "sword", action, weapon);' in sword
assert len(re.findall(r'"name":"[忠武義德狂情]"', sword)) == 6, "劍領風騷必須保留六段"
rulai = (ROOT / SKILLS["如來神掌"][0]).read_text(encoding="utf-8")
assert 'COMBAT_D->fight(me, opponent, "unarmed", action);' in rulai
assert 'me->set_temp("rulai/form_index", (index + 1) % sizeof(rulai_actions));' in rulai
print("KING_MARTIAL_V0_ROUTING_STATIC_PASS: four skills registered; six-stage sword and unarmed routes preserved")
print("KING_MARTIAL_DAMAGE_V0_STATIC_PASS (not Runtime or gameplay validation)")
