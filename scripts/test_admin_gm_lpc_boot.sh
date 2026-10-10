#!/usr/bin/env bash
set -euo pipefail

# ADMIN GM LPC Load Gate／使用真實 Neolith Driver 啟動生成 Runtime，
# 讓 preload 實際載入 /cmds/adm/admin；只檢查編譯／載入與服務啟動，不冒充玩家指令 E2E。
ROOT="${1:-.runtime/es2-king}"
LOG="$(mktemp)"
DRIVER=""
PID=""

cleanup() {
  if [[ -n "$PID" ]] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
  fi
  rm -f "$LOG"
}
trap cleanup EXIT

test -d "$ROOT/mudlib" || { echo "ADMIN GM LPC LOAD FAIL：缺少生成 Runtime $ROOT/mudlib" >&2; exit 1; }
test -f "$ROOT/mudlib/cmds/adm/admin.c" || { echo "ADMIN GM LPC LOAD FAIL：缺少 admin.c" >&2; exit 1; }
test -f "$ROOT/mudlib/adm/etc/preload" || { echo "ADMIN GM LPC LOAD FAIL：缺少 preload" >&2; exit 1; }
grep -Fqx '/cmds/adm/admin' "$ROOT/mudlib/adm/etc/preload" || {
  echo "ADMIN GM LPC LOAD FAIL：admin 未加入 preload" >&2; exit 1;
}

DRIVER="$(find "$ROOT/neolith/out" -type f -name neolith -perm -111 | head -n 1)"
test -n "$DRIVER" || { echo "ADMIN GM LPC LOAD FAIL：找不到已建置的 Neolith Driver" >&2; exit 1; }
# 轉成絕對路徑，再切換到 Runtime 根目錄，避免相對路徑被重複拼接。
DRIVER="$(realpath "$DRIVER")"

cd "$ROOT"
"$DRIVER" -f neolith.conf -c >"$LOG" 2>&1 &
PID=$!

# Wait for the actual TCP listener; a live process alone does not prove boot completed.
python3 - "$PID" "$LOG" <<'PY'
import os, socket, sys, time
pid, log = int(sys.argv[1]), sys.argv[2]
for _ in range(45):
    try:
        os.kill(pid, 0)
    except OSError:
        print(open(log, errors="replace").read())
        raise SystemExit("ADMIN GM LPC LOAD FAIL：Neolith 在開啟服務前退出。")
    sock = socket.socket()
    sock.settimeout(0.5)
    try:
        sock.connect(("127.0.0.1", 4000))
        sock.close()
        break
    except OSError:
        sock.close()
        time.sleep(1)
else:
    print(open(log, errors="replace").read())
    raise SystemExit("ADMIN GM LPC LOAD FAIL：45 秒內未監聽 TCP 4000。")
PY

# Neolith may continue boot after a preload compile error, so inspect the boot log explicitly.
if grep -Eiq 'Error in loading object: /cmds/adm/admin|/cmds/adm/admin(\.c)?.*(compile error|syntax error|failed to load)|admin\.c.*(compile error|syntax error)' "$LOG"; then
  cat "$LOG"
  echo "ADMIN GM LPC LOAD FAIL：admin.c 發生 LPC 編譯／載入錯誤。" >&2
  exit 1
fi

echo "ADMIN GM LPC LOAD PASS／Neolith 已啟動且未偵測到 admin.c 預載編譯／載入錯誤。"
