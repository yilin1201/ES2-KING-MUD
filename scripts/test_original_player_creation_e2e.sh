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
"$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"
mkdir -p "$TEMP_ROOT/mudlib/data/login/h" "$TEMP_ROOT/mudlib/data/user/h" "$TEMP_ROOT/mudlib/data/login/a" "$TEMP_ROOT/mudlib/data/user/a" "$TEMP_ROOT/mudlib/log"
rm -f "$TEMP_ROOT/mudlib/data/login/h/humanprobe.o" "$TEMP_ROOT/mudlib/data/user/h/humanprobe.o" "$TEMP_ROOT/mudlib/data/login/a/avatarprobe.o" "$TEMP_ROOT/mudlib/data/user/a/avatarprobe.o"

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 & driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const n=require("net"),d=Date.now()+30000;(function p(){const s=n.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 & bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/player-creation.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_SAVE_DIR="$TEMP_ROOT/mudlib/data" ES2_E2E_PASSWORD="$TEST_PASSWORD" node "$REPO_ROOT/scripts/test_original_player_creation_e2e.mjs" | tee "$LOG"
for marker in ORIGINAL_PLAYER_CREATION_HUMAN_E2E_PASS ORIGINAL_PLAYER_CREATION_AVATAR_E2E_PASS ORIGINAL_PLAYER_CREATION_E2E_PASS; do grep -Fq "$marker" "$LOG"; done
echo "ORIGINAL PLAYER CREATION E2E PASS：Human（人類）與 Avatar（人類族）均由零存檔完成創角、世界指令、save、quit、relogin。"
