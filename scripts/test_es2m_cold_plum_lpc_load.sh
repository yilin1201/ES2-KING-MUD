#!/usr/bin/env bash
set -euo pipefail

# ES2M Cold Plum LPC Load Gate／以真正 Neolith 載入新增武學、NPC 強度與五堂鎮 NPC。
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
  /d/wutang/crossroad
do
  grep -Fqx "$obj" "$PRELOAD" || printf '%s\n' "$obj" >> "$PRELOAD"
done

cd "$ROOT"
"$DRIVER" -f neolith.conf -c >"$LOG" 2>&1 &
PID=$!

python3 - "$PID" "$LOG" <<'PY'
import os, socket, sys, time
pid, log = int(sys.argv[1]), sys.argv[2]
for _ in range(60):
    try:
        os.kill(pid, 0)
    except OSError:
        print(open(log, errors="replace").read())
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
    print(open(log, errors="replace").read())
    raise SystemExit("ES2M COLD PLUM LOAD FAIL：60 秒內未監聽 TCP 4000。")
PY

if grep -Eiq 'Error in loading object: /(std/martial_art|daemon/skill/(lunmay|hainmay_force|advance_lunmay|mayin|seven)|daemon/misc/npc_power|std/char/npc|d/wutang/(crossroad|npc/may_yin_fong))|((compile|syntax) error).*(martial_art|lunmay|hainmay_force|advance_lunmay|mayin|seven|npc_power|may_yin_fong|crossroad)' "$LOG"; then
  cat "$LOG"
  echo "ES2M COLD PLUM LOAD FAIL：新增武學、NPC 強度或梅影風發生 LPC 載入錯誤。" >&2
  exit 1
fi

echo "ES2M COLD PLUM LPC LOAD PASS／Neolith 啟動與新版武學、NPC 強度、五堂鎮梅影風載入檢查通過。"
echo "STATUS=LOAD_ONLY; PLAYER_APPRENTICESHIP_AND_COMBAT_E2E_NOT_CLAIMED"
