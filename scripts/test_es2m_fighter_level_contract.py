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

# ES2M source still has no generic combat/martial-art score gain on ordinary hits.
assert 'gain_score("combat"' not in combat, "ES2M SOURCE CHANGED: review native combat gain before KING extension"
assert 'gain_score("martial art"' not in combat, "ES2M SOURCE CHANGED: review native martial-art gain before KING extension"

print("ES2M_FIGHTER_LEVEL_CONTRACT_PASS:targets-score-gate-advance-level")
print("ES2M_COMBAT_LEVEL_GAP_CONFIRMED:no-generic-combat-or-martial-art-hit-gain")
