#!/usr/bin/env bash
set -euo pipefail

# Game Playability Completion／遊戲完整可玩程度真實 Driver 驗收。
# 兩個帳號只存在 mktemp Runtime：playprobe 負責可重複診斷，deathprobe 驗證普通玩家死亡／復活。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
FIXTURE="${2:-$REPO_ROOT/.runtime/game-completion-fixture/king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((49000 + $$ % 500))"
TEST_PASSWORD="$(openssl rand -hex 16)"
PASSWORD_SALT="$(openssl rand -hex 4)"
PASSWORD_HASH="$(ES2_HASH_PASSWORD="$TEST_PASSWORD" ES2_HASH_SALT="$PASSWORD_SALT" node -e '
const c=require("crypto"),d=c.createHash("md5").update(process.env.ES2_HASH_PASSWORD+process.env.ES2_HASH_SALT).digest(),a="./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";let e="";for(let i=0;i<3;i++){const v=d[i*5]|d[i*5+1]<<8|d[i*5+2]<<16;for(let s=0;s<24;s+=6)e+=a[v>>s&63]}e+=a[d[15]&63]+a[d[15]>>6&63];process.stdout.write("$1$"+process.env.ES2_HASH_SALT+"$"+e)
')"
driver_pid=""
bridge_pid=""

cleanup() {
  status=$?
  [[ -z "$bridge_pid" ]] || kill "$bridge_pid" 2>/dev/null || true
  [[ -z "$driver_pid" ]] || kill "$driver_pid" 2>/dev/null || true
  wait "$bridge_pid" 2>/dev/null || true
  wait "$driver_pid" 2>/dev/null || true
  if (( status != 0 )); then
    echo "PLAYABILITY COMPLETION FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2
  else
    rm -rf -- "$TEMP_ROOT"
  fi
  return "$status"
}
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"
test -f "$FIXTURE/login/king.o"
test -f "$FIXTURE/user/king.o"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
"$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"
mkdir -p "$TEMP_ROOT/mudlib/data/login/p" "$TEMP_ROOT/mudlib/data/user/p" \
  "$TEMP_ROOT/mudlib/data/login/d" "$TEMP_ROOT/mudlib/data/user/d" "$TEMP_ROOT/mudlib/log"

for id in playprobe deathprobe; do
  initial="${id:0:1}"
  cp "$FIXTURE/login/king.o" "$TEMP_ROOT/mudlib/data/login/$initial/$id.o"
  cp "$FIXTURE/user/king.o" "$TEMP_ROOT/mudlib/data/user/$initial/$id.o"
  awk -v id="$id" -v hash="$PASSWORD_HASH" '
    /^password / { print "password \"" hash "\""; next }
    /^dbase / {
      gsub(/"id":"king"/, "\"id\":\"" id "\"")
      gsub(/"name":"KING"/, "\"name\":\"可玩性測試" id "\"")
      print
      next
    }
    { print }
  ' "$TEMP_ROOT/mudlib/data/login/$initial/$id.o" > "$TEMP_ROOT/$id.login"
  mv "$TEMP_ROOT/$id.login" "$TEMP_ROOT/mudlib/data/login/$initial/$id.o"
  awk -v id="$id" '
    /^dbase / {
      gsub(/"id":"king"/, "\"id\":\"" id "\"")
      gsub(/"name":"KING"/, "\"name\":\"可玩性測試" id "\"")
      print
      next
    }
    { print }
  ' "$TEMP_ROOT/mudlib/data/user/$initial/$id.o" > "$TEMP_ROOT/$id.user"
  mv "$TEMP_ROOT/$id.user" "$TEMP_ROOT/mudlib/data/user/$initial/$id.o"
done

# Diagnostic Privilege／診斷權限只存在暫存 Runtime；deathprobe 保持普通玩家。
grep -Fqx 'playprobe (admin)' "$TEMP_ROOT/mudlib/adm/etc/wizlist" \
  || printf '%s\n' 'playprobe (admin)' >> "$TEMP_ROOT/mudlib/adm/etc/wizlist"

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 &
driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const n=require("net"),d=Date.now()+30000;(function p(){const s=n.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 &
bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/playability.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_PASSWORD="$TEST_PASSWORD" \
  node "$REPO_ROOT/scripts/test_game_playability_completion_e2e.mjs" | tee "$LOG"

for marker in \
  PLAYABILITY_PASS:connection-login-character \
  PLAYABILITY_PASS:world-navigation \
  PLAYABILITY_PASS:npc-interaction \
  PLAYABILITY_PASS:item-equipment \
  PLAYABILITY_PASS:npc-death-respawn \
  PLAYABILITY_PASS:player-death-recovery \
  PLAYABILITY_PASS:save-quit-reconnect-restore \
  GAME_PLAYABILITY_COMPLETION_RUNTIME_PASS
do
  grep -Fq "$marker" "$LOG" || { echo "PLAYABILITY COMPLETION FAIL：缺少 $marker" >&2; exit 1; }
done

if rg -n '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable' "$TEMP_ROOT/driver.stdout"; then
  echo 'PLAYABILITY COMPLETION FAIL：Driver Log 存在編譯／執行錯誤。' >&2
  exit 1
fi

echo 'GAME PLAYABILITY COMPLETION RUNTIME PASS：真實 Driver 已通過世界路徑、NPC、物品／裝備、NPC 死亡／重生、玩家死亡／復活與存檔重登。'
