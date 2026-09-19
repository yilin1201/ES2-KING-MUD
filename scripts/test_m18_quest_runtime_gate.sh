#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/original-es2}"
test -d "$ROOT"
# 第五階段 5M：關鍵字搜尋只能做 Candidate discovery（候選發現），不可冒充完整 Runtime PASS。\nfound=0
for term in quest mission task reward query_temp set_temp add_temp clone_object experience exp; do
  matches="$(grep -RIn --exclude-dir=.git -E "$term" "$ROOT" 2>/dev/null || true)"
  if [[ -n "$matches" ]]; then
    printf '%s\n' "$matches" | sed -n '1,20p' >/dev/null
    found=1
  fi
done
if [[ "$found" -eq 1 ]]; then
  echo 'M18 Runtime Gate CANDIDATE：找到任務相關關鍵字；此結果只代表候選證據存在，不代表完整任務鏈 PASS。'
else
  echo 'M18 Runtime Gate UNKNOWN：未找到可確認完整任務鏈，保持 UNKNOWN。'
fi
