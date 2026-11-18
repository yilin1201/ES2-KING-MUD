#!/usr/bin/env bash
set -euo pipefail

# Original Social / Communication Runtime／原作社交通訊實機測試。
# 使用兩個隔離測試玩家，所有帳號與角色資料只存在 mktemp Runtime，不接觸正式 KING／Neon。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
FIXTURE="${2:-$REPO_ROOT/.runtime/game-completion-fixture/king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((47000 + $$ % 1000))"
TEST_PASSWORD="$(openssl rand -hex 16)"
PASSWORD_SALT="$(openssl rand -hex 4)"
PASSWORD_HASH="$(ES2_HASH_PASSWORD="$TEST_PASSWORD" ES2_HASH_SALT="$PASSWORD_SALT" node -e '
const crypto=require("crypto"),d=crypto.createHash("md5").update(process.env.ES2_HASH_PASSWORD+process.env.ES2_HASH_SALT).digest(),a="./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";let e="";for(let i=0;i<3;i++){const v=d[i*5]|(d[i*5+1]<<8)|(d[i*5+2]<<16);for(let s=0;s<24;s+=6)e+=a[(v>>s)&63]}e+=a[d[15]&63]+a[(d[15]>>6)&63];process.stdout.write(`$1$${process.env.ES2_HASH_SALT}$${e}`);
')"
driver_pid=""; bridge_pid=""
cleanup(){ status=$?; [[ -z "$bridge_pid" ]]||kill "$bridge_pid" 2>/dev/null||true; [[ -z "$driver_pid" ]]||kill "$driver_pid" 2>/dev/null||true; wait "$bridge_pid" 2>/dev/null||true; wait "$driver_pid" 2>/dev/null||true; if ((status!=0)); then echo "ORIGINAL SOCIAL RUNTIME FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2; else rm -rf -- "$TEMP_ROOT"; fi; return "$status"; }
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"; test -f "$FIXTURE/login/king.o"; test -f "$FIXTURE/user/king.o"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"; cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
mkdir -p "$TEMP_ROOT/mudlib/data/login"/{s} "$TEMP_ROOT/mudlib/data/user"/{s} "$TEMP_ROOT/mudlib/log"

# Fixture Clone／測試角色複製：從已由真實 save_object 產生的 KING fixture 複製，
# 只改隔離副本的帳號 ID、角色 ID、顯示名與測試密碼；不寫回正式資料。
for id in sociala socialb; do
  cp "$FIXTURE/login/king.o" "$TEMP_ROOT/mudlib/data/login/s/$id.o"
  cp "$FIXTURE/user/king.o" "$TEMP_ROOT/mudlib/data/user/s/$id.o"
  awk -v id="$id" -v hash="$PASSWORD_HASH" '
    /^id / { print "id \"" id "\""; next }
    /^password / { print "password \"" hash "\""; next }
    /^dbase / {
      gsub(/"id":"king"/, "\"id\":\"" id "\"")
      gsub(/"name":"KING"/, "\"name\":\"社交測試" id "\"")
      print
      next
    }
    { print }
  ' "$TEMP_ROOT/mudlib/data/login/s/$id.o" > "$TEMP_ROOT/$id.login"
  mv "$TEMP_ROOT/$id.login" "$TEMP_ROOT/mudlib/data/login/s/$id.o"
  awk -v id="$id" '
    /^id / { print "id \"" id "\""; next }
    /^name / { print "name \"社交測試" id "\""; next }
    # save_object 的角色 id/name 位於單行 dbase mapping；必須同步改寫，
    # 否則兩個登入帳號會被 Driver 誤判為同一個線上人物。
    /^dbase / {
      gsub(/"id":"king"/, "\"id\":\"" id "\"")
      gsub(/"name":"KING"/, "\"name\":\"社交測試" id "\"")
      print
      next
    }
    { print }
  ' "$TEMP_ROOT/mudlib/data/user/s/$id.o" > "$TEMP_ROOT/$id.user"
  mv "$TEMP_ROOT/$id.user" "$TEMP_ROOT/mudlib/data/user/s/$id.o"
done

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 & driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const net=require("net"),d=Date.now()+30000;(function p(){const s=net.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 & bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const http=require("http"),d=Date.now()+10000;(function p(){http.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/social.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_KING_PASSWORD="$TEST_PASSWORD" node "$REPO_ROOT/scripts/test_original_social_communication_runtime_e2e.mjs" | tee "$LOG"
for marker in SOCIAL_PASS:two-player-item-handoff SOCIAL_PASS:say-room-utf8 SOCIAL_PASS:tell-private-routing SOCIAL_PASS:reply-routing SOCIAL_PASS:missing-player-original-error SOCIAL_PASS:disconnect-relogin ORIGINAL_SOCIAL_COMMUNICATION_RUNTIME_PASS; do
  grep -Fq "$marker" "$LOG" || { echo "ORIGINAL SOCIAL RUNTIME FAIL：缺少 $marker" >&2; exit 1; }
done
echo "ORIGINAL SOCIAL / COMMUNICATION RUNTIME PASS：say／tell／reply／UTF-8／離線／重登均由雙玩家真實 Driver Session 通過。"
