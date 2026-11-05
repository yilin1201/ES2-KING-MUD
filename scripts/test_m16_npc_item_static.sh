#!/usr/bin/env bash
set -euo pipefail

# Static Regression（靜態回歸測試）：
# 不啟動 MUD（Multi-User Dungeon，多人文字角色扮演遊戲），直接檢查 M16 證據文件是否守住 Original／Expansion 邊界。
REGISTRY="original_es2/research/m16_npc_item_evidence_registry.md"
PLAN="original_es2/research/plans/m16_npc_item_runtime_plan.md"

for file in "$REGISTRY" "$PLAN"; do
  if [[ ! -f "$file" ]]; then
    echo "M16 Static FAIL：缺少必要檔案：$file"
    exit 1
  fi
done

# 必須保留已確認名稱與 unknown（未知）邊界。
required_terms=(
  "梅影風"
  "May yin fong"
  "fighter.lunmay"
  "銀霜鎧"
  "奔雲靴"
  "梅花白襖"
  "流雲清玉帶"
  "白玉戒指"
  "寒霜劍"
  "冰雪匕"
  "UNKNOWN"
  "CONFIRMED_TEXT"
  "CONFIRMED_RUNTIME"
)

for term in "${required_terms[@]}"; do
  if ! grep -Fq -- "$term" "$REGISTRY"; then
    echo "M16 Static FAIL：證據登錄表缺少必要內容：$term"
    exit 1
  fi
done

# 舊模擬曾出現的精確數值不能被當成 Original 已確認資料。
# 若未來取得真正 Original Runtime 原始碼，應先更新證據等級與此測試，再導入數值。
if grep -Eq 'HP[^\n]*6500|內力[^\n]*12000|宗師境[^\n]*Lv\.30' "$REGISTRY"; then
  echo "M16 Static FAIL：偵測到舊模擬精確數值被寫入 Original 證據登錄表。"
  exit 1
fi

# 猜測路徑只能作為禁止範例，不可標示成已確認 Runtime path。
if grep -Eiq 'CONFIRMED_RUNTIME[^\n]*/d/lengmei/npc/meiyingfeng|/d/lengmei/npc/meiyingfeng[^\n]*CONFIRMED_RUNTIME' "$REGISTRY"; then
  echo "M16 Static FAIL：猜測 NPC path 被誤標為 CONFIRMED_RUNTIME。"
  exit 1
fi

echo "M16 Static PASS：NPC／裝備／物品證據分級與 Original／Expansion 邊界正常。"
