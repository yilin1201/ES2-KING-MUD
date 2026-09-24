#!/usr/bin/env bash
set -euo pipefail

# Full Driver Journey／完整驅動器旅程：沿用既有 Neolith、Runtime 與 KING fixture，
# 只在隔離暫存目錄啟動一次真正 Driver，不重新建置或建立第二套永久 Runtime。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
FIXTURE="${2:-$REPO_ROOT/.runtime/game-completion-fixture/king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((45000 + $$ % 1000))"
TEST_PASSWORD="$(openssl rand -hex 16)"
PASSWORD_SALT="$(openssl rand -hex 4)"
# Neolith crypt／Neolith 密碼雜湊：此 Driver 的 MD5 相容格式使用既有 14 字元編碼，
# 不等同系統 openssl passwd；測試 fixture 必須依 Driver 真實演算法產生，才算正常 Original 驗證。
PASSWORD_HASH="$(ES2_HASH_PASSWORD="$TEST_PASSWORD" ES2_HASH_SALT="$PASSWORD_SALT" node -e '
  const crypto = require("crypto");
  const digest = crypto.createHash("md5")
    .update(process.env.ES2_HASH_PASSWORD + process.env.ES2_HASH_SALT).digest();
  const alphabet = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
  let encoded = "";
  for (let i = 0; i < 3; i++) {
    const value = digest[i * 5] | (digest[i * 5 + 1] << 8) | (digest[i * 5 + 2] << 16);
    for (let shift = 0; shift < 24; shift += 6) encoded += alphabet[(value >> shift) & 63];
  }
  encoded += alphabet[digest[15] & 63] + alphabet[(digest[15] >> 6) & 63];
  process.stdout.write(`$1$${process.env.ES2_HASH_SALT}$${encoded}`);
')"
driver_pid=""
bridge_pid=""

cleanup() {
  status=$?
  [[ -z "$bridge_pid" ]] || kill "$bridge_pid" 2>/dev/null || true
  [[ -z "$driver_pid" ]] || kill "$driver_pid" 2>/dev/null || true
  wait "$bridge_pid" 2>/dev/null || true
  wait "$driver_pid" 2>/dev/null || true
  if (( status != 0 )); then
    echo "FULL DRIVER JOURNEY FAIL（測試失敗）：暫存 Runtime 保留於 $TEMP_ROOT" >&2
  else
    rm -rf -- "$TEMP_ROOT"
  fi
  return "$status"
}
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"
test -f "$FIXTURE/login/king.o"
test -f "$FIXTURE/user/king.o"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
mkdir -p "$TEMP_ROOT/mudlib/data/login/k" "$TEMP_ROOT/mudlib/data/user/k" "$TEMP_ROOT/mudlib/log"
cp "$FIXTURE/login/king.o" "$TEMP_ROOT/mudlib/data/login/k/king.o"
cp "$FIXTURE/user/king.o" "$TEMP_ROOT/mudlib/data/user/k/king.o"

# Test Password／測試密碼：只改隔離副本中的 Original crypt 雜湊，讓既有 fixture
# 能經正常 Original Login 驗證；明文只存在本程序記憶體與子程序環境。
awk -v hash="$PASSWORD_HASH" '
  /^password / { print "password \"" hash "\""; next }
  { print }
' "$TEMP_ROOT/mudlib/data/login/k/king.o" > "$TEMP_ROOT/king.login"
mv "$TEMP_ROOT/king.login" "$TEMP_ROOT/mudlib/data/login/k/king.o"

(
  cd "$TEMP_ROOT"
  exec "$DRIVER_BIN" -f neolith.conf
) > "$TEMP_ROOT/driver.stdout" 2>&1 &
driver_pid=$!

ES2_TEST_PORT=4000 node -e '
  const net = require("net");
  const deadline = Date.now() + 30000;
  function probe() {
    const socket = net.createConnection({host:"127.0.0.1", port:Number(process.env.ES2_TEST_PORT)});
    socket.once("connect", () => { socket.destroy(); process.exit(0); });
    socket.once("error", () => { socket.destroy(); Date.now() < deadline ? setTimeout(probe, 100) : process.exit(1); });
  }
  probe();
'

(
  cd "$REPO_ROOT/webtelnet"
  ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs
) > "$TEMP_ROOT/bridge.stdout" 2>&1 &
bridge_pid=$!

ES2_TEST_PORT="$WEB_PORT" node -e '
  const http = require("http");
  const deadline = Date.now() + 10000;
  function probe() {
    http.get({host:"127.0.0.1", port:Number(process.env.ES2_TEST_PORT), path:"/health"}, response => {
      response.resume();
      if (response.statusCode === 200) process.exit(0);
      Date.now() < deadline ? setTimeout(probe, 100) : process.exit(1);
    }).on("error", () => Date.now() < deadline ? setTimeout(probe, 100) : process.exit(1));
  }
  probe();
'

ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" \
ES2_E2E_KING_PASSWORD="$TEST_PASSWORD" \
node "$REPO_ROOT/scripts/test_game_completion_full_driver_e2e.mjs"

echo "FULL DRIVER JOURNEY PASS（測試通過）：NPC、物品／裝備、戰鬥、技能、門派／拜師已由單一 Neolith Session 完成。"
