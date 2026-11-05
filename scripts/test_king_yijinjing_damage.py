#!/usr/bin/env python3
"""KING 易筋經徒手傷害回歸檢查；Static PASS 不等於 Runtime PASS。"""
from pathlib import Path
import sys

root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("es2_king_expansion/runtime/mudlib")
force = (root / "d/arena/skill/yijinjing.c").read_text()
rulai = (root / "d/arena/skill/rulai_shenzhang.c").read_text()
for token in (
    "int inflict_damage(int strength, object victim)",
    "attacker = previous_object();",
    'attacker->query_temp("apply/damage")',
    "victim->resist_damage(damage, attacker)",
    "victim->receive_damage(damage, attacker, attacker)",
):
    assert token in force, f"Yijinjing missing: {token}"
assert 'register_skill_daemon("yijinjing")' in force
assert 'COMBAT_D->fight(me, opponent, "unarmed", action)' in rulai
assert '"attack":40, "force":40, "defense":40' in rulai
print("KING_YIJINJING_DAMAGE_STATIC_PASS (not Runtime damage evidence)")
