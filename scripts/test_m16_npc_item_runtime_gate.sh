#!/usr/bin/env bash
set -euo pipefail

# M16 Runtime Gate（實機證據閘門）：\n# 第五階段 5S：搜尋結果只分 UNKNOWN／CANDIDATE；候選證據不得標成完整 Runtime PASS。
# 只檢查 bootstrap 後的乾淨 Original ES2 上游程式樹，不把 ES2-KING 擴充資料當成 Original 證據。
RUNTIME_ROOT="${1:-.runtime/original-es2}"

if [[ ! -d "$RUNTIME_ROOT" ]]; then
  echo "M16 FAIL：找不到 Runtime tree（實機程式樹）：$RUNTIME_ROOT"
  exit 1
fi

echo "M16 NPC／裝備／物品 Runtime Gate"
echo "Runtime root：$RUNTIME_ROOT"

# 搜尋詞包含已考證的中英文名稱與歷史 class route（職業／門派路徑）。
terms=(
  "May yin fong"
  "mei_yingfeng"
  "fighter.lunmay"
  "lengmei"
  "lunmay"
  "梅影風"
  "劉乙忘玄"
  "寒霜劍"
  "冰雪匕"
  "銀霜鎧"
  "奔雲靴"
  "梅花白襖"
  "流雲清玉帶"
  "白玉戒指"
)

found=0
for term in "${terms[@]}"; do
  echo "---- 搜尋：$term"
  matches="$(grep -RInF --exclude-dir=.git -- "$term" "$RUNTIME_ROOT" 2>/dev/null || true)"
  if [[ -n "$matches" ]]; then
    printf '%s\n' "$matches" | head -n 40
    found=1
  else
    echo "（公開上游未找到）"
  fi
done

if [[ "$found" -eq 0 ]]; then
  echo "M16 Runtime Gate UNKNOWN：第一批 NPC／裝備／物品在目前公開上游未找到可確認 Runtime source；精確 path、HP、技能等級與裝備屬性保持 UNKNOWN，不補造。"
else
  echo "M16 Runtime Gate CANDIDATE：找到候選 Original Runtime 證據；需逐檔核對 LPC（Lars Pensjö C，傳統 MUD 程式語言）內容後才可升級為 CONFIRMED_RUNTIME。"
fi
