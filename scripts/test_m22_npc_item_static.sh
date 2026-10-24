#!/usr/bin/env bash
set -euo pipefail

# Static Regression／靜態回歸：保護 Original 證據分級與禁止補造規則。
REGISTRY="original_es2/research/m22_npc_item_evidence_registry.md"
PLAN="original_es2/research/plans/m22_npc_item_runtime_plan.md"
for file in "$REGISTRY" "$PLAN"; do test -f "$file" || { echo "M22 STATIC FAIL：缺少 $file"; exit 1; }; done
for term in CONFIRMED_RUNTIME UNKNOWN '23 個' '29 個' '3 個' F_VILLAGER F_SOLDIER F_VENDOR F_FIGHTER F_BANDIT 'ES2-KING Expansion'; do
  grep -Fq "$term" "$REGISTRY" || { echo "M22 STATIC FAIL：證據表缺少 $term"; exit 1; }
done
grep -Fq '不補造 HP、技能等級、掉落率、商品價格或特殊能力' "$REGISTRY"
grep -Fq 'ACTIONS-INFRA-BLOCKED' "$PLAN"
echo 'M22 NPC ITEM STATIC PASS／NPC、物品與證據邊界正常。'
