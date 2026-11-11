#!/usr/bin/env bash
set -euo pipefail

# ES2M Cold Plum + Khome/Mei LPC Load Gate／以真正 Neolith 載入武學、自宅、演武界及梅寒霜。
# 這是編譯／載入驗證，不等同玩家完整拜師、學武或戰鬥 E2E。
ROOT="${1:-.runtime/es2-king}"
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

test -d "$ROOT/mudlib" || { echo "ES2M COLD PLUM LOAD FAIL：缺少 Runtime $ROOT/mudlib" >&2; exit 1; }
DRIVER="$(find "$ROOT/neolith/out" -type f -name neolith -perm -111 | head -n 1)"
test -n "$DRIVER" || { echo "ES2M COLD PLUM LOAD FAIL：找不到已建置的 Neolith Driver" >&2; exit 1; }
DRIVER="$(realpath "$DRIVER")"

PRELOAD="$ROOT/mudlib/adm/etc/preload"
test -f "$PRELOAD" || { echo "ES2M COLD PLUM LOAD FAIL：缺少 preload" >&2; exit 1; }

# 測試只修改 CI 的隔離 Runtime preload，不修改 Repository 或正式存檔。
for obj in \
  /std/martial_art \
  /daemon/skill/lunmay \
  /daemon/skill/hainmay_force \
  /daemon/skill/advance_lunmay \
  /daemon/skill/mayin \
  /daemon/skill/seven \
  /daemon/misc/npc_power \
  /d/wutang/crossroad \
  /cmds/adm/khome \
  /custom/home/room/home_hall \
  /d/king/wuji_realm \
  /d/arena/yanwujie \
  /d/arena/npc/mei_hanshuang
do
  grep -Fqx "$obj" "$PRELOAD" || printf '%s\n' "$obj" >> "$PRELOAD"
done

# Neolith.conf writes DebugLogFile under MudlibDir/LogDir; create it before startup.
mkdir -p "$ROOT/mudlib/log"
: > "$ROOT/mudlib/log/debug.log"
DEBUG_LOG="$(realpath "$ROOT/mudlib/log/debug.log")"

cd "$ROOT"
"$DRIVER" -f neolith.conf >"$LOG" 2>&1 &
PID=$!

python3 - "$PID" "$LOG" "$DEBUG_LOG" <<'PY'
import os, socket, sys, time
pid, log, debug_log = int(sys.argv[1]), sys.argv[2], sys.argv[3]
for _ in range(60):
    try:
        os.kill(pid, 0)
    except OSError:
        for path in (log, debug_log):
            if os.path.exists(path):
                print(open(path, errors="replace").read()[-20000:])
        raise SystemExit("ES2M COLD PLUM LOAD FAIL：Neolith 在監聽前退出。")
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
    for path in (log, debug_log):
        if os.path.exists(path):
            print(open(path, errors="replace").read()[-20000:])
    raise SystemExit("ES2M COLD PLUM LOAD FAIL：60 秒內未監聽 TCP 4000。")
PY

if grep -Eiq 'Error in loading object: /(std/martial_art|daemon/skill/(lunmay|hainmay_force|advance_lunmay|mayin|seven)|daemon/misc/npc_power|std/char/npc|d/wutang/(crossroad|npc/may_yin_fong)|cmds/adm/khome|custom/home/room/home_hall|d/king/wuji_realm|d/arena/(yanwujie|npc/mei_hanshuang))|((compile|syntax) error).*(martial_art|lunmay|hainmay_force|advance_lunmay|mayin|seven|npc_power|may_yin_fong|crossroad|khome|home_hall|wuji_realm|yanwujie|mei_hanshuang)' "$LOG" "$DEBUG_LOG"; then
  cat "$LOG"
  tail -n 200 "$DEBUG_LOG" 2>/dev/null || true
  echo "ES2M COLD PLUM LOAD FAIL：新增武學、NPC 強度或梅影風發生 LPC 載入錯誤。" >&2
  exit 1
fi

echo "ES2M COLD PLUM + KHOME/MEI LPC LOAD PASS／Neolith 已載入新版武學、Khome 指令、家園大廳、無極之境、演武界與梅寒霜 NPC。"
echo "STATUS=LOAD_ONLY; KHOME_INTERACTIVE_AND_MEI_COMBAT_E2E_NOT_CLAIMED"
