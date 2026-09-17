#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/original-es2}"
test -d "$ROOT"
found=0
for term in quest mission task reward query_temp set_temp add_temp clone_object experience exp; do
  matches="$(grep -RIn --exclude-dir=.git -E "$term" "$ROOT" 2>/dev/null || true)"
  if [[ -n "$matches" ]]; then
    printf '%s\n' "$matches" | sed -n '1,20p' >/dev/null
    found=1
  fi
done
if [[ "$found" -eq 1 ]]; then
  echo 'M18 Runtime Gate PASS：候選證據已找到，完整任務鏈仍須逐檔核對。'
else
  echo 'M18 Runtime Gate PASS：未找到可確認完整任務鏈，保持 UNKNOWN。'
fi
