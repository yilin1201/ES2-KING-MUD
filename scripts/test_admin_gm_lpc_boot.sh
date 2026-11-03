#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.runtime/es2-king}"
ROOT="$(cd "$ROOT" && pwd)"
LOG="$(mktemp)"
DEBUG_LOG="$ROOT/mudlib/log/debug.log"
COMPILE_LOG="$ROOT/mudlib/log/log"
DRIVER=""
PID=""

cleanup() {
  local status=$?
  if [[ $status -ne 0 ]]; then
    echo '---- ADMIN GM Neolith stdout/stderr ----' >&2
    tail -n 120 "$LOG" 2>/dev/null || true
    for path in "$DEBUG_LOG" "$COMPILE_LOG"; do
      if [[ -f "$path" ]]; then
        echo "---- ADMIN GM LPC log: $path ----" >&2
        tail -n 200 "$path" 2>/dev/null || true
      fi
    done
  fi
  if [[ -n "$PID" ]] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
  fi
  rm -f "$LOG"
}
trap cleanup EXIT

mkdir -p "$ROOT/mudlib/log"
: > "$DEBUG_LOG"
DRIVER="$(find "$ROOT/neolith/out" -type f -name neolith -perm -111 | head -n 1)"
[[ -n "$DRIVER" && -x "$DRIVER" ]] || { echo 'ADMIN GM LPC LOAD FAIL：找不到 Neolith Driver。' >&2; exit 1; }

# Load-only gate: production clients connect through WebTelnet/RealIPD; direct Telnet is not a valid E2E path.
PRELOAD="$ROOT/mudlib/adm/etc/preload"
grep -Fqx '/cmds/adm/admin' "$PRELOAD" || echo '/cmds/adm/admin' >> "$PRELOAD"

cd "$ROOT"
"$DRIVER" -f neolith.conf >"$LOG" 2>&1 &
PID=$!

python3 - "$PID" <<'PY'
import os, socket, sys, time
pid = int(sys.argv[1])
deadline = time.time() + 45
while time.time() < deadline:
    try:
        os.kill(pid, 0)
    except OSError:
        raise SystemExit('ADMIN GM LPC LOAD FAIL：Neolith 在啟動期間退出。')
    with socket.socket() as sock:
        sock.settimeout(0.5)
        if sock.connect_ex(('127.0.0.1', 4000)) == 0:
            raise SystemExit(0)
    time.sleep(0.25)
raise SystemExit('ADMIN GM LPC LOAD FAIL：45 秒內未監聽 TCP 4000。')
PY

if grep -Eiq "Error in loading object.*cmds/adm/admin|admin\.c.*(compile error|syntax error)|String too long" "$LOG" "$DEBUG_LOG" "$COMPILE_LOG" 2>/dev/null; then
  echo 'ADMIN GM LPC LOAD FAIL：admin.c 發生 LPC 編譯／載入錯誤。' >&2
  exit 1
fi

if ! grep -Fq 'preloaded cmds/adm/admin' "$DEBUG_LOG"; then
  echo 'ADMIN GM LPC LOAD FAIL：debug.log 未確認 admin command 成功 preload。' >&2
  exit 1
fi

echo 'ADMIN GM LPC LOAD PASS／admin.c 已由 Neolith 成功編譯並載入。'
