#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/m30/.runtime/es2-king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
TELNET_PORT=4000
WEB_PORT="$((43000 + $$ % 1000))"
driver_pid=""
bridge_pid=""

cleanup() {
  status=$?
  if (( status != 0 )); then
    echo 'M30 KING RESERVATION E2E FAIL：Neolith／Bridge 診斷紀錄如下。' >&2
    tail -n 80 "$TEMP_ROOT/mudlib/log/debug.log" 2>/dev/null || true
    tail -n 80 "$TEMP_ROOT/mudlib/log/log" 2>/dev/null || true
  fi
  [[ -z "$bridge_pid" ]] || kill "$bridge_pid" 2>/dev/null || true
  [[ -z "$driver_pid" ]] || kill "$driver_pid" 2>/dev/null || true
  wait "$bridge_pid" 2>/dev/null || true
  wait "$driver_pid" 2>/dev/null || true
  rm -rf -- "$TEMP_ROOT"
  return "$status"
}
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"
test -f "$SOURCE_RUNTIME/neolith.conf"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
# Production-equivalent Assertion／正式部署等效斷言：最終 Runtime 檢查會核對 Neolith Telnet 原始碼；
# 測試沙盒只複製必要的唯讀 comm.c，不另行建置 Driver，也不擴大測試資料範圍。
mkdir -p "$TEMP_ROOT/neolith/src"
cp "$SOURCE_RUNTIME/neolith/src/comm.c" "$TEMP_ROOT/neolith/src/comm.c"

# 每次使用乾淨資料目錄，證明拒絕流程不會偷偷產生 KING 登入或角色存檔。
mkdir -p "$TEMP_ROOT/mudlib/data/login/k" "$TEMP_ROOT/mudlib/data/user/k" "$TEMP_ROOT/mudlib/log"
if [[ "${ES2_E2E_SKIP_OVERLAY:-0}" != "1" ]]; then
  bash "$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"
fi
bash "$REPO_ROOT/scripts/assert_m30_final_runtime.sh" "$TEMP_ROOT"

(
  cd "$TEMP_ROOT"
  exec "$DRIVER_BIN" -f neolith.conf
) &
driver_pid=$!

ES2_TEST_HOST=127.0.0.1 ES2_TEST_PORT="$TELNET_PORT" node -e '
  const net = require("net");
  const deadline = Date.now() + 30000;
  function probe() {
    const socket = net.createConnection({ host: process.env.ES2_TEST_HOST, port: Number(process.env.ES2_TEST_PORT) });
    socket.once("connect", () => { socket.destroy(); process.exit(0); });
    socket.once("error", () => { socket.destroy(); Date.now() < deadline ? setTimeout(probe, 100) : process.exit(1); });
  }
  probe();
'

(
  cd "$REPO_ROOT/webtelnet"
  ES2_HOST=127.0.0.1 ES2_PORT="$TELNET_PORT" PORT="$WEB_PORT" exec node server.mjs
) &
bridge_pid=$!

ES2_TEST_PORT="$WEB_PORT" node -e '
  const http = require("http");
  const deadline = Date.now() + 10000;
  function probe() {
    http.get({ host: "127.0.0.1", port: Number(process.env.ES2_TEST_PORT), path: "/health" }, response => {
      response.resume();
      if (response.statusCode === 200) process.exit(0);
      Date.now() < deadline ? setTimeout(probe, 100) : process.exit(1);
    }).on("error", () => Date.now() < deadline ? setTimeout(probe, 100) : process.exit(1));
  }
  probe();
'

ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" \
ES2_E2E_SAVE_DIR="$TEMP_ROOT/mudlib/data" \
node "$REPO_ROOT/scripts/test_m30_king_reservation_e2e.mjs"
