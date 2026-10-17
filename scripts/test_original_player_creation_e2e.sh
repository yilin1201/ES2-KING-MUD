#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((49000 + $$ % 700))"
TEST_PASSWORD="$(openssl rand -hex 16)"
driver_pid=""; bridge_pid=""
cleanup(){
  status=$?
  if ((status)); then
    echo "ORIGINAL PLAYER CREATION E2E FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2
    for log in "$TEMP_ROOT/driver.stdout" "$TEMP_ROOT/bridge.stdout" "$TEMP_ROOT/player-creation.log"; do
      if [[ -r "$log" ]]; then
        echo "----- 診斷日誌：$log（最後 100 行）-----" >&2
        tail -n 100 "$log" >&2 || true
      fi
    done
    if [[ -n "$driver_pid" ]]; then
      if kill -0 "$driver_pid" 2>/dev/null; then
        echo "診斷：Neolith driver process still alive at E2E failure (pid=$driver_pid)." >&2
      else
        echo "診斷：Neolith driver process exited before E2E completed." >&2
      fi
    fi
    if [[ -d "$TEMP_ROOT/mudlib/log" ]]; then
      while IFS= read -r -d '' log; do
        echo "----- MUD Runtime log：$log（最後 80 行）-----" >&2
        tail -n 80 "$log" >&2 || true
      done < <(find "$TEMP_ROOT/mudlib/log" -maxdepth 2 -type f -print0)
    fi
    find "$TEMP_ROOT" -maxdepth 2 -type f -name 'core*' -printf '診斷：core dump file %p (%s bytes)\\n' >&2 || true
  fi
  [[ -z "$bridge_pid" ]] || kill "$bridge_pid" 2>/dev/null || true
  [[ -z "$driver_pid" ]] || kill "$driver_pid" 2>/dev/null || true
  wait "$bridge_pid" 2>/dev/null || true
  wait "$driver_pid" 2>/dev/null || true
  if ((status == 0)); then rm -rf -- "$TEMP_ROOT"; fi
  return "$status"
}
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"

# ES2M Port Contract／依實際 mudlib globals.h 核對 Driver 設定，避免 4000/4001 混用。
MUD_PORT="$(awk '$1 == "#define" && $2 == "MUD_PORT" { print $3; exit }' "$TEMP_ROOT/mudlib/include/globals.h")"
CONFIG_PORT="$(awk '$1 == "Port" { split($2, p, ":"); print p[1]; exit }' "$TEMP_ROOT/neolith.conf")"
if [[ ! "$MUD_PORT" =~ ^[0-9]+$ || "$CONFIG_PORT" != "$MUD_PORT" ]]; then
  echo "ORIGINAL PLAYER CREATION E2E BLOCKED：連接埠不一致（globals.h=$MUD_PORT, neolith.conf=$CONFIG_PORT）。" >&2
  exit 1
fi
PORT_HEX="$(printf '%04X' "$MUD_PORT")"
echo "ES2M_E2E_PORT_CONTRACT_PASS: mudlib=$MUD_PORT config=$CONFIG_PORT"
# Docker passes a runtime that already received both overlays. Reapplying the expansion
# to that generated runtime can collide with deliberately protected NPC/world files.
# Local callers keep the default behavior and build the overlays in the isolated temp runtime.
if [[ "${ES2_RUNTIME_ALREADY_OVERLAID:-0}" == "1" ]]; then
  echo "PLAYER CREATION E2E: using pre-overlaid source Runtime; skipped duplicate overlay application."
else
  bash "$REPO_ROOT/scripts/apply_race_phase2_runtime.sh" "$TEMP_ROOT"
  bash "$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"
fi
# Test-only Host Throttle／測試專用主機限流處理：12 個種族皆由同一個 localhost 建立，
# 會觸發 Original ES2 的每 IP 十帳號保護。只在 mktemp Runtime 套用既有 KING
# bootstrap 政策，不修改來源保存區，也不把「同 IP 大量創角」宣稱為正式 Gameplay。
# No-match is normal: avoid set -e/pipefail abort when antispam is already disabled.
# Preserve real grep errors (status > 1) instead of silently bypassing the gate.
if grep -RIl '^[[:space:]]*#define[[:space:]]\+ENABLE_ANTISPAM' \
  "$TEMP_ROOT/mudlib/include" "$TEMP_ROOT/mudlib/adm" > "$TEMP_ROOT/antispam-files" 2>"$TEMP_ROOT/antispam-grep.stderr"; then
  while IFS= read -r file; do
    sed -i 's/^[[:space:]]*#define[[:space:]]\+ENABLE_ANTISPAM.*/\/\/ ES2-KING isolated test: ENABLE_ANTISPAM disabled/' "$file"
  done < "$TEMP_ROOT/antispam-files"
