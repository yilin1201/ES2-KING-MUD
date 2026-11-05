#!/usr/bin/env bash
set -euo pipefail

# K Admin E2E／使用一次性 KING + kprobe，禁止讀寫正式玩家與 Neon 資料。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
FIXTURE="${2:-$REPO_ROOT/.runtime/game-completion-fixture/king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((48500 + $$ % 1000))"
TEST_PASSWORD="$(openssl rand -hex 16)"
PASSWORD_SALT="$(openssl rand -hex 4)"
PASSWORD_HASH="$(ES2_HASH_PASSWORD="$TEST_PASSWORD" ES2_HASH_SALT="$PASSWORD_SALT" node -e '
const c=require("crypto"),d=c.createHash("md5").update(process.env.ES2_HASH_PASSWORD+process.env.ES2_HASH_SALT).digest(),a="./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";let e="";for(let i=0;i<3;i++){const v=d[i*5]|d[i*5+1]<<8|d[i*5+2]<<16;for(let s=0;s<24;s+=6)e+=a[(v>>s)&63]}e+=a[d[15]&63]+a[(d[15]>>6)&63];process.stdout.write("$1$"+process.env.ES2_HASH_SALT+"$"+e)
')"
driver_pid=""; bridge_pid=""

cleanup(){ status=$?; [[ -z "$bridge_pid" ]]||kill "$bridge_pid" 2>/dev/null||true; [[ -z "$driver_pid" ]]||kill "$driver_pid" 2>/dev/null||true; wait "$bridge_pid" 2>/dev/null||true; wait "$driver_pid" 2>/dev/null||true; if ((status));then echo "K ADMIN RUNTIME FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2;else rm -rf -- "$TEMP_ROOT";fi; return "$status"; }
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"; test -f "$FIXTURE/login/king.o"; test -f "$FIXTURE/user/king.o"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
"$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"
mkdir -p "$TEMP_ROOT/mudlib/data/login/k" "$TEMP_ROOT/mudlib/data/user/k" "$TEMP_ROOT/mudlib/log"

# KING fixture／正式帳號格式，但只存在 mktemp Runtime。
cp "$FIXTURE/login/king.o" "$TEMP_ROOT/mudlib/data/login/k/king.o"
cp "$FIXTURE/user/king.o" "$TEMP_ROOT/mudlib/data/user/k/king.o"
awk -v hash="$PASSWORD_HASH" '/^password /{print "password \"" hash "\"";next}{print}' "$TEMP_ROOT/mudlib/data/login/k/king.o" > "$TEMP_ROOT/king.login"
mv "$TEMP_ROOT/king.login" "$TEMP_ROOT/mudlib/data/login/k/king.o"

# kprobe fixture／一般玩家，不能加入 Original wizlist；K role 只由 kadmind 暫存資料管理。
cp "$FIXTURE/login/king.o" "$TEMP_ROOT/mudlib/data/login/k/kprobe.o"
cp "$FIXTURE/user/king.o" "$TEMP_ROOT/mudlib/data/user/k/kprobe.o"
awk -v hash="$PASSWORD_HASH" '
  /^dbase / { print "dbase ([\"id\":\"kprobe\",\"channels\":({\"chat\",\"rumor\",}),\"name\":\"K權限測試\",\"creation_time\":1790236786,\"body\":\"/obj/user\",\"last_on\":1790236788,\"karma\":5,\"last_from\":\"localhost\",\"time_aged\":6,])"; next }
  /^password / { print "password \"" hash "\""; next }
  { print }
' "$TEMP_ROOT/mudlib/data/login/k/kprobe.o" > "$TEMP_ROOT/kprobe.login"
mv "$TEMP_ROOT/kprobe.login" "$TEMP_ROOT/mudlib/data/login/k/kprobe.o"
awk '
  /^dbase / { print "dbase ([\"gender\":\"male\",\"birthday\":1790236786,\"id\":\"kprobe\",\"name\":\"K權限測試\",\"class\":\"commoner\",\"level\":1,\"age\":17,\"race\":\"human\",\"time_aged\":0,])"; next }
  /^masters / { print "masters ([])"; next }
  /^apprentices / { print "apprentices ([])"; next }
  /^skills / { print "skills ([])"; next }
  /^learned / { print "learned ([])"; next }
  /^skill_map / { print "skill_map ([])"; next }
  /^skill_flag / { print "skill_flag ([])"; next }
  { print }
' "$TEMP_ROOT/mudlib/data/user/k/kprobe.o" > "$TEMP_ROOT/kprobe.user"
mv "$TEMP_ROOT/kprobe.user" "$TEMP_ROOT/mudlib/data/user/k/kprobe.o"
if grep -Eq '^kprobe[[:space:]]' "$TEMP_ROOT/mudlib/adm/etc/wizlist"; then echo 'K ADMIN RUNTIME FAIL：kprobe 不得進入 Original wizlist。' >&2; exit 1; fi

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 & driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const n=require("net"),d=Date.now()+30000;(function p(){const s=n.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 & bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/k-admin.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_PASSWORD="$TEST_PASSWORD" node "$REPO_ROOT/scripts/test_k_admin_runtime_e2e.mjs" | tee "$LOG"
for marker in K_ADMIN_RUNTIME_PASS K_HELP_RUNTIME_PASS K_PERMISSION_REGRESSION_PASS; do grep -Fq "$marker" "$LOG"; done
if rg -n '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable' "$TEMP_ROOT/driver.stdout"; then echo 'K ADMIN RUNTIME FAIL：Driver Log 存在 Code Error。' >&2; exit 1; fi
grep -Fq '"id":"kprobe"' "$TEMP_ROOT/mudlib/data/user/k/kprobe.o"
grep -Fq '"class":"commoner"' "$TEMP_ROOT/mudlib/data/user/k/kprobe.o"
grep -Fq '"k":\s*"kill"' "$TEMP_ROOT/mudlib/adm/daemons/aliasd.c" || grep -Fq '"k":' "$TEMP_ROOT/mudlib/adm/daemons/aliasd.c"
echo 'K ADMIN RUNTIME PASS：KING／Wizard／Arch／Player 權限、Help、Original k=kill 與 save／quit／relogin 已由隔離真 Driver 通過。'
