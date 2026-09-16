#!/usr/bin/env bash
set -euo pipefail

# Static Regression Test／靜態回歸測試：不啟動 MUD，先確認 Original 技能骨架仍符合已考證基線。
ROOT=".runtime/original-es2/mudlib"

# Skill Daemon／技能常駐物件：目前保存來源中確認存在徒手與劍術兩個基礎技能。
test -f "$ROOT/daemon/skill/unarmed.c"
test -f "$ROOT/daemon/skill/sword.c"
grep -q 'register_skill_daemon("unarmed")' "$ROOT/daemon/skill/unarmed.c"
grep -Eq 'register_skill_daemon[[:space:]]*\([[:space:]]*"sword"' "$ROOT/daemon/skill/sword.c"
grep -q 'COMBAT_D->fight' "$ROOT/daemon/skill/unarmed.c"
grep -q 'COMBAT_D->fight' "$ROOT/daemon/skill/sword.c"

# Character Skill Interface／角色技能介面：確認技能等級、學習、進階與映射核心函式仍存在。
SKILL_FEATURE="$ROOT/feature/char/skill.c"
test -f "$SKILL_FEATURE"
grep -q 'void set_skill(string skill, int val)' "$SKILL_FEATURE"
grep -q 'varargs int query_skill(string skill, int raw)' "$SKILL_FEATURE"
grep -q 'improve_skill(string skill, int amount)' "$SKILL_FEATURE"
grep -q 'void advance_skill(string skill, int amount)' "$SKILL_FEATURE"
grep -q 'varargs void map_skill(string skill, string mapped_to)' "$SKILL_FEATURE"

# Original 技能等級上限目前為 200；此處只保護來源既有規格，不自行改寫數值。
grep -q 'if( val > 200 ) val = 200;' "$SKILL_FEATURE"
grep -q 'if( skills\[skill\] > 200 ) skills\[skill\] = 200;' "$SKILL_FEATURE"

echo 'M12 STATIC PASS／靜態驗證通過：Original 技能 Daemon 與角色技能介面基線完整。'
