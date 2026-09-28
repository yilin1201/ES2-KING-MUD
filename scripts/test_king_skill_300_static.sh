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
# KING Project Canon mapping regression／使用者驗收指定的正式裝備關係。
grep -Fq 'map_skill("secondhand sword", "advance_lunmay")' "$F"
grep -Fq 'map_skill("dodge", "mayin")' "$F"
grep -Fq 'map_skill("staff", "chin_staff")' "$F"
grep -Fq 'map_skill("blade", "daxie qisun blade")' "$F"
for pair in 'advance_lunmay|傲梅暗劍訣' 'mayin|梅影身法' 'chin_staff|青邪杖法' 'kuxiao force|大邪心法' 'daxie qisun blade|大邪七損刀'; do
  id="${pair%%|*}"; zh="${pair#*|}"
  grep -Fq "CHINESE_D->add_translate(\"$id\", \"$zh\")" "$F"
done
grep -Fq 'actor->set("es2_king/yijinjing_qi_manifest", level == 300 ? 1 : 0);' "$F"
test "$(grep -Fc 'actor->set("es2_king/yijinjing_qi_manifest", level == 300 ? 1 : 0);' "$F")" -eq 2
! grep -Eqi 'SSS|武學品階|達摩初祖' "$F"
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
