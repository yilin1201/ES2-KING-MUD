#!/usr/bin/env bash
set -euo pipefail

# Original Thief Progression／原作盜賊進階真實 Driver 驗證。
# 測試帳號只存在 mktemp Runtime；不讀寫正式 KING、Render 或 Neon 玩家資料。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/playability-runtime}"
FIXTURE="${2:-$REPO_ROOT/.runtime/playability-fixture/king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((49500 + $$ % 400))"
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
    echo "ORIGINAL THIEF PROGRESSION FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2
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
mkdir -p "$TEMP_ROOT/mudlib/data/login/t" "$TEMP_ROOT/mudlib/data/user/t" "$TEMP_ROOT/mudlib/log"

cp "$FIXTURE/login/king.o" "$TEMP_ROOT/mudlib/data/login/t/thiefprobe.o"
cp "$FIXTURE/user/king.o" "$TEMP_ROOT/mudlib/data/user/t/thiefprobe.o"
awk -v hash="$PASSWORD_HASH" '
  /^id / { print "id \"thiefprobe\""; next }
  /^name / { print "name \"盜賊流程測試\""; next }
  /^password / { print "password \"" hash "\""; next }
  /^dbase / {
    gsub(/"id":"king"/, "\"id\":\"thiefprobe\"")
    gsub(/"name":"KING"/, "\"name\":\"盜賊流程測試\"")
    print
    next
  }
  { print }
' "$TEMP_ROOT/mudlib/data/login/t/thiefprobe.o" > "$TEMP_ROOT/thiefprobe.login"
mv "$TEMP_ROOT/thiefprobe.login" "$TEMP_ROOT/mudlib/data/login/t/thiefprobe.o"
awk '
  /^dbase / { print "dbase ([\"gender\":\"male\",\"birthday\":1790236786,\"id\":\"thiefprobe\",\"name\":\"盜賊流程測試\",\"class\":\"commoner\",\"level\":1,\"age\":17,\"race\":\"human\",\"time_aged\":0,])"; next }
  /^masters / { print "masters ([])"; next }
  /^apprentices / { print "apprentices ([])"; next }
  /^skills / { print "skills ([])"; next }
  /^learned / { print "learned ([])"; next }
  /^skill_map / { print "skill_map ([])"; next }
  /^skill_flag / { print "skill_flag ([])"; next }
  /^autoload / { print "autoload ({\"/obj/money/coin:500\",})"; next }
  { print }
' "$TEMP_ROOT/mudlib/data/user/t/thiefprobe.o" > "$TEMP_ROOT/thiefprobe.user"
mv "$TEMP_ROOT/thiefprobe.user" "$TEMP_ROOT/mudlib/data/user/t/thiefprobe.o"

# 診斷權限只存在暫存 Runtime，用來讀取狀態與停止 NPC 隨機移動。
grep -Fqx 'thiefprobe (admin)' "$TEMP_ROOT/mudlib/adm/etc/wizlist" \
  || printf '%s\n' 'thiefprobe (admin)' >> "$TEMP_ROOT/mudlib/adm/etc/wizlist"

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 &
driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const n=require("net"),d=Date.now()+30000;(function p(){const s=n.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 &
bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/thief-progression.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_PASSWORD="$TEST_PASSWORD" \
  node "$REPO_ROOT/scripts/test_original_thief_progression_runtime_e2e.mjs" | tee "$LOG"

for marker in \
  THIEF_PROGRESSION_PASS:original-world-route \
  THIEF_PROGRESSION_PASS:food-comb-exchange \
  THIEF_PROGRESSION_PASS:comb-qualification \
  THIEF_PROGRESSION_PASS:class-and-skills \
  THIEF_PROGRESSION_PASS:save-quit-relogin-restore \
  ORIGINAL_THIEF_PROGRESSION_RUNTIME_PASS
do
  grep -Fq "$marker" "$LOG" || { echo "ORIGINAL THIEF PROGRESSION FAIL：缺少 $marker" >&2; exit 1; }
done

# Save Evidence／存檔證據：由 Driver 寫回 class 與技能，不只檢查畫面文字。
grep -Fq '"class":"thief"' "$TEMP_ROOT/mudlib/data/user/t/thiefprobe.o"
grep -Eq '^skills .*"sneak":0' "$TEMP_ROOT/mudlib/data/user/t/thiefprobe.o"
grep -Eq '^skills .*"stealing":0' "$TEMP_ROOT/mudlib/data/user/t/thiefprobe.o"
grep -Eq '^learned .*"sneak":([2-9][0-9]|[1-9][0-9]{2,})' "$TEMP_ROOT/mudlib/data/user/t/thiefprobe.o"
grep -Eq '^learned .*"stealing":([2-9][0-9]|[1-9][0-9]{2,})' "$TEMP_ROOT/mudlib/data/user/t/thiefprobe.o"

if rg -n '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable' "$TEMP_ROOT/driver.stdout"; then
  echo 'ORIGINAL THIEF PROGRESSION FAIL：Driver Log 存在編譯／執行錯誤。' >&2
  exit 1
fi

echo 'ORIGINAL THIEF PROGRESSION RUNTIME PASS：食物→阿寶梳子→瞎眼老太婆→盜賊職業／技能→save／quit／relogin 已由隔離真實 Driver 通過。'
