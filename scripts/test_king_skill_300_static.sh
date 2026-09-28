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
echo "KING SKILL 300 STATIC PASS"
