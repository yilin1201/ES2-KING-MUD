#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${ES2_RUNTIME_DIR:-/opt/es2-king/runtime}"
RUNTIME_DATA="$RUNTIME_DIR/mudlib/data"
MARKER="$RUNTIME_DATA/.cleanup_nonking_test_accounts_v1"

test -d "$RUNTIME_DATA" || { echo "ACCOUNT CLEANUP FAIL：找不到 Runtime data：$RUNTIME_DATA" >&2; exit 1; }

# 一次性清理歷史測試帳號。只處理帳號/角色/郵件保存區，不碰世界資料。
# Marker 會跟 Neon snapshot 一起保存，因此後續新玩家不會被此腳本刪除。
if [[ -f "$MARKER" ]]; then
  echo "ACCOUNT CLEANUP SKIP：歷史測試帳號已清理。"
  exit 0
fi

removed=0
for area in login user mail; do
  root="$RUNTIME_DATA/$area"
  [[ -d "$root" ]] || continue
  while IFS= read -r -d '' file; do
    base="$(basename "$file")"
    # KING 是唯一保留的既有帳號；兼容常見 .o / .json 等保存副檔名。
    stem="${base%%.*}"
    if [[ "${stem,,}" == "king" ]]; then
      continue
    fi
    rm -f -- "$file"
    removed=$((removed + 1))
  done < <(find "$root" -type f -print0)
done

touch "$MARKER"
echo "ACCOUNT CLEANUP PASS：保留 KING；已刪除非 KING 歷史帳號檔案數=$removed"
