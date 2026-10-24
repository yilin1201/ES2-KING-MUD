#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.runtime/es2-king}"
AOJIAN="$ROOT/mudlib/daemon/skill/au-chan_sword.c"
test -f "$AOJIAN"

# ORIGINAL COMBAT NARRATION PRESERVATION — HIGHEST PRIORITY.
# 有 Evidence 的完整人物出招敘述不得因排版／手機顯示而縮寫。
grep -Fq '$N施展傲劍訣中的極招' "$AOJIAN"
grep -Fq 'HIR "劍" HIY "領" HIG "風" HIC "騷" HIW' "$AOJIAN"
grep -Fq '『"+stage["color"]+stage["name"]+HIW+"』' "$AOJIAN"
grep -Fq '一道"+stage["color"]+stage["color_name"]+HIW+"的劍氣射向$n！' "$AOJIAN"

# 六段 Evidence 必須完整存在，不能以省略／摘要方式取代。
for stage in 忠 武 義 德 狂 情; do
  grep -Fq "\"name\":\"$stage\"" "$AOJIAN"
done

# 防止再次退回已發生過的縮寫版本：action 不得直接從「劍領風騷」開始而遺失人物出招主句。
! grep -Fq '"action":HIR "劍" HIY "領" HIG "風" HIC "騷"' "$AOJIAN"

echo "ORIGINAL_COMBAT_NARRATION_PRESERVATION_PASS"
