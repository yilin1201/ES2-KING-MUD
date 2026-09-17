#!/usr/bin/env bash
set -euo pipefail

# Runtime Gate（實機證據閘門）：搜尋 Original ES2 任務程式候選，不自行判定不存在的規格。
ROOT="${1:-.runtime/original-es2}"
[[ -d "$ROOT" ]] || { echo "M18 FAIL：找不到 Runtime tree：$ROOT"; exit 1; }

terms=("quest" "mission" "task" "reward" "query_temp" "set_temp" "add_temp" "clone_object" "experience" "exp")
found=0

echo "M18 任務系統 Runtime Gate"
for term in "${terms[@]}"; do
  echo "---- 搜尋：$term"
  matches="$(grep -RIn --exclude-dir=.git -E "$term" "$ROOT" 2>/dev/null || true)"
  if [[ -n "$matches" ]]; then
    printf '%s\n' "$matches" | head -n 80
    found=1
  else
    echo "（公開上游未找到）"
  fi
done

echo "---- 任務相關檔名候選"
find "$ROOT" -type f \( -iname '*quest*' -o -iname '*mission*' -o -iname '*task*' \) -print 2>/dev/null | head -n 100 || true

if [[ "$found" -eq 1 ]]; then
  echo "M18 Runtime Gate PASS：找到任務／進度／獎勵候選證據；需逐檔核對完整任務鏈後才能標為 CONFIRMED_RUNTIME。"
else
  echo "M18 Runtime Gate PASS：目前公開上游未找到可直接確認的任務系統關鍵證據；保持 UNKNOWN，不補造。"
fi
