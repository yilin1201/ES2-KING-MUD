#!/usr/bin/env bash
set -euo pipefail

# Fighter Historical Reconstruction E2E／建立一次性 Runtime 與隔離 fixture，
# 不讀寫正式 KING、Neon 或任何正式玩家存檔。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
FIXTURE="${2:-$REPO_ROOT/.runtime/game-completion-fixture/king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((49000 + $$ % 1000))"
TEST_PASSWORD="$(openssl rand -hex 16)"
PASSWORD_SALT="$(openssl rand -hex 4)"
PASSWORD_HASH="$(ES2_HASH_PASSWORD="$TEST_PASSWORD" ES2_HASH_SALT="$PASSWORD_SALT" node -e '
const c=require("crypto"),d=c.createHash("md5").update(process.env.ES2_HASH_PASSWORD+process.env.ES2_HASH_SALT).digest(),a="./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";let e="";for(let i=0;i<3;i++){const v=d[i*5]|d[i*5+1]<<8|d[i*5+2]<<16;for(let s=0;s<24;s+=6)e+=a[(v>>s)&63]}e+=a[d[15]&63]+a[(d[15]>>6)&63];process.stdout.write("$1$"+process.env.ES2_HASH_SALT+"$"+e)
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
    echo "FIGHTER CLASS RUNTIME FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2
  else
    rm -rf -- "$TEMP_ROOT"
  fi
  return "$status"
}
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"
if [[ -f "$FIXTURE/login/king.o" && -f "$FIXTURE/user/king.o" ]]; then
  FIXTURE_LOGIN="$FIXTURE/login/king.o"
  FIXTURE_USER="$FIXTURE/user/king.o"
elif [[ -f "$FIXTURE/login/k/king.o" && -f "$FIXTURE/user/k/king.o" ]]; then
  FIXTURE_LOGIN="$FIXTURE/login/k/king.o"
  FIXTURE_USER="$FIXTURE/user/k/king.o"
else
  echo "FIGHTER CLASS RUNTIME FAIL：找不到 fixture：$FIXTURE" >&2
  exit 1
fi

cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
"$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"
mkdir -p "$TEMP_ROOT/mudlib/data/login/f" "$TEMP_ROOT/mudlib/data/user/f" "$TEMP_ROOT/mudlib/log"

# Fixture Clone／只沿用真實 save_object 格式；改成隔離 ID、密碼與 commoner 起點。
cp "$FIXTURE_LOGIN" "$TEMP_ROOT/mudlib/data/login/f/fighterprobe.o"
cp "$FIXTURE_USER" "$TEMP_ROOT/mudlib/data/user/f/fighterprobe.o"
awk -v hash="$PASSWORD_HASH" '
  /^id / { print "id \"fighterprobe\""; next }
  /^name / { print "name \"武者流程測試\""; next }
  /^password / { print "password \"" hash "\""; next }
  { print }
' "$TEMP_ROOT/mudlib/data/login/f/fighterprobe.o" > "$TEMP_ROOT/fighterprobe.login"
mv "$TEMP_ROOT/fighterprobe.login" "$TEMP_ROOT/mudlib/data/login/f/fighterprobe.o"
awk '
  /^attribute / { print "attribute ([\"cor\":16,\"dex\":13,\"cps\":15,\"str\":16,\"spi\":14,\"wis\":16,\"con\":14,\"int\":16,])"; next }
  /^dbase / { print "dbase ([\"gender\":\"male\",\"birthday\":1790236786,\"id\":\"fighterprobe\",\"name\":\"武者流程測試\",\"class\":\"commoner\",\"level\":1,\"age\":17,\"race\":\"human\",\"time_aged\":0,])"; next }
  /^masters / { print "masters ([])"; next }
  /^apprentices / { print "apprentices ([])"; next }
  /^skills / { print "skills ([])"; next }
  /^learned / { print "learned ([])"; next }
  /^skill_map / { print "skill_map ([])"; next }
  /^skill_flag / { print "skill_flag ([])"; next }
  { print }
' "$TEMP_ROOT/mudlib/data/user/f/fighterprobe.o" > "$TEMP_ROOT/fighterprobe.user"
mv "$TEMP_ROOT/fighterprobe.user" "$TEMP_ROOT/mudlib/data/user/f/fighterprobe.o"

# Test-only navigation authority／僅讓隔離 fixture 使用 goto 抵達未接正式世界的重建入口。
grep -Fqx 'fighterprobe (admin)' "$TEMP_ROOT/mudlib/adm/etc/wizlist" \
  || printf '%s\n' 'fighterprobe (admin)' >> "$TEMP_ROOT/mudlib/adm/etc/wizlist"

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 & driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const n=require("net"),d=Date.now()+30000;(function p(){const s=n.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 & bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/fighter-class.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_PASSWORD="$TEST_PASSWORD" \
  node "$REPO_ROOT/scripts/test_original_fighter_class_runtime_e2e.mjs" | tee "$LOG"

for marker in \
  ORIGINAL_FIGHTER_CLASS_PASS:entry \
  ORIGINAL_FIGHTER_CLASS_PASS:join \
  ORIGINAL_FIGHTER_CLASS_PASS:class-fighter \
  ORIGINAL_FIGHTER_CLASS_PASS:rank \
  ORIGINAL_FIGHTER_CLASS_PASS:save-quit-relogin \
  ORIGINAL_FIGHTER_CLASS_RUNTIME_PASS
do
  grep -Fq "$marker" "$LOG" || { echo "FIGHTER CLASS RUNTIME FAIL：缺少 $marker" >&2; exit 1; }
done

# Driver Save Evidence／不能只看畫面；隔離 save_object 檔必須實際寫回 fighter。
grep -Fq '"class":"fighter"' "$TEMP_ROOT/mudlib/data/user/f/fighterprobe.o"

echo 'ORIGINAL FIGHTER CLASS RUNTIME PASS：Historical join→Target set_class(fighter)→武者 rank→save／quit／relogin 已由隔離真 Driver 通過。'
