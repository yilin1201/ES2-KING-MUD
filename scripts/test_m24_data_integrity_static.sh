#!/usr/bin/env bash
set -euo pipefail
DOC="original_es2/research/m24_system_data_integrity.md"
test -f "$DOC"
for term in CONFIRMED_RUNTIME UNKNOWN Save Load Autoload Condition Death Revive Score Experience Economy 'Item protection' 'ES2-KING Expansion'; do
  grep -Fq "$term" "$DOC" || { echo "M24 STATIC FAIL：缺少 $term"; exit 1; }
done
grep -Fq '任務進度跨登入保存仍不得宣告完成' "$DOC"
grep -Fq '不修改 Original 保存原始碼' "$DOC"
echo 'M24 DATA INTEGRITY STATIC PASS／資料完整性與 UNKNOWN 邊界正常。'
