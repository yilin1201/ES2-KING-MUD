#!/usr/bin/env bash
set -euo pipefail
F="es2_king_expansion/runtime/mudlib/adm/daemons/kingmartiald.c"
for skill in force unarmed sword "secondhand sword" "twohanded sword" blade "twohanded blade" staff parry dodge whip; do
  grep -Fq "\"$skill\"" "$F"
done
grep -Fq 'level > 300' "$F"
grep -Fq 'set_skill("yijinjing", level)' "$F"
grep -Fq 'set_skill("batian lianti jue", level)' "$F"
grep -Fq 'set_skill("rulai shenzhang", level)' "$F"
APPLY="scripts/apply_es2_king_expansion.sh"
grep -Fq 'ES2-KING OWNER SKILL CAP 300' "$APPLY"
grep -Fq 'return 300;' "$APPLY"
grep -Fq 'return 200;' "$APPLY"
grep -Fq 'set_cold_plum", user, 300' "$APPLY"
grep -Fq 'set_creator_core_martial", user, 300' "$APPLY"
grep -Fq 'set_rulai_shenzhang", user, 300' "$APPLY"
grep -Fq 'skills[skill] > es2_king_skill_cap()' "$APPLY"
grep -Fq 's > es2_king_skill_cap()' "$APPLY"
echo "KING SKILL 300 STATIC PASS"
