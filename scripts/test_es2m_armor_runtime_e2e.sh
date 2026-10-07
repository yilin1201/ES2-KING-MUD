#!/usr/bin/env bash
# 91 件防具真實 Driver 隔離驗證：測試指令只放入 mktemp Runtime，正式世界不提供物品。
set -euo pipefail
unset DATABASE_URL
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/v5-isolated-runtime}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$REPO_ROOT/.runtime/v5-isolated-build/src/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((48500 + $$ % 900))"
TEST_PASSWORD="$(openssl rand -hex 16)"
driver_pid=""; bridge_pid=""
cleanup(){ status=$?; [[ -z "$bridge_pid" ]]||kill "$bridge_pid" 2>/dev/null||true; [[ -z "$driver_pid" ]]||kill "$driver_pid" 2>/dev/null||true; wait "$bridge_pid" 2>/dev/null||true; wait "$driver_pid" 2>/dev/null||true; if ((status));then echo "ES2M ARMOR RUNTIME FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2;else rm -rf -- "$TEMP_ROOT";fi; return "$status"; }
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"
test -d "$SOURCE_RUNTIME/mudlib"
test -f "$SOURCE_RUNTIME/neolith.conf"
test -f "$REPO_ROOT/webtelnet/node_modules/ws/wrapper.mjs"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
bash "$REPO_ROOT/scripts/apply_race_phase2_runtime.sh" "$TEMP_ROOT"
bash "$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"
python3 "$REPO_ROOT/scripts/apply_es2m_armor_persistence_runtime.py" \
  --matrix "$REPO_ROOT/docs/migration/ES2M_IMPORT_MATRIX_20261003.csv" \
  --runtime "$TEMP_ROOT/mudlib"
python3 "$REPO_ROOT/scripts/generate_es2m_armor_runtime_fixture.py" \
  --matrix "$REPO_ROOT/docs/migration/ES2M_IMPORT_MATRIX_20261003.csv" \
  --output "$TEMP_ROOT/mudlib/cmds/usr/es2armor.c"
rm -rf -- "$TEMP_ROOT/mudlib/data"
mkdir -p "$TEMP_ROOT/mudlib/data/login"/{a..z} "$TEMP_ROOT/mudlib/data/user"/{a..z} "$TEMP_ROOT/mudlib/log"

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 & driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const n=require("net"),d=Date.now()+30000;(function p(){const s=n.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 & bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/armor-runtime.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_PASSWORD="$TEST_PASSWORD" \
  node "$REPO_ROOT/scripts/test_es2m_armor_runtime_e2e.mjs" | tee "$LOG"
for marker in \
  ES2_ARMOR_PLAYER_SECURITY_PASS \
  ES2_ORDINARY_EQUIPMENT_PERSISTENCE_PASS \
  ES2_ARMOR_LOAD_PASS \
  ES2_ARMOR_FIVE_SLOTS_PASS \
  ES2_ARMOR_RESTRICTIONS_PASS \
  ES2_ARMOR_UNIQUE_PASS \
  ES2_ARMOR_CORROSIVE_HANDS_PASS \
  ES2_ARMOR_PERSISTENCE_PASS \
  ES2M_ARMOR_RUNTIME_E2E_PASS
do grep -Fq "$marker" "$LOG"; done
test "$(grep -o '/custom/armor/' "$TEMP_ROOT/mudlib/data/user/a/armorprobe.o" | wc -l)" -eq 5
if grep -En '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable|Undefined function' "$TEMP_ROOT/driver.stdout"; then
  echo 'ES2M ARMOR RUNTIME FAIL：Driver Log 存在程式錯誤。' >&2
  exit 1
fi
echo 'ES2M ARMOR RUNTIME PASS：普通玩家、91 件載入、五部位、9 限制、3 唯一物、腐蝕之手與五部位跨登入保存均通過。'
