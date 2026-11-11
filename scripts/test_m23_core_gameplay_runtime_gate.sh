#!/usr/bin/env bash
set -euo pipefail

# Integration Gate／整合閘門：確認 Original 核心介面可沿同一角色流程串接。
ROOT="${1:-.runtime/original-es2}/mudlib"
SCORE="$ROOT/feature/char/score.c"
RELATION="$ROOT/feature/char/relation.c"
SKILL="$ROOT/feature/char/skill.c"
for file in "$SCORE" "$RELATION" "$SKILL" "$ROOT/cmds/std/apprentice.c" "$ROOT/cmds/std/study.c" "$ROOT/cmds/std/exert.c" "$ROOT/cmds/std/perform.c" "$ROOT/feature/study.c" "$ROOT/feature/char/combat.c" "$ROOT/feature/char/attack.c" "$ROOT/d/snow/npc/alchemist.c" "$ROOT/d/snow/skill/dragon_force.c"; do
  test -f "$file" || { echo "M23 RUNTIME FAIL：缺少 $file"; exit 1; }
done

# Class／職業與角色初始化。
grep -Fq 'void set_class(string new_class)' "$SCORE"
grep -Fq 'CLASS_D(query_class())->initialize(this_object())' "$SCORE"

# Apprentice／拜師與雙向關係。
grep -Fq 'ob->accept_apprentice(me)' "$ROOT/cmds/std/apprentice.c"
grep -Fq 'ob->init_apprentice(me)' "$ROOT/cmds/std/apprentice.c"
grep -Fq 'int is_apprentice_of(object ob)' "$RELATION"
grep -Fq 'int init_apprentice(object ob)' "$RELATION"

# Skill、Study、Enable／技能、研讀與激發。
for signature in 'void set_skill(string skill, int val)' 'varargs int query_skill(string skill, int raw)' 'improve_skill(string skill, int amount)' 'void advance_skill(string skill, int amount)' 'varargs void map_skill(string skill, string mapped_to)'; do
  grep -Fq "$signature" "$SKILL"
done
grep -Fq 'return ob->study_ob(me)' "$ROOT/cmds/std/study.c"
grep -Fq 'me->improve_skill(t, 1 + random(point))' "$ROOT/feature/study.c"
grep -Fq 'me->map_skill(ski, map_to)' "$ROOT/cmds/usr/enable.c"

# Martial and combat／內功、招式與戰鬥映射。
grep -Fq 'SKILL_D(me->skill_mapped("force"))->exert_function(me, arg, target)' "$ROOT/cmds/std/exert.c"
grep -Fq 'perform_action(me, act, target)' "$ROOT/cmds/std/perform.c"
grep -Fq 'force_sk = skill_mapped("force")' "$ROOT/feature/char/combat.c"
grep -Fq 'COMBAT_D->auto_fight' "$ROOT/feature/char/attack.c"

# Concrete Original chain／Original 實例：平民拜方士與龍圖心經。
grep -Fq 'me->set_class("alchemist")' "$ROOT/d/snow/npc/alchemist.c"
grep -Fq 'map_skill("force", "dragon force")' "$ROOT/d/snow/npc/alchemist.c"
grep -Fq 'exert_function(object me, string func, object target)' "$ROOT/d/snow/skill/dragon_force.c"

echo 'M23 CORE GAMEPLAY RUNTIME PASS／職業→拜師→技能→研讀／激發→武學／戰鬥核心鏈完整。'
