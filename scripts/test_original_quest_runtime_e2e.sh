#!/usr/bin/env bash
set -euo pipefail

# Phase 3 Original Quest Runtime／貨棧工錢與私塾書生真實 Driver 驗收。
# 兩個測試帳號只存在 mktemp Runtime；不讀寫正式 KING、Render 或 Neon 玩家資料。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/playability-runtime}"
FIXTURE="${2:-$REPO_ROOT/.runtime/playability-fixture/king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((49900 + $$ % 90))"
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
    echo "ORIGINAL QUEST RUNTIME FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2
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
mkdir -p "$TEMP_ROOT/mudlib/data/login/w" "$TEMP_ROOT/mudlib/data/user/w" \
  "$TEMP_ROOT/mudlib/data/login/s" "$TEMP_ROOT/mudlib/data/user/s" "$TEMP_ROOT/mudlib/log"

for id in wageprobe scholarprobe; do
  initial="${id:0:1}"
  cp "$FIXTURE/login/king.o" "$TEMP_ROOT/mudlib/data/login/$initial/$id.o"
  cp "$FIXTURE/user/king.o" "$TEMP_ROOT/mudlib/data/user/$initial/$id.o"
  awk -v id="$id" -v hash="$PASSWORD_HASH" '
    /^id / { print "id \"" id "\""; next }
    /^name / { print "name \"Original Quest 測試\""; next }
    /^password / { print "password \"" hash "\""; next }
    /^dbase / {
      gsub(/"id":"king"/, "\"id\":\"" id "\"")
      gsub(/"name":"KING"/, "\"name\":\"Original Quest 測試\"")
      print
      next
    }
    { print }
  ' "$TEMP_ROOT/mudlib/data/login/$initial/$id.o" > "$TEMP_ROOT/$id.login"
  mv "$TEMP_ROOT/$id.login" "$TEMP_ROOT/mudlib/data/login/$initial/$id.o"

  awk -v id="$id" '
    /^attribute / { print "attribute ([\"cor\":16,\"dex\":16,\"cps\":16,\"str\":16,\"spi\":16,\"wis\":16,\"con\":16,\"int\":16,])"; next }
    /^dbase / { print "dbase ([\"gender\":\"male\",\"birthday\":1790236786,\"id\":\"" id "\",\"name\":\"Original Quest 測試\",\"class\":\"commoner\",\"level\":1,\"age\":17,\"race\":\"human\",\"time_aged\":0,])"; next }
    /^masters / { print "masters ([])"; next }
    /^apprentices / { print "apprentices ([])"; next }
    /^skills / { if (id == "scholarprobe") print "skills ([\"literate\":5,])"; else print "skills ([])"; next }
    /^learned / { print "learned ([])"; next }
    /^skill_map / { print "skill_map ([])"; next }
    /^skill_flag / { print "skill_flag ([])"; next }
    /^autoload / { print "autoload ({})"; next }
    { print }
  ' "$TEMP_ROOT/mudlib/data/user/$initial/$id.o" > "$TEMP_ROOT/$id.user"
  mv "$TEMP_ROOT/$id.user" "$TEMP_ROOT/mudlib/data/user/$initial/$id.o"
  printf '%s (admin)\n' "$id" >> "$TEMP_ROOT/mudlib/adm/etc/wizlist"
done

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 &
driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const n=require("net"),d=Date.now()+30000;(function p(){const s=n.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 &
bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/original-quest-runtime.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_PASSWORD="$TEST_PASSWORD" \
  node "$REPO_ROOT/scripts/test_original_quest_runtime_e2e.mjs" | tee "$LOG"

for marker in \
  ORIGINAL_WAGE_PASS:entry-progress-completion-reward \
  ORIGINAL_WAGE_PASS:save-quit-relogin-restore \
  ORIGINAL_WAGE_RUNTIME_PASS \
  ORIGINAL_SCHOLAR_PASS:entry-requirement-teaching \
  ORIGINAL_SCHOLAR_PASS:offer-and-class-state \
  ORIGINAL_SCHOLAR_PASS:save-quit-relogin-restore \
  ORIGINAL_SCHOLAR_RUNTIME_PASS \
  ORIGINAL_QUEST_PHASE3_RUNTIME_PASS
do
  grep -Fq "$marker" "$LOG" || { echo "ORIGINAL QUEST RUNTIME FAIL：缺少 $marker" >&2; exit 1; }
done

# Driver Save Evidence／工錢 reward 與 scholar class 都由 Driver 寫入隔離存檔。
grep -Eq '^autoload .*\/obj\/money\/coin:25' "$TEMP_ROOT/mudlib/data/user/w/wageprobe.o"
grep -Fq '"class":"scholar"' "$TEMP_ROOT/mudlib/data/user/s/scholarprobe.o"
grep -Eq '^learned .*"literate":[1-9][0-9]*' "$TEMP_ROOT/mudlib/data/user/s/scholarprobe.o"

if rg -n '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable' "$TEMP_ROOT/driver.stdout"; then
  echo 'ORIGINAL QUEST RUNTIME FAIL：Driver Log 存在編譯／執行錯誤。' >&2
  exit 1
fi

echo 'ORIGINAL QUEST PHASE 3 RUNTIME PASS：貨棧工錢與 Scholar 已由隔離真實 Driver 完成並跨重登還原。'
