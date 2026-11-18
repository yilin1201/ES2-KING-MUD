#!/usr/bin/env python3
from pathlib import Path
import sys

root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("es2m_snapshot/mudlib")
fighter = (root / "daemon/class/fighter.c").read_text()
score = (root / "feature/char/score.c").read_text()
combat = (root / "adm/daemons/combatd.c").read_text()

required_fighter = [
    'set_target_score("combat"',
    'set_target_score("martial art"',
    'set_target_score("martial mastery"',
    'void advance_level(object ob)',
]
required_score = [
    'void\ngain_score(string course, int xp)',
    'foreach(s, v in targ_sc)',
    'CLASS_D(query_class())->advance_level(this_object())',
    'add("level", 1)',
]
for token in required_fighter:
    assert token in fighter, f"FIGHTER LEVEL CONTRACT FAIL: missing {token}"
for token in required_score:
    assert token in score, f"SCORE LEVEL CONTRACT FAIL: missing {token}"

# ES2M 原始成長規則：combat 經驗只在成功閃躲／格擋函式中發放，
# martial art 只在造成傷害後，且使用非基本攻擊技能時發放。
# 不可用全檔 grep 禁止 gain_score，否則會把合法的防禦成長誤判為一般命中成長。
dodge_start = combat.find("void restored_dodge_gain(")
parry_start = combat.find("void restored_parry_gain(")
hit_start = combat.find("private void restored_hit_gain(")
fight_start = combat.find("varargs int" + chr(10) + "fight (")
assert min(dodge_start, parry_start, hit_start, fight_start) >= 0, "ES2M COMBAT CONTRACT FAIL: missing progression function"
dodge_fn = combat[dodge_start:parry_start]
parry_fn = combat[parry_start:hit_start]
hit_fn = combat[hit_start:fight_start]
assert "defense_combat_gain(me, opponent);" in dodge_fn, "ES2M SOURCE CHANGED: dodge combat gain missing"
assert "improve_skill_exact(\"dodge\"" in dodge_fn, "ES2M SOURCE CHANGED: dodge skill progression missing"
assert "defense_combat_gain(me, opponent);" in parry_fn, "ES2M SOURCE CHANGED: parry combat gain missing"
assert "improve_skill_exact(\"parry\"" in parry_fn, "ES2M SOURCE CHANGED: parry skill progression missing"
assert 'gain_score("martial art", 1)' in hit_fn, "ES2M SOURCE CHANGED: enabled martial-art score gain missing"
assert 'member_array(skill, basic_attack_skills) < 0' in hit_fn, "ES2M SOURCE CHANGED: basic attacks must not grant martial art"
assert 'if( damage > 0 ) restored_hit_gain(me, victim, skill, weapon);' in combat, "ES2M SOURCE CHANGED: hit progression must require successful damage"
assert 'gain_score("combat"' not in hit_fn, "ES2M SOURCE CHANGED: ordinary successful hit must not directly grant combat score"

print("ES2M_FIGHTER_LEVEL_CONTRACT_PASS:targets-score-gate-advance-level")
print("ES2M_COMBAT_LEVEL_CONTRACT_PASS:dodge-parry-gain; basic-hit-no-martial-art; enabled-martial-hit-gated-by-damage")
