#!/usr/bin/env bash
# Player Open Alpha／普通玩家開放測試：建立全空 data Runtime，禁止使用預建玩家 save 或管理權限。
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((50000 + $$ % 500))"
TEST_PASSWORD="$(openssl rand -hex 16)"
driver_pid=""
bridge_pid=""

cleanup() {
  status=$?
  [[ -z "$bridge_pid" ]] || kill "$bridge_pid" 2>/dev/null || true
  [[ -z "$driver_pid" ]] || kill "$driver_pid" 2>/dev/null || true
  wait "$bridge_pid" 2>/dev/null || true
  wait "$driver_pid" 2>/dev/null || true
  if (( status != 0 )); then
    echo "PLAYER OPEN ALPHA FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2
  else
    rm -rf -- "$TEMP_ROOT"
  fi
  return "$status"
}
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
"$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"

# Fresh Data／全新資料：此 E2E 不複製任何 login/user fixture。
rm -rf -- "$TEMP_ROOT/mudlib/data"
mkdir -p "$TEMP_ROOT/mudlib/data/login"/{a..z} "$TEMP_ROOT/mudlib/data/user"/{a..z} "$TEMP_ROOT/mudlib/log"

# Security Gate／安全閘門：測試帳號不得存在 wizlist，也不允許測試腳本加入權限。
for id in kinglook avataropen thiefopen; do
  ! grep -Eq "^${id}[[:space:]]" "$TEMP_ROOT/mudlib/adm/etc/wizlist"
done

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 &
driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const n=require("net"),d=Date.now()+30000;(function p(){const s=n.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 &
bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/player-open-alpha.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_PASSWORD="$TEST_PASSWORD" \
  node "$REPO_ROOT/scripts/test_player_open_alpha_e2e.mjs" | tee "$LOG"

for marker in \
  ORIGINAL_PLAYER_CREATION_HUMAN_E2E_PASS \
  ORIGINAL_PLAYER_CREATION_AVATAR_E2E_PASS \
  PLAYER_SECURITY_BOUNDARY_PASS \
  PLAYER_CLASS_PASS:kinglook:alchemist \
  PLAYER_CLASS_PASS:thiefopen:thief \
  PLAYER_TRAINING_PASS:thiefopen:npc-improve_skill \
  PLAYER_THIEF_PERSISTENCE_PASS \
  PLAYER_FULL_JOURNEY_E2E_PASS
do
  grep -Fq "$marker" "$LOG" || { echo "PLAYER OPEN ALPHA FAIL：缺少 $marker" >&2; exit 1; }
done

# Save Evidence／存檔證據：由 Driver 從零建立，不接受 fixture 或畫面文字替代。
for id in kinglook avataropen thiefopen; do
  initial="${id:0:1}"
  test -s "$TEMP_ROOT/mudlib/data/login/$initial/$id.o"
  test -s "$TEMP_ROOT/mudlib/data/user/$initial/$id.o"
  grep -Fq '"level":1' "$TEMP_ROOT/mudlib/data/user/$initial/$id.o"
done
grep -Fq '"race":"human"' "$TEMP_ROOT/mudlib/data/user/k/kinglook.o"
grep -Fq '"class":"alchemist"' "$TEMP_ROOT/mudlib/data/user/k/kinglook.o"
grep -Fq '"name":"KING"' "$TEMP_ROOT/mudlib/data/user/k/kinglook.o"
grep -Fq '"race":"avatar"' "$TEMP_ROOT/mudlib/data/user/a/avataropen.o"
grep -Fq '"class":"commoner"' "$TEMP_ROOT/mudlib/data/user/a/avataropen.o"
grep -Fq '"class":"thief"' "$TEMP_ROOT/mudlib/data/user/t/thiefopen.o"
grep -Eq '^skills .*"sneak":0' "$TEMP_ROOT/mudlib/data/user/t/thiefopen.o"
grep -Eq '^learned .*"sneak":([2-9][0-9]|[1-9][0-9]{2,})' "$TEMP_ROOT/mudlib/data/user/t/thiefopen.o"

if rg -n '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable' "$TEMP_ROOT/driver.stdout"; then
  echo 'PLAYER OPEN ALPHA FAIL：Driver Log 存在編譯／執行錯誤。' >&2
  exit 1
fi

echo 'PLAYER_OPEN_ALPHA_LOCAL_RUNTIME_PASS：全新 Human／Avatar 創角、普通玩家世界／NPC／物品／裝備／戰鬥、Alchemist／Thief、save／quit／relogin 均通過。'
