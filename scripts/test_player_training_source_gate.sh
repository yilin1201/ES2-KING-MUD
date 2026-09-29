#!/usr/bin/env bash
# 普通玩家 Training Source Gate：只驗證 pinned Original ES2 真正存在的玩家訓練介面。
# 不以 KING/admin/call/goto/clone 或 Historical Evidence 補造 learn/practice/exercise。
set -euo pipefail
ROOT="${1:-${ES2_RUNTIME_DIR:-/opt/es2-king/runtime}}"
ENABLE="$ROOT/mudlib/cmds/usr/enable.c"
SKILLS="$ROOT/mudlib/cmds/usr/skills.c"
STUDY="$ROOT/mudlib/cmds/std/study.c"
PERFORM="$ROOT/mudlib/cmds/std/perform.c"
SKILL="$ROOT/mudlib/feature/char/skill.c"
SNEAK="$ROOT/mudlib/cmds/std/sneak.c"
STEAL="$ROOT/mudlib/cmds/std/steal.c"
for file in "$ENABLE" "$SKILLS" "$STUDY" "$PERFORM" "$SKILL" "$SNEAK" "$STEAL"; do
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

# Skill progression engine：真正的學習進度由 improve_skill / advance_skill 保存，
# 一般玩家上限仍維持 Original 200；KING 的唯一 300 例外由既有 Final Gate 另驗證。
grep -Fq 'improve_skill(string skill, int amount)' "$SKILL"
grep -Fq 'learned[skill] += amount;' "$SKILL"
grep -Fq 'advance_skill(string skill, int amount)' "$SKILL"
grep -Fq 'SKILL_D(skill)->skill_improved' "$SKILL"
grep -Fq 'SKILL_D(skill)->skill_advanced' "$SKILL"
# Final Runtime 已套用既有 KING-only 300 exception；一般玩家仍由 cap helper 回傳 Original 200。
grep -Fq 'ES2-KING OWNER SKILL CAP 300' "$SKILL"
grep -Fq 'return 200;' "$SKILL"
grep -Fq 'if( val > cap ) val = cap;' "$SKILL"
grep -Fq 'if( skills[skill] > es2_king_skill_cap() )' "$SKILL"

# Ordinary-player active progression／普通玩家主動成長：
# Original sneak/steal command 是真正可由玩家操作觸發的 improve_skill call site。
grep -Fq 'me->improve_skill("sneak", 1);' "$SNEAK"
grep -Fq 'me->improve_skill("sneak", me->query_attr("int") );' "$SNEAK"
grep -Fq 'me->improve_skill("stealing", me->query_attr("int"));' "$STEAL"
grep -Fq 'me->improve_skill("stealing", random(me->query_attr("int")));' "$STEAL"

# 重要 Evidence boundary：這個 pinned Target 沒有 usr learn/practice/exercise command。
# 若日後出現，必須重新 audit，而不是默默把 family/historical 語法當 Original。
for command in learn practice exercise; do
  if test -f "$ROOT/mudlib/cmds/usr/$command.c" || test -f "$ROOT/mudlib/cmds/std/$command.c"; then
    echo "PLAYER_TRAINING_SOURCE_GATE_REAUDIT:$command command appeared in pinned runtime" >&2
    exit 1
  fi
done

echo 'PLAYER_TRAINING_SOURCE_GATE_PASS'
echo 'PLAYER_TRAINING_CONFIRMED:skills,enable,study,perform,sneak,steal,improve_skill,advance_skill'
echo 'PLAYER_ACTIVE_TRAINING_SOURCE_CONFIRMED:sneak,steal'
echo 'PLAYER_TRAINING_SOURCE_REQUIRED:learn,practice,exercise'
