#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${ES2_RUNTIME_DIR:-/opt/es2-king/runtime}"
DRIVER_BIN="${ES2_DRIVER_BIN:-/opt/es2-king/bin/neolith}"
WEBTELNET_DIR="${ES2_WEBTELNET_DIR:-/opt/es2-king/webtelnet}"
INTERNAL_PORT="${ES2_PORT:-4001}"
export ES2_HOST="${ES2_HOST:-127.0.0.1}"
export ES2_PORT="$INTERNAL_PORT"
export PORT="${PORT:-8080}"

test -x "$DRIVER_BIN" || { echo "START FAIL：Neolith 不可執行：$DRIVER_BIN" >&2; exit 1; }
test -f "$RUNTIME_DIR/neolith.conf" || { echo "START FAIL：缺少 neolith.conf" >&2; exit 1; }
test -f "$WEBTELNET_DIR/server.mjs" || { echo "START FAIL：缺少 WebSocket/Telnet Bridge" >&2; exit 1; }

# ES2M Port Contract／固定來源連接埠契約：globals.h、neolith.conf 與 Bridge 必須一致。
SOURCE_MUD_PORT="$(awk '$1 == "#define" && $2 == "MUD_PORT" { print $3; exit }' "$RUNTIME_DIR/mudlib/include/globals.h")"
CONFIG_MUD_PORT="$(awk '$1 == "Port" { split($2, p, ":"); print p[1]; exit }' "$RUNTIME_DIR/neolith.conf")"
if [[ ! "$SOURCE_MUD_PORT" =~ ^[0-9]+$ || "$SOURCE_MUD_PORT" != "$CONFIG_MUD_PORT" || "$SOURCE_MUD_PORT" != "$INTERNAL_PORT" ]]; then
  echo "START FAIL：ES2M 連接埠設定不一致（globals.h=$SOURCE_MUD_PORT, neolith.conf=$CONFIG_MUD_PORT, bridge=$INTERNAL_PORT）。" >&2
  exit 1
fi
echo "ES2M_PORT_CONTRACT_PASS: mudlib=$SOURCE_MUD_PORT config=$CONFIG_MUD_PORT bridge=$INTERNAL_PORT"

"$SCRIPT_DIR/prepare_es2_persistence.sh"

# Restart-safe Binary Cache Invalidation：
# Neolith 執行後會重新產生這兩個 .b；同一容器 restart 前必須移除，
# 讓 Startup Assertion 驗證的是目前 Runtime Source，而不是上一次 Boot 的 cache。
rm -f \
  "$RUNTIME_DIR/mudlib/bin/adm/daemons/logind.b" \
  "$RUNTIME_DIR/mudlib/bin/adm/daemons/cmd_d.b"

# Startup Assertion（啟動斷言）：在 Neolith 啟動前再檢查容器最終 mudlib，
# 防止錯誤映像、複製順序或舊 Overlay 讓公開服務退回不安全版本。
bash "$SCRIPT_DIR/assert_m30_final_runtime.sh" "$RUNTIME_DIR"
mkdir -p "$RUNTIME_DIR/mudlib/log"

driver_pid=""
bridge_pid=""
persistence_pid=""
stopping=0
cleanup_done=0

cleanup() {
  if [[ "$cleanup_done" -eq 1 ]]; then
    return
  fi
  cleanup_done=1
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
  # EXIT trap 統一執行一次 cleanup，避免 SIGTERM 路徑重複 Final Flush。
  exit 0
}

trap cleanup EXIT
trap graceful_shutdown INT TERM

# Neolith（MUD 遊戲執行引擎）只供同一容器的 bridge 使用；部署不得映射 MUD Telnet port。
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
# 不送帳號或密碼，只驗證 Browser-facing WebSocket -> WebTelnet -> Neolith:$INTERNAL_PORT。
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
        console.log("WEBSOCKET RUNTIME PASS：/mud -> WebTelnet -> Neolith:$INTERNAL_PORT 已收到 ES2 登入提示。");
        ws.close();
        process.exit(0);
      }
    });
    ws.on("error", () => { clearTimeout(timer); retry(); });
  }
  probe();
' || { echo "START FAIL：WebSocket Runtime Smoke 未通過。" >&2; exit 1; }

# Ordinary Player Session Smoke／普通玩家公開入口等價路徑：
# 只走到「新人物建立確認」後回答 N；不建立帳號、不設定密碼、不寫入正式玩家存檔。
# 這是 localhost deployment gate，不能冒充外部 PUBLIC_PLAYER_SMOKE_PASS。
node "$SCRIPT_DIR/test_public_player_session_smoke.mjs" "http://127.0.0.1:$PORT" \
  || { echo "START FAIL：Ordinary Player Session Smoke 未通過。" >&2; exit 1; }

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
  driver_status=0
  if wait "$driver_pid" 2>/dev/null; then
    driver_status=0
  else
    driver_status=$?
  fi
  # Native Crash Classification／原生程序崩潰分類：
  # POSIX shell 對 signal 終止通常回報 128+signal；例如 SIGABRT=134。
  # 這只增加診斷證據，不把 exit code 本身誤當 root cause。
  if (( driver_status >= 128 && driver_status <= 255 )); then
    driver_signal=$((driver_status - 128))
    echo "RUNTIME FAIL：Neolith process exited unexpectedly (exit=$driver_status, signal=$driver_signal, class=NATIVE_SIGNAL_EXIT); terminating service for clean restart." >&2
  else
    echo "RUNTIME FAIL：Neolith process exited unexpectedly (exit=$driver_status, class=PROCESS_EXIT); terminating service for clean restart." >&2
  fi
  exit 1
fi

bridge_status=0
if wait "$bridge_pid" 2>/dev/null; then
  bridge_status=0
else
  bridge_status=$?
fi
echo "RUNTIME FAIL：WebTelnet bridge exited unexpectedly (exit=$bridge_status); terminating service for clean restart." >&2
exit 1
