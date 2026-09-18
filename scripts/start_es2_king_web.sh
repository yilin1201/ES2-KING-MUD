#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${ES2_RUNTIME_DIR:-/opt/es2-king/runtime}"
DRIVER_BIN="${ES2_DRIVER_BIN:-/opt/es2-king/bin/neolith}"
WEBTELNET_DIR="${ES2_WEBTELNET_DIR:-/opt/es2-king/webtelnet}"
INTERNAL_PORT="${ES2_PORT:-4000}"
export ES2_HOST="${ES2_HOST:-127.0.0.1}"
export ES2_PORT="$INTERNAL_PORT"
export PORT="${PORT:-8080}"

test -x "$DRIVER_BIN" || { echo "START FAIL：Neolith 不可執行：$DRIVER_BIN" >&2; exit 1; }
test -f "$RUNTIME_DIR/neolith.conf" || { echo "START FAIL：缺少 neolith.conf" >&2; exit 1; }
test -f "$WEBTELNET_DIR/server.mjs" || { echo "START FAIL：缺少 WebSocket/Telnet Bridge" >&2; exit 1; }

"$SCRIPT_DIR/prepare_es2_persistence.sh"
# Startup Assertion（啟動斷言）：在 Neolith 啟動前再檢查容器最終 mudlib，
# 防止錯誤映像、複製順序或舊 Overlay 讓公開服務退回不安全版本。
bash "$SCRIPT_DIR/assert_m30_final_runtime.sh" "$RUNTIME_DIR"
mkdir -p "$RUNTIME_DIR/mudlib/log"

driver_pid=""
bridge_pid=""
cleanup() {
  if [[ -n "$bridge_pid" ]] && kill -0 "$bridge_pid" 2>/dev/null; then
    kill "$bridge_pid" 2>/dev/null || true
    wait "$bridge_pid" 2>/dev/null || true
  fi
  if [[ -n "$driver_pid" ]] && kill -0 "$driver_pid" 2>/dev/null; then
    kill "$driver_pid" 2>/dev/null || true
    wait "$driver_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

# Neolith（MUD 遊戲執行引擎）只供同一容器的 bridge 使用；部署不得映射 4000。
(
  cd "$RUNTIME_DIR"
  exec "$DRIVER_BIN" -f neolith.conf
) &
driver_pid=$!

# 等待真實 Telnet listener，不用固定 sleep 冒充啟動完成。
node -e '
  const net = require("net");
  const host = process.env.ES2_HOST;
  const port = Number(process.env.ES2_PORT);
  const deadline = Date.now() + 60000;
  function probe() {
    const socket = net.createConnection({ host, port });
    socket.setTimeout(1000);
    socket.once("connect", () => { socket.destroy(); process.exit(0); });
    const retry = () => { socket.destroy(); Date.now() < deadline ? setTimeout(probe, 250) : process.exit(1); };
    socket.once("error", retry);
    socket.once("timeout", retry);
  }
  probe();
' || { echo "START FAIL：Neolith ${ES2_HOST}:${ES2_PORT} 未在 60 秒內啟動。" >&2; exit 1; }

cd "$WEBTELNET_DIR"
node server.mjs &
bridge_pid=$!
wait "$bridge_pid"
