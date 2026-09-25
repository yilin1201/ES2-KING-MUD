#!/usr/bin/env bash
set -euo pipefail

# Targeted Runtime E2E／針對性執行環境端到端測試：重用既有 Neolith binary、
# Game Completion Runtime 與真實 KING fixture；不重新 Clone 或 Build Driver。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
FIXTURE="${2:-$REPO_ROOT/.runtime/game-completion-fixture/king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((46000 + $$ % 1000))"
TEST_PASSWORD="$(openssl rand -hex 16)"
PASSWORD_SALT="$(openssl rand -hex 4)"
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
  rm -rf -- "$TEMP_ROOT"
  return "$status"
}
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"
test -f "$FIXTURE/login/king.o" -a -f "$FIXTURE/user/king.o"

# Isolated Save Data／隔離存檔：只複製既有 Runtime tree，Driver 仍是同一個已建置 binary；
# 測試密碼只存在程序記憶體與暫存檔，絕不寫回 Repository。
cp -a "$RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
mkdir -p "$TEMP_ROOT/mudlib/data/login/k" "$TEMP_ROOT/mudlib/data/user/k" \
  "$TEMP_ROOT/mudlib/data/login/m" "$TEMP_ROOT/mudlib/data/user/m" "$TEMP_ROOT/mudlib/log"
awk -v hash="$PASSWORD_HASH" '/^password / { print "password \"" hash "\""; next } { print }' \
  "$FIXTURE/login/king.o" > "$TEMP_ROOT/mudlib/data/login/k/king.o"
cp "$FIXTURE/user/king.o" "$TEMP_ROOT/mudlib/data/user/k/king.o"
sed -e 's/"id":"king"/"id":"mortal"/' -e 's/"name":"KING"/"name":"MORTAL"/' \
  "$TEMP_ROOT/mudlib/data/login/k/king.o" > "$TEMP_ROOT/mudlib/data/login/m/mortal.o"
sed -e 's/"id":"king"/"id":"mortal"/' -e 's/"name":"KING"/"name":"MORTAL"/' \
  "$FIXTURE/user/king.o" > "$TEMP_ROOT/mudlib/data/user/m/mortal.o"

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
node "$REPO_ROOT/scripts/test_daxie_qisun_runtime_e2e.mjs"

