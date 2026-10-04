#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((49000 + $$ % 700))"
TEST_PASSWORD="$(openssl rand -hex 16)"
driver_pid=""; bridge_pid=""
cleanup(){ status=$?; [[ -z "$bridge_pid" ]] || kill "$bridge_pid" 2>/dev/null || true; [[ -z "$driver_pid" ]] || kill "$driver_pid" 2>/dev/null || true; wait "$bridge_pid" 2>/dev/null || true; wait "$driver_pid" 2>/dev/null || true; if ((status)); then echo "ORIGINAL PLAYER CREATION E2E FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2; else rm -rf -- "$TEMP_ROOT"; fi; return "$status"; }
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
"$REPO_ROOT/scripts/apply_race_phase2_runtime.sh" "$TEMP_ROOT"
"$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"
# Test-only Host Throttle／測試專用主機限流處理：12 個種族皆由同一個 localhost 建立，
# 會觸發 Original ES2 的每 IP 十帳號保護。只在 mktemp Runtime 套用既有 KING
# bootstrap 政策，不修改來源保存區，也不把「同 IP 大量創角」宣稱為正式 Gameplay。
grep -RIl '^[[:space:]]*#define[[:space:]]\+ENABLE_ANTISPAM' \
  "$TEMP_ROOT/mudlib/include" "$TEMP_ROOT/mudlib/adm" 2>/dev/null \
  | while read -r file; do
      sed -i 's/^[[:space:]]*#define[[:space:]]\+ENABLE_ANTISPAM.*/\/\/ ES2-KING isolated test: ENABLE_ANTISPAM disabled/' "$file"
    done
if grep -R '^[[:space:]]*#define[[:space:]]\+ENABLE_ANTISPAM' \
  "$TEMP_ROOT/mudlib/include" "$TEMP_ROOT/mudlib/adm" 2>/dev/null; then
  echo 'ORIGINAL PLAYER CREATION E2E BLOCKED：測試 Runtime 仍啟用 localhost 創角限流。' >&2
  exit 1
fi
mkdir -p "$TEMP_ROOT/mudlib/data/login"/{a..z} "$TEMP_ROOT/mudlib/data/user"/{a..z} "$TEMP_ROOT/mudlib/log"
for id in humanprobe avatarprobe blackprobe yenprobe wooprobe dingprobe jiaoprobe rainprobe ashprobe headprobe yaksaprobe malikprobe; do
  initial="${id:0:1}"
  rm -f "$TEMP_ROOT/mudlib/data/login/$initial/$id.o" "$TEMP_ROOT/mudlib/data/user/$initial/$id.o"
done

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 & driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const n=require("net"),d=Date.now()+30000;(function p(){const s=n.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 & bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/player-creation.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_SAVE_DIR="$TEMP_ROOT/mudlib/data" ES2_E2E_PASSWORD="$TEST_PASSWORD" node "$REPO_ROOT/scripts/test_original_player_creation_e2e.mjs" | tee "$LOG"
for marker in ORIGINAL_PLAYER_CREATION_HUMAN_E2E_PASS ORIGINAL_PLAYER_CREATION_AVATAR_E2E_PASS ES2M_PLAYER_CREATION_12_RACES_E2E_PASS; do grep -Fq "$marker" "$LOG"; done
echo "ES2M PLAYER CREATION E2E：12 種族由零存檔逐一驗證創角、世界指令、save、quit、relogin。"
