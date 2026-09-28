#!/usr/bin/env bash
set -euo pipefail

# KING Weapon Targeted Runtime E2E／沿用既有真 Driver + KING fixture，
# 所有 save 與密碼改寫只存在 mktemp Runtime，不碰正式玩家或 Neon。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
FIXTURE="${2:-$REPO_ROOT/.runtime/game-completion-fixture/king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((47500 + $$ % 1000))"
TEST_PASSWORD="$(openssl rand -hex 16)"
PASSWORD_SALT="$(openssl rand -hex 4)"
PASSWORD_HASH="$(ES2_HASH_PASSWORD="$TEST_PASSWORD" ES2_HASH_SALT="$PASSWORD_SALT" node -e '
const c=require("crypto"),d=c.createHash("md5").update(process.env.ES2_HASH_PASSWORD+process.env.ES2_HASH_SALT).digest(),a="./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";let e="";for(let i=0;i<3;i++){const v=d[i*5]|d[i*5+1]<<8|d[i*5+2]<<16;for(let s=0;s<24;s+=6)e+=a[(v>>s)&63]}e+=a[d[15]&63]+a[(d[15]>>6)&63];process.stdout.write("$1$"+process.env.ES2_HASH_SALT+"$"+e)
')"
driver_pid=""; bridge_pid=""
cleanup(){ status=$?; [[ -z "$bridge_pid" ]]||kill "$bridge_pid" 2>/dev/null||true; [[ -z "$driver_pid" ]]||kill "$driver_pid" 2>/dev/null||true; wait "$bridge_pid" 2>/dev/null||true; wait "$driver_pid" 2>/dev/null||true; if ((status));then echo "KING WEAPON RUNTIME FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2;else rm -rf -- "$TEMP_ROOT";fi; return "$status"; }
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"; test -f "$FIXTURE/login/king.o"; test -f "$FIXTURE/user/king.o"
cp -a "$RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
"$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"
mkdir -p "$TEMP_ROOT/mudlib/data/login/k" "$TEMP_ROOT/mudlib/data/user/k" "$TEMP_ROOT/mudlib/log"
awk -v hash="$PASSWORD_HASH" '/^password /{print "password \"" hash "\"";next}{print}' "$FIXTURE/login/king.o" > "$TEMP_ROOT/mudlib/data/login/k/king.o"
cp "$FIXTURE/user/king.o" "$TEMP_ROOT/mudlib/data/user/k/king.o"

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 & driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const n=require("net"),d=Date.now()+30000;(function p(){const s=n.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 & bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/king-weapon.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_KING_PASSWORD="$TEST_PASSWORD" node "$REPO_ROOT/scripts/test_king_weapon_runtime_e2e.mjs" | tee "$LOG"
grep -Fq KING_WEAPON_RUNTIME_E2E_PASS "$LOG"
if rg -n '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable' "$TEMP_ROOT/driver.stdout"; then echo "KING WEAPON RUNTIME FAIL：Driver Log 存在 Code Error。" >&2; exit 1; fi
echo "KING WEAPON RUNTIME E2E PASS：五武器、空手登入、dual-wield、twohanded、save／quit／relogin 與 duplicate protection 已通過。"
