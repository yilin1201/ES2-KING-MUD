#!/usr/bin/env bash
set -euo pipefail

# Static Regression／靜態回歸：確認 Original 內功的 force 映射、exert 與龍圖心經核心證據仍存在。
ROOT=".runtime/original-es2"
DRAGON="$ROOT/mudlib/d/snow/skill/dragon_force.c"
EXERT="$ROOT/mudlib/cmds/std/exert.c"
ESTIMATE="$ROOT/mudlib/cmds/usr/estimate.c"

for file in "$DRAGON" "$EXERT" "$ESTIMATE"; do
  test -f "$file" || { echo "M13 STATIC FAIL／失敗：缺少 $file"; exit 1; }
done

# dragon force／龍圖心經：必須仍是可 enable 為 force 的 Skill Daemon。
grep -Fq 'register_skill_daemon("dragon force")' "$DRAGON"
grep -Fq 'return usage == "force"' "$DRAGON"
grep -Fq 'me->advance_skill("dragon force", 40)' "$DRAGON"
grep -Fq 'me->improve_skill("dragon force"' "$DRAGON"
grep -Fq 'me->improve_skill("force"' "$DRAGON"
grep -Fq 'me->consume_stat("gin", 10)' "$DRAGON"
grep -Fq 'me->consume_stat("kee", 10)' "$DRAGON"
grep -Fq 'me->consume_stat("sen", 10)' "$DRAGON"

# exert／運功指令：必須由 force 映射找到專用內功，不可退化成直接寫死某一套武學。
grep -Fq 'me->skill_mapped("force")' "$EXERT"
grep -Fq 'exert_function(me, f, target)' "$EXERT"

# estimate／估算：確認專用內功啟用時，force 與 kee 會參與攻擊強度修正。
grep -Fq 'me->skill_mapped("force") != "force"' "$ESTIMATE"
grep -Fq 'me->query_skill("force") * me->query_stat("kee") * 4' "$ESTIMATE"

echo 'M13 FORCE STATIC PASS／靜態通過：Original force → 專用內功 → exert 與戰鬥修正架構已鎖定。'
