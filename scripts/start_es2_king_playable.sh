#!/usr/bin/env bash
set -euo pipefail

# Browser Playable Start／瀏覽器可玩啟動：重用既有 Neolith、Mudlib、WebTelnet 與 Bridge，
# 不重新 Clone、Build 或建立另一套 Runtime。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME="${ES2_RUNTIME:-$REPO_ROOT/.runtime/game-completion-runtime}"
WEBTELNET_DIR="${ES2_WEBTELNET_DIR:-$REPO_ROOT/webtelnet}"
MUD_PORT="${ES2_PORT:-4000}"
WEB_PORT="${PORT:-${WEBTELNET_PORT:-8080}}"
BRIDGE_PID_FILE="$RUNTIME/.es2-king-webtelnet.pid"
BRIDGE_LOG="$RUNTIME/mudlib/log/es2-king-webtelnet.stdout"
driver_started=0
bridge_pid=""

fail() {
    echo "ES2-KING PLAYABLE FAIL（瀏覽器入口啟動失敗）：$*" >&2
    [[ -f "$BRIDGE_LOG" ]] && tail -30 "$BRIDGE_LOG" >&2 || true
    exit 1
}

port_listening() {
    local port="$1"
    ss -H -ltn "sport = :$port" 2>/dev/null | grep -q "LISTEN"
}

cleanup() {
    if [[ -n "$bridge_pid" ]] && kill -0 "$bridge_pid" 2>/dev/null; then
        kill "$bridge_pid" 2>/dev/null || true
        wait "$bridge_pid" 2>/dev/null || true
    fi
    if (( driver_started )) && [[ -f "$RUNTIME/.es2-king-driver.pid" ]]; then
        driver_pid="$(sed -n '1p' "$RUNTIME/.es2-king-driver.pid")"
        kill "$driver_pid" 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

command -v ss >/dev/null 2>&1 || fail "缺少被動 Port 檢查工具 ss。"
command -v node >/dev/null 2>&1 || fail "缺少 WebSocket Bridge 所需 Node.js。"
[[ -f "$WEBTELNET_DIR/server.mjs" ]] || fail "找不到既有 WebSocket Bridge。"
[[ -f "$WEBTELNET_DIR/public/index.html" ]] || fail "找不到既有 Web MUD Client。"
[[ -d "$WEBTELNET_DIR/node_modules/ws" ]] || fail "找不到既有 ws 模組；本腳本不會自行下載相依套件。"
mkdir -p "$RUNTIME/mudlib/log"

if ! port_listening "$MUD_PORT"; then
    driver_started=1
    ES2_RUNTIME="$RUNTIME" ES2_PORT="$MUD_PORT" bash "$REPO_ROOT/scripts/start_es2_king.sh"
fi
port_listening "$MUD_PORT" || fail "Neolith TCP $MUD_PORT 未進入 LISTENING（監聽）狀態。"

if port_listening "$WEB_PORT"; then
    fail "Web Port $WEB_PORT 已被其他程序使用。"
fi

(
    cd "$WEBTELNET_DIR"
    ES2_HOST=127.0.0.1 ES2_PORT="$MUD_PORT" PORT="$WEB_PORT" \
        exec node server.mjs
) >"$BRIDGE_LOG" 2>&1 &
bridge_pid=$!
echo "$bridge_pid" > "$BRIDGE_PID_FILE"

stable_checks=0
for _ in $(seq 1 100); do
    kill -0 "$bridge_pid" 2>/dev/null || break
    if port_listening "$WEB_PORT"; then
        stable_checks=$((stable_checks + 1))
    else
        stable_checks=0
    fi
    if (( stable_checks >= 5 )); then
        cat <<READY
================================
ES2-KING PLAYABLE READY
================================
Driver: READY
TCP 4000: READY
WebSocket Bridge: READY
Web Client: READY

Local Browser Entry:
http://127.0.0.1:$WEB_PORT
================================
READY
        # Supervisor／監督程序：保持 Bridge 與 Driver 所在工作階段存活；Ctrl+C 可安全停止本輪服務。
        wait "$bridge_pid"
        exit $?
    fi
    sleep 0.1
done

fail "WebSocket Bridge 未能在 Web Port $WEB_PORT 穩定啟動。"
