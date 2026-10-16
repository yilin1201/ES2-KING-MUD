#!/usr/bin/env bash
# 普通玩家 Training Source Gate：原版來源規則只對 pinned Original ES2 檢查；
# KING 專屬技能上限等 Runtime overlay 規則另對生成 Runtime 檢查。
set -euo pipefail
RUNTIME_ROOT="${1:-${ES2_RUNTIME_DIR:-/opt/es2-king/runtime}}"
ORIGINAL_MUDLIB="${2:-${ES2_ORIGINAL_MUDLIB:-}}"
if [[ -z "$ORIGINAL_MUDLIB" || ! -d "$ORIGINAL_MUDLIB" ]]; then
  echo "PLAYER_TRAINING_SOURCE_GATE_BLOCKED: provide pinned Original mudlib path as argument 2 or ES2_ORIGINAL_MUDLIB" >&2
  exit 1
fi

ENABLE="$ORIGINAL_MUDLIB/cmds/usr/enable.c"
SKILLS="$ORIGINAL_MUDLIB/cmds/usr/skills.c"
STUDY="$ORIGINAL_MUDLIB/cmds/std/study.c"
PERFORM="$ORIGINAL_MUDLIB/cmds/std/perform.c"
ORIGINAL_SKILL="$ORIGINAL_MUDLIB/feature/char/skill.c"
ORIGINAL_SNEAK="$ORIGINAL_MUDLIB/cmds/std/sneak.c"
ORIGINAL_STEAL="$ORIGINAL_MUDLIB/cmds/std/steal.c"
RUNTIME_SKILL="$RUNTIME_ROOT/mudlib/feature/char/skill.c"
for file in "$ENABLE" "$SKILLS" "$STUDY" "$PERFORM" "$ORIGINAL_SKILL" "$ORIGINAL_SNEAK" "$ORIGINAL_STEAL" "$RUNTIME_SKILL"; do
  test -f "$file" || { echo "PLAYER_TRAINING_SOURCE_GATE_FAIL:missing:$file" >&2; exit 1; }
done

# Original 可確認介面：skills / enable / study / perform。
grep -Fq 'enable <技能種類> with <技能名稱>' "$ENABLE"
grep -Fq 'query_skill_map()' "$ENABLE"
grep -Fq 'valid_enable' "$ENABLE"
grep -Fq 'skills [-a][<某人>]' "$SKILLS"
grep -Fq 'query_learned()' "$SKILLS"
grep -Fq 'study <物品>' "$STUDY"
grep -Fq 'return ob->study_ob(me);' "$STUDY"
grep -Fq 'perform <技能:絕招>' "$PERFORM"
grep -Fq 'perform_action(me, act, target)' "$PERFORM"

# Original progression engine and real player-callable improvement sites.
grep -Fq 'improve_skill(string skill, int amount)' "$ORIGINAL_SKILL"
grep -Fq 'learned[skill] += amount;' "$ORIGINAL_SKILL"
grep -Fq 'advance_skill(string skill, int amount)' "$ORIGINAL_SKILL"
grep -Fq 'SKILL_D(skill)->skill_improved' "$ORIGINAL_SKILL"
grep -Fq 'SKILL_D(skill)->skill_advanced' "$ORIGINAL_SKILL"
grep -Fq 'me->improve_skill("sneak", 1);' "$ORIGINAL_SNEAK"
grep -Fq 'me->improve_skill("sneak", me->query_attr("int") );' "$ORIGINAL_SNEAK"
grep -Fq 'me->improve_skill("stealing", me->query_attr("int"));' "$ORIGINAL_STEAL"
grep -Fq 'me->improve_skill("stealing", random(me->query_attr("int")));' "$ORIGINAL_STEAL"

# Evidence boundary: absence of learn/practice/exercise is asserted only against pinned Original.
for command in learn practice exercise; do
  if test -f "$ORIGINAL_MUDLIB/cmds/usr/$command.c" || test -f "$ORIGINAL_MUDLIB/cmds/std/$command.c"; then
    echo "PLAYER_TRAINING_SOURCE_GATE_REAUDIT:$command command appeared in pinned Original source" >&2
    exit 1
  fi
done

# ES2-KING Runtime overlay contract is a separate gate, not an Original-source assertion.
grep -Fq 'ES2-KING OWNER SKILL CAP 300' "$RUNTIME_SKILL"
grep -Fq 'return 300;' "$RUNTIME_SKILL"
grep -Fq 'return 200;' "$RUNTIME_SKILL"
grep -Fq 'if( val > cap ) val = cap;' "$RUNTIME_SKILL"
grep -Fq 'if( skills[skill] > es2_king_skill_cap() )' "$RUNTIME_SKILL"

echo 'PLAYER_TRAINING_ORIGINAL_SOURCE_GATE_PASS:pinned Original only'
echo 'PLAYER_TRAINING_RUNTIME_OVERLAY_GATE_PASS:KING cap contract checked separately'
echo 'PLAYER_TRAINING_CONFIRMED:skills,enable,study,perform,sneak,steal,improve_skill,advance_skill'
echo 'PLAYER_TRAINING_SOURCE_REQUIRED:learn,practice,exercise'
