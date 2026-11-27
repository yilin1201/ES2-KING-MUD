#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
FIXTURE="${2:-$REPO_ROOT/.runtime/game-completion-fixture/king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"; WEB_PORT="$((48000 + $$ % 1000))"; driver_pid=""; bridge_pid=""
PASSWORD="$(openssl rand -hex 16)"; SALT="$(openssl rand -hex 4)"
HASH="$(ES2_HASH_PASSWORD="$PASSWORD" ES2_HASH_SALT="$SALT" node -e 'const c=require("crypto"),d=c.createHash("md5").update(process.env.ES2_HASH_PASSWORD+process.env.ES2_HASH_SALT).digest(),a="./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";let e="";for(let i=0;i<3;i++){let v=d[i*5]|d[i*5+1]<<8|d[i*5+2]<<16;for(let s=0;s<24;s+=6)e+=a[v>>s&63]}e+=a[d[15]&63]+a[d[15]>>6&63];process.stdout.write("$1$"+process.env.ES2_HASH_SALT+"$"+e)')"
cleanup(){ local s=$?; [[ -z "$bridge_pid" ]]||kill "$bridge_pid" 2>/dev/null||true; [[ -z "$driver_pid" ]]||kill "$driver_pid" 2>/dev/null||true; wait "$bridge_pid" 2>/dev/null||true;wait "$driver_pid" 2>/dev/null||true; ((s))&&echo "YANWUJIE RUNTIME FAIL：$TEMP_ROOT" >&2||rm -rf "$TEMP_ROOT";return "$s";};trap cleanup EXIT INT TERM
test -x "$DRIVER_BIN";test -f "$FIXTURE/login/king.o";test -f "$FIXTURE/user/king.o"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib";cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf";cp -a "$REPO_ROOT/es2_king_expansion/runtime/mudlib/." "$TEMP_ROOT/mudlib/"
rm -f "$TEMP_ROOT/mudlib/bin/std/race/humanoid.b"
mkdir -p "$TEMP_ROOT/mudlib/data/login/k" "$TEMP_ROOT/mudlib/data/user/k" "$TEMP_ROOT/mudlib/log"
cp "$FIXTURE/login/king.o" "$TEMP_ROOT/mudlib/data/login/k/king.o";cp "$FIXTURE/user/king.o" "$TEMP_ROOT/mudlib/data/user/k/king.o"
awk -v h="$HASH" '/^password /{print "password \"" h "\"";next}{print}' "$TEMP_ROOT/mudlib/data/login/k/king.o" >"$TEMP_ROOT/x";mv "$TEMP_ROOT/x" "$TEMP_ROOT/mudlib/data/login/k/king.o"
(cd "$TEMP_ROOT";exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 & driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const n=require("net"),d=Date.now()+30000;(function p(){const s=n.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet";ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 & bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_KING_PASSWORD="$PASSWORD" node "$REPO_ROOT/scripts/test_yanwujie_runtime_e2e.mjs" | tee "$TEMP_ROOT/test.log"
for m in YANWUJIE_PASS:enter YANWUJIE_PASS:defeat-reconstruct-no-ghost YANWUJIE_PASS:out YANWUJIE_RUNTIME_PASS;do grep -Fq "$m" "$TEMP_ROOT/test.log";done
echo "YANWUJIE RUNTIME PASS：Original HP exhausted death branch 已於 arena_zone 被攔截，角色保持 living 並原地重塑。"
