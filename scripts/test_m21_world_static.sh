#!/usr/bin/env bash
set -euo pipefail

# Static Regression／靜態回歸：保護證據分級及 Original／Expansion 邊界。
REGISTRY="original_es2/research/m21_world_content_evidence_registry.md"
PLAN="original_es2/research/plans/m21_world_content_runtime_plan.md"
for file in "$REGISTRY" "$PLAN"; do test -f "$file" || { echo "M21 STATIC FAIL：缺少 $file"; exit 1; }; done

for term in CONFIRMED_RUNTIME UNKNOWN 'mudlib/d/snow/' '43 個' '99 個' inn_hall.c small_temple.c 'ES2-KING Expansion'; do
  grep -Fq "$term" "$REGISTRY" || { echo "M21 STATIC FAIL：證據表缺少 $term"; exit 1; }
done
grep -Fq '只讀 Original 上游，不修改保存原始碼' "$PLAN"
grep -Fq '不宣稱遺失的歷史區域已被補全' "$PLAN"

echo 'M21 WORLD STATIC PASS／世界內容證據分級與 UNKNOWN 邊界正常。'
