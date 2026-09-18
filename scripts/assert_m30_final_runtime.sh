#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${1:-${ES2_RUNTIME_DIR:-/opt/es2-king/runtime}}"
LOGIN_D="$RUNTIME_DIR/mudlib/adm/daemons/logind.c"

test -f "$LOGIN_D" || {
  echo "FINAL RUNTIME ASSERTION FAIL（最終執行環境斷言失敗）：找不到 $LOGIN_D" >&2
  exit 1
}

# Final Runtime Assertion（最終執行環境斷言）：直接檢查 Neolith 即將載入的 logind，
# 不以 Overlay 原始腳本存在作為替代證據。
reservation_block="$(sed -n '/ES2-KING PUBLIC OWNER ID RESERVATION/,/^[[:space:]]*}/p' "$LOGIN_D")"
grep -Fq 'if (arg == "king")' <<<"$reservation_block"
grep -Fq 'ob->delete("id")' <<<"$reservation_block"
grep -Fq 'logon(ob)' <<<"$reservation_block"
grep -Fq '已拒絕公開註冊' <<<"$reservation_block"

if grep -Fq 'destruct(ob)' <<<"$reservation_block"; then
  echo "FINAL RUNTIME ASSERTION FAIL（最終執行環境斷言失敗）：KING 保留路徑仍包含舊版 destruct(ob)。" >&2
  exit 1
fi

echo "FINAL RUNTIME OVERLAY ASSERTION PASS（最終執行環境覆蓋層斷言通過）：新版 KING 保留流程已存在於 Neolith 實際載入的 logind.c。"
