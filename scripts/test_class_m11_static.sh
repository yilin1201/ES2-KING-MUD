#!/usr/bin/env bash
set -euo pipefail

# M11 Class Static Test／職業靜態測試：只驗證有 Original 證據的內容，不創造遺失職業公式。
ROOT="${1:-.runtime/original-es2}"
CLASS_DIR="$ROOT/mudlib/daemon/class"
SCORE="$ROOT/mudlib/feature/char/score.c"

# Existing Original daemons／現存 Original 職業常駐物件：平民與武者必須完整存在。
test -f "$CLASS_DIR/commoner.c"
test -f "$CLASS_DIR/fighter.c"
grep -q 'return "平民"' "$CLASS_DIR/commoner.c"
grep -q 'return "武者"' "$CLASS_DIR/fighter.c"

# Class lifecycle／職業生命週期：角色設定職業與升級時，Original 架構必須仍會呼叫 Class Daemon。
grep -q 'void set_class(string new_class)' "$SCORE"
grep -q 'CLASS_D(new_class)->initialize(this_object())' "$SCORE"
grep -q 'CLASS_D(query_class())->advance_level(this_object())' "$SCORE"

# Evidence guard／證據保護：目前沒有 Original thief/soldier daemon，不可把推測檔案冒充原作。
if [[ -f "$CLASS_DIR/thief.c" || -f "$CLASS_DIR/soldier.c" ]]; then
  echo 'FAIL／失敗：偵測到 thief/soldier 職業檔；若為重建檔必須放在 ES2-KING 重建層並標明來源，不得冒充 Original。' >&2
  exit 1
fi

echo 'M11 STATIC PASS／靜態驗證通過：Original 平民、武者與 Class 生命週期完整；缺失職業未被擅自補寫。'