else
  grep_status=$?
  if (( grep_status != 1 )); then
    cat "$TEMP_ROOT/antispam-grep.stderr" >&2
    echo 'ORIGINAL PLAYER CREATION E2E BLOCKED：無法確認測試 Runtime 的防洗版設定。' >&2
    exit 1
  fi
fi
if grep -R '^[[:space:]]*#define[[:space:]]\+ENABLE_ANTISPAM' \
  "$TEMP_ROOT/mudlib/include" "$TEMP_ROOT/mudlib/adm" 2>/dev/null; then
  echo 'ORIGINAL PLAYER CREATION E2E BLOCKED：測試 Runtime 仍啟用 localhost 創角限流。' >&2
  exit 1
fi
mkdir -p "$TEMP_ROOT/mudlib/data/login"/{a..z} "$TEMP_ROOT/mudlib/data/login"/{0..9} "$TEMP_ROOT/mudlib/data/user"/{a..z} "$TEMP_ROOT/mudlib/data/user"/{0..9} "$TEMP_ROOT/mudlib/log"
for id in humanprobe avatarprobe blackprobe yenprobe wooprobe dingprobe jiaoprobe rainprobe ashprobe headprobe yaksaprobe malikprobe 7probe; do
  initial="${id:0:1}"
  rm -f "$TEMP_ROOT/mudlib/data/login/$initial/$id.o" "$TEMP_ROOT/mudlib/data/user/$initial/$id.o"
done

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 & driver_pid=$!
# Readiness gate／只讀核心 TCP listener 狀態，不建立後立即中斷的探測連線。
# 部分 Driver 對啟動期短連線的處理會觸發異常；不可用 connect-and-close 來判斷 ready。
port_listening(){
  awk -v port=":$PORT_HEX" 'NR > 1 && $2 ~ (port "$\") && $4 == "0A" { found=1 } END { exit !found }' \
    /proc/net/tcp /proc/net/tcp6 2>/dev/null
}
driver_ready=0
for _ in {1..300}; do
  if ! kill -0 "$driver_pid" 2>/dev/null; then
    echo "ORIGINAL PLAYER CREATION E2E BLOCKED：Neolith 在 listener ready 前已退出。" >&2
    tail -n 100 "$TEMP_ROOT/driver.stdout" >&2 || true
    exit 1
  fi
  if port_listening; then driver_ready=1; break; fi
  sleep 0.1
done
if ((driver_ready == 0)); then
  echo "ORIGINAL PLAYER CREATION E2E BLOCKED：等待 Neolith port $MUD_PORT listener timeout。" >&2
  tail -n 100 "$TEMP_ROOT/driver.stdout" >&2 || true
  exit 1
fi
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT="$MUD_PORT" PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 & bridge_pid=$!
# Bridge readiness gate／確認 HTTP 靜態入口已啟動；不呼叫 /health，避免重複建立 MUD 探測連線。
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/player-creation.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_SAVE_DIR="$TEMP_ROOT/mudlib/data" ES2_E2E_PASSWORD="$TEST_PASSWORD" node "$REPO_ROOT/scripts/test_original_player_creation_e2e.mjs" | tee "$LOG"
for marker in ORIGINAL_PLAYER_CREATION_HUMAN_E2E_PASS ORIGINAL_PLAYER_CREATION_AVATAR_E2E_PASS ES2M_PLAYER_CREATION_NUMERIC_ID_ACCEPTED_PASS ES2M_SINGLE_CHARACTER_DISPLAY_NAME_PASS ES2M_PLAYER_CREATION_12_RACES_E2E_PASS; do grep -Fq "$marker" "$LOG"; done
# Runtime evidence must be free of compilation/runtime errors, not merely JS markers.
test -r "$TEMP_ROOT/driver.stdout" || { echo 'ORIGINAL PLAYER CREATION E2E BLOCKED：缺少 Driver log。' >&2; exit 1; }
if grep -En '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable|Undefined function' "$TEMP_ROOT/driver.stdout"; then
  echo 'ORIGINAL PLAYER CREATION E2E FAIL：Driver Log 存在編譯／執行錯誤。' >&2
  exit 1
fi
echo "ES2M PLAYER CREATION E2E：12 種族由零存檔逐一驗證創角、世界指令、save、quit、relogin。"
