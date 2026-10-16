#!/usr/bin/env bash
set -euo pipefail
DOC="original_es2/research/closure/m24_system_data_integrity.md"
test -f "$DOC"
for term in CONFIRMED_RUNTIME UNKNOWN Save Load Autoload Condition Death Revive Score Experience Economy 'Item protection' 'ES2-KING Expansion'; do
  grep -Fq "$term" "$DOC" || { echo "M24 STATIC FAIL：缺少 $term"; exit 1; }
done
# Quest Persistence／任務持久化：架構已確認，但目標 Original 版本仍未完成正式驗收。
grep -Fq '目標 Original 任務跨登入完整驗收' "$DOC"
grep -Fq '仍不得宣告完成' "$DOC"
grep -Fq '不修改 Original 保存原始碼' "$DOC"
echo 'M24 DATA INTEGRITY STATIC PASS／資料完整性與 UNKNOWN 邊界正常。'
