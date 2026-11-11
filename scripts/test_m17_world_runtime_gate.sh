#!/usr/bin/env bash
set -euo pipefail

# M17 Runtime Gate（實機證據閘門）：只讀 bootstrap 後的 Original ES2 上游程式樹。\n# 第五階段 5Q：關鍵字或常見 room 結構只代表 Candidate discovery，不可標成完整世界 Runtime PASS。
RUNTIME_ROOT="${1:-.runtime/original-es2}"

if [[ ! -d "$RUNTIME_ROOT" ]]; then
  echo "M17 FAIL：找不到 Runtime tree（實機程式樹）：$RUNTIME_ROOT"
  exit 1
fi

echo "M17 世界區域／房間 Runtime Gate"
echo "Runtime root：$RUNTIME_ROOT"

terms=(
  "lengmei"
  "lunmay"
  "fighter.lunmay"
  "冷梅"
  "雪亭"
  "set(\"exits\""
  "set(\"short\""
  "inherit ROOM"
)

found_world=0
for term in "${terms[@]}"; do
  echo "---- 搜尋：$term"
  matches="$(grep -RInF --exclude-dir=.git -- "$term" "$RUNTIME_ROOT" 2>/dev/null || true)"
  if [[ -n "$matches" ]]; then
    printf '%s\n' "$matches" | head -n 60
    found_world=1
  else
    echo "（公開上游未找到）"
  fi
done

# 列出實際存在的 /d 類區域目錄作為後續地圖盤點入口；沒有 /d 也不視為失敗，因上游結構可能不同。
echo "---- 區域目錄候選"
find "$RUNTIME_ROOT" -maxdepth 3 -type d \( -path '*/d/*' -o -name 'd' \) 2>/dev/null | head -n 100 || true

if [[ "$found_world" -eq 0 ]]; then
  echo "M17 Runtime Gate UNKNOWN：第一批區域關鍵詞與常見房間結構未在目前公開上游找到；地圖與 path 保持 UNKNOWN，不補造。"
else
  echo "M17 Runtime Gate CANDIDATE：找到候選世界／房間證據；需逐檔核對 LPC 的 path、inherit、short、long、exits 與 clone 後才能升級為 CONFIRMED_RUNTIME。"
fi
