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
print("KING_MARTIAL_DAMAGE_V0_STATIC_PASS (not Runtime or gameplay validation)")
