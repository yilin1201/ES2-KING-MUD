#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${1:-${ES2_RUNTIME_DIR:-/opt/es2-king/runtime}}"
LOGIN_D="$RUNTIME_DIR/mudlib/adm/daemons/logind.c"
COMMAND_D="$RUNTIME_DIR/mudlib/adm/daemons/cmd_d.c"
PRELOAD_FILE="$RUNTIME_DIR/mudlib/adm/etc/preload"

test -f "$LOGIN_D" || {
  echo "FINAL RUNTIME ASSERTION FAIL（最終執行環境斷言失敗）：找不到 $LOGIN_D" >&2
  exit 1
}

# Final Runtime Assertion（最終執行環境斷言）：直接檢查 Neolith 即將載入的 logind，
# 不以 Overlay 原始腳本存在作為替代證據。
reservation_block="$(sed -n '/ES2-KING PUBLIC OWNER ID RESERVATION/,/^    mapping opts =/p' "$LOGIN_D")"
grep -Fq 'if (arg == "king")' <<<"$reservation_block"
grep -Fq 'ob->delete("id")' <<<"$reservation_block"
grep -Fq 'logon(ob)' <<<"$reservation_block"
grep -Fq '已拒絕公開註冊' <<<"$reservation_block"
grep -Fq 'input_to("get_owner_claim", 3, ob)' <<<"$reservation_block"
grep -Fq 'ES2-KING OWNER CLAIM FLOW' "$LOGIN_D"
grep -Fq 'owner_claim_transport_decode(token)' "$LOGIN_D"
grep -Fq 'secure_owner_claim_equal(supplied, secret)' "$LOGIN_D"
grep -Fq 'Claim 安全診斷：' "$LOGIN_D"
grep -Fq '比較=MISMATCH' "$LOGIN_D"
grep -Fq 'envsubst("${ES2_KING_CLAIM_TOKEN:-}")' "$LOGIN_D"
# Public Character Text Input（公開創角文字輸入）必須真的存在於 Neolith 最終載入的 logind。
grep -Fq 'ES2-KING PUBLIC CHARACTER TEXT INPUT' "$LOGIN_D"
test "$(grep -Fc 'input_to ("get_race", 0, ob);' "$LOGIN_D")" -eq 2
! grep -Fq 'input_to ("get_race", ob)' "$LOGIN_D"
! grep -Fq 'callback 的額外參數。\n' "$LOGIN_D"
grep -Fq 'private void get_race (string race, object ob)' "$LOGIN_D"
! grep -Fq 'switch (choice ? choice : race)' "$LOGIN_D"
grep -Fq 'case "1":' "$LOGIN_D"
grep -Fq 'case "human":' "$LOGIN_D"
grep -Fq 'case "2":' "$LOGIN_D"
grep -Fq 'case "avatar":' "$LOGIN_D"
grep -Fq '請輸入編號 1 或 2' "$LOGIN_D"
grep -Fq 'ES2-KING OWNER COMMAND REHASH' "$COMMAND_D"
for command in kingcreate kingrealm kingmartial kingcanon; do
  grep -Fqx "/cmds/adm/$command" "$PRELOAD_FILE"
done
test ! -e "$RUNTIME_DIR/mudlib/bin/adm/daemons/logind.b"
test ! -e "$RUNTIME_DIR/mudlib/bin/adm/daemons/cmd_d.b"

if grep -Fq 'destruct(ob)' <<<"$reservation_block"; then
  echo "FINAL RUNTIME ASSERTION FAIL（最終執行環境斷言失敗）：KING 保留路徑仍包含舊版 destruct(ob)。" >&2
  exit 1
fi

echo "FINAL RUNTIME OVERLAY ASSERTION PASS（最終執行環境覆蓋層斷言通過）：新版 KING 保留流程與 Public Race Text 相容層已存在於 Neolith 實際載入的 logind.c。"
