#!/usr/bin/env bash
set -euo pipefail

# One-command Start／一鍵啟動：只使用既有 Runtime、Mudlib 與 Neolith binary，
# 不執行 Clone、Build、GitHub Actions、Render 或任何付費服務。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME="${ES2_RUNTIME:-$REPO_ROOT/.runtime/game-completion-runtime}"
DRIVER="${ES2_DRIVER_BIN:-$RUNTIME/neolith/out/build/linux/src/Debug/neolith}"
CONFIG="${ES2_CONFIG:-$RUNTIME/neolith.conf}"
PORT="${ES2_PORT:-4000}"
PID_FILE="$RUNTIME/.es2-king-driver.pid"
STDOUT_LOG="$RUNTIME/mudlib/log/es2-king-driver.stdout"

fail() {
    echo "ES2-KING DRIVER FAIL（啟動失敗）：$*" >&2
    exit 1
}

port_listening() {
    # Passive Listen Check／被動監聽檢查：不可用「連上後立即斷線」探測，
    # 否則舊 Neolith 會在尚未寫完登入畫面時收到 SIGPIPE 並結束。
    ss -H -ltn "sport = :$PORT" 2>/dev/null | grep -q "LISTEN"
}

test -d "$RUNTIME/mudlib" || fail "找不到既有 Mudlib：$RUNTIME/mudlib"
test -x "$DRIVER" || fail "找不到既有 Neolith binary：$DRIVER"
test -f "$CONFIG" || fail "找不到 Neolith config：$CONFIG"
command -v ss >/dev/null 2>&1 || fail "缺少用於被動 Port 監聽檢查的 ss。"
mkdir -p "$RUNTIME/mudlib/log"

if port_listening; then
    echo "ES2-KING DRIVER READY（遊戲引擎已就緒）"
    echo "Telnet 127.0.0.1:$PORT"
    exit 0
fi

rm -f "$PID_FILE"

(
    cd "$RUNTIME"
    # Detached Process／分離程序：避免啟動命令結束時連帶關閉遊戲引擎。
    setsid "$DRIVER" -f "$CONFIG" </dev/null > "$STDOUT_LOG" 2>&1 &
    echo $! > "$PID_FILE"
)

stable_checks=0
for _ in $(seq 1 100); do
    pid="$(cat "$PID_FILE")"
    if ! kill -0 "$pid" 2>/dev/null; then
        break
    fi
    if port_listening; then
        stable_checks=$((stable_checks + 1))
    else
        stable_checks=0
    fi
    # 同時確認程序與監聽狀態連續穩定，防止短暫啟動造成假 PASS。
    if (( stable_checks >= 5 )); then
        echo "ES2-KING DRIVER READY（遊戲引擎已就緒）"
        echo "Telnet 127.0.0.1:$PORT"
        exit 0
    fi
    sleep 0.1
done

if [[ -f "$PID_FILE" ]]; then
    pid="$(cat "$PID_FILE")"
    kill "$pid" 2>/dev/null || true
fi
echo "最近啟動紀錄：" >&2
tail -30 "$STDOUT_LOG" >&2 2>/dev/null || true
fail "Port $PORT 未進入 LISTENING（監聽）狀態。"
