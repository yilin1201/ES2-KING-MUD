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
persistence_pid=""
stopping=0

cleanup() {
  if [[ -n "$bridge_pid" ]] && kill -0 "$bridge_pid" 2>/dev/null; then
    kill "$bridge_pid" 2>/dev/null || true
    wait "$bridge_pid" 2>/dev/null || true
  fi
  if [[ -n "$driver_pid" ]] && kill -0 "$driver_pid" 2>/dev/null; then
    kill "$driver_pid" 2>/dev/null || true
    wait "$driver_pid" 2>/dev/null || true
  fi
  if [[ -n "$persistence_pid" ]] && kill -0 "$persistence_pid" 2>/dev/null; then
    kill "$persistence_pid" 2>/dev/null || true
    wait "$persistence_pid" 2>/dev/null || true
  fi
  # Final Flush／最後同步：Driver 停止寫入後再保存一次，避免正常 Restart 遺失最後一筆 save。
  bash "$SCRIPT_DIR/sync_es2_persistence.sh" || true
}

graceful_shutdown() {
  stopping=1
  echo "RUNTIME STOP：received platform shutdown signal; performing clean persistence flush." >&2
  cleanup
  exit 0
}

trap cleanup EXIT
trap graceful_shutdown INT TERM

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

# Persistence Sync Loop／持久化同步迴圈：單次 Neon 網路錯誤不殺死同步程序，留下錯誤並持續重試。
(
  while true; do
    sleep "${ES2_PERSISTENCE_SYNC_INTERVAL:-2}"
    if ! bash "$SCRIPT_DIR/sync_es2_persistence.sh"; then
      echo "PERSISTENCE SYNC WARN：durable sync 失敗；將於下一輪重試。" >&2
    fi
  done
) &
persistence_pid=$!

cd "$WEBTELNET_DIR"
node server.mjs &
bridge_pid=$!

# WebSocket Runtime Smoke／WebSocket 執行期煙霧測試：
# 從容器內走與 iPhone 相同的 /mud Bridge 路徑，必須收到 Original ES2 登入提示。
# 不送帳號或密碼，只驗證 Browser-facing WebSocket -> WebTelnet -> Neolith:4000。
node --input-type=module -e '
  import WebSocket from "ws";
  const port = Number(process.env.PORT);
  const deadline = Date.now() + 30000;
  function probe() {
    const ws = new WebSocket(`ws://127.0.0.1:${port}/mud`);
    let output = "";
    const retry = () => {
      try { ws.terminate(); } catch {}
      if (Date.now() >= deadline) {
        console.error("START FAIL：WebSocket /mud 未收到 ES2 登入提示。");
        process.exit(1);
      }
      setTimeout(probe, 300);
    };
    const timer = setTimeout(retry, 2000);
    ws.on("message", data => {
      output += Buffer.from(data).toString("utf8");
      if (/使用者代號|東 方 故 事/.test(output)) {
        clearTimeout(timer);
        console.log("WEBSOCKET RUNTIME PASS：/mud -> WebTelnet -> Neolith:4000 已收到 ES2 登入提示。");
        ws.close();
        process.exit(0);
      }
    });
    ws.on("error", () => { clearTimeout(timer); retry(); });
  }
  probe();
' || { echo "START FAIL：WebSocket Runtime Smoke 未通過。" >&2; exit 1; }

# Process Supervision／程序監督：公開服務存活期間 Driver 與 Bridge 必須同時存在。
# 過去若 Neolith native crash，Bridge 仍可能留在前景而讓 Render 不重啟；
# 現在任一核心程序退出都讓容器失敗退出，由平台依正常服務生命週期重建。
while kill -0 "$driver_pid" 2>/dev/null && kill -0 "$bridge_pid" 2>/dev/null; do
  sleep 1
done

if [[ "$stopping" -eq 1 ]]; then
  exit 0
fi

if ! kill -0 "$driver_pid" 2>/dev/null; then
  echo "RUNTIME FAIL：Neolith process exited unexpectedly; terminating service for clean restart." >&2
  wait "$driver_pid" 2>/dev/null || true
  exit 1
fi

echo "RUNTIME FAIL：WebTelnet bridge exited unexpectedly; terminating service for clean restart." >&2
wait "$bridge_pid" 2>/dev/null || true
exit 1
