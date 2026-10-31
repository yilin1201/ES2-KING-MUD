#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
FIXTURE="${2:-$REPO_ROOT/.runtime/game-completion-fixture/king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"; WEB_PORT="$((47000 + $$ % 1000))"
TEST_PASSWORD="$(openssl rand -hex 16)"; PASSWORD_SALT="$(openssl rand -hex 4)"
PASSWORD_HASH="$(ES2_HASH_PASSWORD="$TEST_PASSWORD" ES2_HASH_SALT="$PASSWORD_SALT" node -e 'const c=require("crypto"),d=c.createHash("md5").update(process.env.ES2_HASH_PASSWORD+process.env.ES2_HASH_SALT).digest(),a="./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";let e="";for(let i=0;i<3;i++){let v=d[i*5]|d[i*5+1]<<8|d[i*5+2]<<16;for(let s=0;s<24;s+=6)e+=a[(v>>s)&63]}e+=a[d[15]&63]+a[(d[15]>>6)&63];process.stdout.write("$1$"+process.env.ES2_HASH_SALT+"$"+e)')"
driver_pid=""; bridge_pid=""
cleanup(){ s=$?; [[ -z "$bridge_pid" ]]||kill "$bridge_pid" 2>/dev/null||true; [[ -z "$driver_pid" ]]||kill "$driver_pid" 2>/dev/null||true; wait "$bridge_pid" 2>/dev/null||true; wait "$driver_pid" 2>/dev/null||true; if ((s));then echo "COLD PLUM RUNTIME FAIL：$TEMP_ROOT" >&2;else rm -rf "$TEMP_ROOT";fi; return "$s"; }; trap cleanup EXIT INT TERM
test -x "$DRIVER_BIN"; test -f "$FIXTURE/login/king.o"; test -f "$FIXTURE/user/king.o"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"; cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
"$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"
mkdir -p "$TEMP_ROOT/mudlib/data/login/k" "$TEMP_ROOT/mudlib/data/user/k" "$TEMP_ROOT/mudlib/log"
cp "$FIXTURE/login/king.o" "$TEMP_ROOT/mudlib/data/login/k/king.o"; cp "$FIXTURE/user/king.o" "$TEMP_ROOT/mudlib/data/user/k/king.o"
awk -v hash="$PASSWORD_HASH" '/^password /{print "password \"" hash "\"";next}{print}' "$TEMP_ROOT/mudlib/data/login/k/king.o" > "$TEMP_ROOT/x"; mv "$TEMP_ROOT/x" "$TEMP_ROOT/mudlib/data/login/k/king.o"
(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 & driver_pid=$!
ES2_TEST_PORT=4000 node -e 'const n=require("net"),d=Date.now()+30000;(function p(){let s=n.createConnection({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT});s.once("connect",()=>{s.destroy();process.exit(0)});s.once("error",()=>{s.destroy();Date.now()<d?setTimeout(p,100):process.exit(1)})})()'
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 & bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'
LOG="$TEMP_ROOT/cold-plum.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_KING_PASSWORD="$TEST_PASSWORD" node "$REPO_ROOT/scripts/test_cold_plum_arena_runtime_e2e.mjs" | tee "$LOG"
for marker in \
  COLD_PLUM_PASS:king-99-skills-admin \
  COLD_PLUM_PASS:wuji-enter-yanwujie \
  COLD_PLUM_PASS:npc-attributes-skills \
  COLD_PLUM_PASS:arena-defeat-protection \
  COLD_PLUM_PASS:mirror-mind-state \
  COLD_PLUM_PASS:phase1-cold-plum-combat \
  COLD_PLUM_PASS:aojian-phase-transition-30 \
  COLD_PLUM_PASS:aojian-combat-runtime \
  COLD_PLUM_PASS:jianling-fengsao-random-combat \
  COLD_PLUM_PASS:aojian-reset-to-cold-plum \
  COLD_PLUM_PASS:king-combat-mei \
  COLD_PLUM_PASS:yanwujie-out-wuji \
  COLD_PLUM_PASS:save-quit-relogin-restore \
  COLD_PLUM_RUNTIME_PASS
do
  grep -Fq "$marker" "$LOG"
done
echo "COLD PLUM RUNTIME PASS：真實 Neolith Driver 已驗證 KING 八屬性 99、KING 技能 Lv.300、冷梅莊技能、演武界雙向拓撲、梅寒霜 50/300、明鏡止水、冷梅 Phase 1、30 招傲劍切換、傲劍 Phase 2、劍領風騷隨機六段連擊、戰後冷梅 reset、Combat、Arena 敗北保護及 save／quit／relogin／restore。"
