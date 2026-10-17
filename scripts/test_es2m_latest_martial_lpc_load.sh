#!/usr/bin/env bash
set -euo pipefail

# ES2M 最新虎刀門武學 LPC Load Gate／真實 Neolith 載入狻猊步法、三門刀法、瘋虎功與高慎。
# 此測試只在隔離 Runtime preload 加入檢查物件，不改寫 Repository 或正式玩家存檔。
ROOT="${1:-/opt/es2-king/runtime}"
LOG="$(mktemp)"
PID=""

cleanup() {
  if [[ -n "$PID" ]] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
  fi
  rm -f "$LOG"
}
trap cleanup EXIT

test -d "$ROOT/mudlib" || { echo "ES2M MARTIAL LOAD FAIL：缺少 Runtime $ROOT/mudlib" >&2; exit 1; }
DRIVER="${ES2_DRIVER_BIN:-}"
if [[ -z "$DRIVER" ]]; then
  DRIVER="$(find "$ROOT/neolith/out" -type f -name neolith -perm -111 | head -n 1)"
fi
test -n "$DRIVER" && test -x "$DRIVER" || { echo "ES2M MARTIAL LOAD FAIL：找不到可執行 Neolith Driver" >&2; exit 1; }
DRIVER="$(realpath "$DRIVER")"

PRELOAD="$ROOT/mudlib/adm/etc/preload"
test -f "$PRELOAD" || { echo "ES2M MARTIAL LOAD FAIL：缺少 preload" >&2; exit 1; }

for obj in \
  /daemon/skill/tiger-steps \
  /daemon/skill/sanmeendo \
  /daemon/skill/tiger-force \
  /d/oldpine/npc/kao_shen
do
  grep -Fqx "$obj" "$PRELOAD" || printf '%s\n' "$obj" >> "$PRELOAD"
done

# ES2M Port Contract／從實際 mudlib 與 Driver config 讀取連接埠，避免固定使用 Original 的 4000。
MUD_PORT="$(awk '$1 == "#define" && $2 == "MUD_PORT" { print $3; exit }' "$ROOT/mudlib/include/globals.h")"
CONFIG_PORT="$(awk '$1 == "Port" { split($2, p, ":"); print p[1]; exit }' "$ROOT/neolith.conf")"
if [[ ! "$MUD_PORT" =~ ^[0-9]+$ || "$CONFIG_PORT" != "$MUD_PORT" ]]; then
  echo "ES2M MARTIAL LOAD BLOCKED：連接埠不一致（globals.h=$MUD_PORT, neolith.conf=$CONFIG_PORT）。" >&2
  exit 1
fi

cd "$ROOT"
"$DRIVER" -f neolith.conf -c >"$LOG" 2>&1 &
PID=$!

python3 - "$PID" "$LOG" "$MUD_PORT" <<'PY'
import os, socket, sys, time
pid, log, port = int(sys.argv[1]), sys.argv[2], int(sys.argv[3])
for _ in range(60):
    try:
        os.kill(pid, 0)
    except OSError:
        print(open(log, errors="replace").read())
        raise SystemExit("ES2M MARTIAL LOAD FAIL：Neolith 在監聽前退出。")
    sock = socket.socket()
    sock.settimeout(0.5)
    try:
        sock.connect(("127.0.0.1", port))
        sock.close()
        break
    except OSError:
        sock.close()
        time.sleep(1)
else:
    print(open(log, errors="replace").read())
    raise SystemExit(f"ES2M MARTIAL LOAD FAIL：60 秒內未監聽 TCP {port}。")
PY

if grep -Eiq 'Error in loading object: /(daemon/skill/(tiger-steps|sanmeendo|tiger-force)|d/oldpine/npc/kao_shen)|((compile|syntax) error).*(tiger-steps|sanmeendo|tiger-force|kao_shen)' "$LOG"; then
  cat "$LOG"
  echo "ES2M MARTIAL LOAD FAIL：最新虎刀門技能或高慎發生 LPC 載入錯誤。" >&2
  exit 1
fi

echo "ES2M LATEST MARTIAL LPC LOAD PASS／Neolith 啟動並載入狻猊步法、三門刀法、瘋虎功及高慎。"
echo "STATUS=LOAD_ONLY; PLAYER_TRAINING_AND_COMBAT_E2E_NOT_CLAIMED"
