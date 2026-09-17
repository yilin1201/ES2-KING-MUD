#!/usr/bin/env bash
set -euo pipefail

# Static Regression／靜態回歸：確認研究文件保留已確認證據與 UNKNOWN 邊界。
REGISTRY="original_es2/research/m19_lifecycle_evidence_registry.md"
PLAN="original_es2/research/m19_lifecycle_runtime_plan.md"

for file in "$REGISTRY" "$PLAN"; do
  [[ -f "$file" ]] || { echo "M19 STATIC FAIL：缺少 $file"; exit 1; }
done

for term in CONFIRMED_RUNTIME UNKNOWN unconcious revive die make_corpse make_living time_aged 86400; do
  grep -Fq "$term" "$REGISTRY" || { echo "M19 STATIC FAIL：證據表缺少 $term"; exit 1; }
done

grep -Fq '不修改 Original 保存原始碼' "$PLAN"
grep -Fq '不代表所有死亡懲罰或輪迴規則已完成' "$PLAN"

echo 'M19 LIFECYCLE STATIC PASS／角色生命週期證據分級與 Original 邊界正常。'
