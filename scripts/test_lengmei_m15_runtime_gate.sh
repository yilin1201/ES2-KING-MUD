#!/usr/bin/env bash
set -euo pipefail

# M15 Runtime Gate／實機證據閘門：先確認公開 Original ES2 上游是否真的保存冷梅莊／梅影風可執行 LPC。
RUNTIME_ROOT="${1:-.runtime/original-es2}"
MUDLIB="$RUNTIME_ROOT/mudlib"

if [[ ! -d "$MUDLIB" ]]; then
  echo "ERROR：找不到已 Bootstrap（啟動準備）的 Original ES2 Mudlib：$MUDLIB" >&2
  exit 1
fi

# Search tokens／搜尋識別字：同時查歷史職業代碼、英文顯示名與常見羅馬化路徑字串，避免只用中文檔名造成漏查。
TOKENS=("fighter.lunmay" "May yin fong" "mei_yingfeng" "lengmei" "lunmay")
FOUND=0
REPORT=".runtime/m15-lengmei-evidence.txt"
: > "$REPORT"

for token in "${TOKENS[@]}"; do
  echo "===== $token =====" >> "$REPORT"
  # grep 回傳 1 代表沒有符合項目；這是有效的證據結果，不應讓整個測試誤判 FAIL。
  if grep -RIn --exclude-dir=.git --include='*.c' --include='*.h' --include='*.md' --include='*.txt' "$token" "$MUDLIB" >> "$REPORT" 2>/dev/null; then
    FOUND=1
  else
    echo "（公開上游未找到）" >> "$REPORT"
  fi
  echo >> "$REPORT"
done

if [[ "$FOUND" -eq 1 ]]; then
  echo "M15 Runtime Gate PASS：公開上游找到冷梅莊／梅影風相關字串；需依報告逐筆確認是否為 Original 可執行 LPC 證據。"
else
  echo "M15 Runtime Gate PASS：目前公開上游未找到冷梅莊／梅影風可確認 Runtime source；保持 NPC path、HP、技能等級未知，不補造。"
fi

cat "$REPORT"
