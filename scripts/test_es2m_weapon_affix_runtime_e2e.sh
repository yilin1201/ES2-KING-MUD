#!/usr/bin/env bash
# 新武器附加屬性真實 Driver 驗證：全部資料及測試指令只存在 mktemp Runtime。
set -euo pipefail
unset DATABASE_URL
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/v5-isolated-runtime}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$REPO_ROOT/.runtime/v5-isolated-build/src/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((47500 + $$ % 900))"
TEST_PASSWORD="$(openssl rand -hex 16)"
driver_pid=""; bridge_pid=""
cleanup(){ status=$?; [[ -z "$bridge_pid" ]]||kill "$bridge_pid" 2>/dev/null||true; [[ -z "$driver_pid" ]]||kill "$driver_pid" 2>/dev/null||true; wait "$bridge_pid" 2>/dev/null||true; wait "$driver_pid" 2>/dev/null||true; if ((status));then echo "ES2M WEAPON AFFIX RUNTIME FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2;else rm -rf -- "$TEMP_ROOT";fi; return "$status"; }
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"
test -d "$SOURCE_RUNTIME/mudlib"
test -f "$SOURCE_RUNTIME/neolith.conf"
test -f "$REPO_ROOT/webtelnet/node_modules/ws/wrapper.mjs"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
bash "$REPO_ROOT/scripts/apply_race_phase2_runtime.sh" "$TEMP_ROOT"
bash "$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"
python3 "$REPO_ROOT/scripts/generate_es2m_weapon_affix_runtime_fixture.py" \
  --output "$TEMP_ROOT/mudlib/cmds/usr/es2affix.c"
rm -rf -- "$TEMP_ROOT/mudlib/data"
mkdir -p "$TEMP_ROOT/mudlib/data/login"/{a..z} "$TEMP_ROOT/mudlib/data/user"/{a..z} "$TEMP_ROOT/mudlib/log"

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 & driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const n=require("net"),d=Date.now()+30000;(function p(){const s=n.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 & bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/weapon-affix-runtime.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_PASSWORD="$TEST_PASSWORD" \
  node "$REPO_ROOT/scripts/test_es2m_weapon_affix_runtime_e2e.mjs" | tee "$LOG"
for marker in \
  ES2_AFFIX_PLAYER_SECURITY_PASS \
  ES2_AFFIX_LOAD_PASS \
  ES2_AFFIX_EQUIP_PASS \
  ES2_AFFIX_STORAGE_PERSISTENCE_PASS \
  ES2M_WEAPON_AFFIX_RUNTIME_E2E_PASS
do grep -Fq "$marker" "$LOG"; done
if grep -En '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable|Undefined function' "$TEMP_ROOT/driver.stdout"; then
  echo 'ES2M WEAPON AFFIX RUNTIME FAIL：Driver Log 存在程式錯誤。' >&2
  exit 1
fi
echo 'ES2M WEAPON AFFIX RUNTIME PASS：17 件武器、確定詞綴、裝備與私人儲物箱跨登入保存均通過。'
