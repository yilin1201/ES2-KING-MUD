#!/usr/bin/env bash
set -euo pipefail

# Static Regression／靜態回歸：確認 Original 內功的 force 映射、exert 與龍圖心經核心證據仍存在。
# 重要：只檢查 Original 原始碼真正存在的介面與公式，不用推測字串取代原始證據。
ROOT="${1:-.runtime/original-es2}"
DRAGON="$ROOT/mudlib/d/snow/skill/dragon_force.c"
EXERT="$ROOT/mudlib/cmds/std/exert.c"
ESTIMATE="$ROOT/mudlib/cmds/usr/estimate.c"

for file in "$DRAGON" "$EXERT" "$ESTIMATE"; do
  test -f "$file" || { echo "M13 STATIC FAIL／失敗：缺少 $file"; exit 1; }
done

# dragon force／龍圖心經：確認 Skill Daemon 註冊、force 啟用、修煉成長與精氣神消耗。
grep -Fq 'DAEMON_D->register_skill_daemon("dragon force")' "$DRAGON"
grep -Fq 'return usage == "force"' "$DRAGON"
grep -Fq 'me->advance_skill("dragon force", 40)' "$DRAGON"
grep -Fq 'me->improve_skill("dragon force"' "$DRAGON"
grep -Fq 'me->improve_skill("force"' "$DRAGON"
grep -Fq 'me->consume_stat("gin", 10)' "$DRAGON"
grep -Fq 'me->consume_stat("kee", 10)' "$DRAGON"
grep -Fq 'me->consume_stat("sen", 10)' "$DRAGON"
grep -Fq 'me->interrupt(me, "exhausted")' "$DRAGON"
if grep -Fq 'me->interrupt_me(me, "exhausted")' "$DRAGON"; then
  echo 'M13 STATIC FAIL／失敗：dragon force 仍呼叫不存在的 interrupt_me()。' >&2
  exit 1
fi

# exert／運功指令：Original 先取得 force 映射，再透過 SKILL_D 呼叫該專用內功的 exert_function。
grep -Fq 'f = me->skill_mapped("force")' "$EXERT"
grep -Fq 'SKILL_D(me->skill_mapped("force"))->exert_function(me, arg, target)' "$EXERT"

# estimate／估算：確認專用內功啟用時，force 與 kee 會參與攻擊力道修正。
grep -Fq 'me->skill_mapped("force") != "force"' "$ESTIMATE"
grep -Fq 'me->query_skill("force") * me->query_stat("kee") * 4' "$ESTIMATE"

echo 'M13 FORCE STATIC PASS／靜態通過：Original force → 專用內功 → exert 與戰鬥修正架構已鎖定。'
