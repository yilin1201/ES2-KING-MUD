#!/usr/bin/env bash
set -euo pipefail

# Original Internal Skill Runtime／Original 內功實機：重用既有 Neolith、mudlib 與 KING fixture，
# 所有角色修改都只發生在 mktemp 建立的隔離副本。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
FIXTURE="${2:-$REPO_ROOT/.runtime/game-completion-fixture/king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((46000 + $$ % 1000))"
TEST_PASSWORD="$(openssl rand -hex 16)"
PASSWORD_SALT="$(openssl rand -hex 4)"
PASSWORD_HASH="$(ES2_HASH_PASSWORD="$TEST_PASSWORD" ES2_HASH_SALT="$PASSWORD_SALT" node -e '
  const crypto = require("crypto");
  const digest = crypto.createHash("md5")
    .update(process.env.ES2_HASH_PASSWORD + process.env.ES2_HASH_SALT).digest();
  const alphabet = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
  let encoded = "";
  for (let i = 0; i < 3; i++) {
    const value = digest[i * 5] | (digest[i * 5 + 1] << 8) | (digest[i * 5 + 2] << 16);
    for (let shift = 0; shift < 24; shift += 6) encoded += alphabet[(value >> shift) & 63];
  }
  encoded += alphabet[digest[15] & 63] + alphabet[(digest[15] >> 6) & 63];
  process.stdout.write(`$1$${process.env.ES2_HASH_SALT}$${encoded}`);
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
    echo "ORIGINAL INTERNAL SKILL RUNTIME FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2
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
mkdir -p "$TEMP_ROOT/mudlib/data/login/f" "$TEMP_ROOT/mudlib/data/user/f" "$TEMP_ROOT/mudlib/log"
cp "$FIXTURE/login/king.o" "$TEMP_ROOT/mudlib/data/login/f/forceprobe.o"
cp "$FIXTURE/user/king.o" "$TEMP_ROOT/mudlib/data/user/f/forceprobe.o"

awk -v hash="$PASSWORD_HASH" '
  /^id / { print "id \"forceprobe\""; next }
  /^password / { print "password \"" hash "\""; next }
  { print }
' "$TEMP_ROOT/mudlib/data/login/f/forceprobe.o" > "$TEMP_ROOT/forceprobe.login"
mv "$TEMP_ROOT/forceprobe.login" "$TEMP_ROOT/mudlib/data/login/f/forceprobe.o"

# Isolated Diagnostic Player／隔離診斷角色：保留真實 save_object 格式，但改成非 KING ID，
# 避免正式 KING provisioning 覆蓋這個 Original dragon force 還原測試。
awk '
  /^dbase / {
    gsub(/"id":"king"/, "\"id\":\"forceprobe\"")
    gsub(/"name":"KING"/, "\"name\":\"內功測試\"")
  }
  { print }
' "$TEMP_ROOT/mudlib/data/user/f/forceprobe.o" > "$TEMP_ROOT/forceprobe.user"
mv "$TEMP_ROOT/forceprobe.user" "$TEMP_ROOT/mudlib/data/user/f/forceprobe.o"
grep -Fqx 'forceprobe (admin)' "$TEMP_ROOT/mudlib/adm/etc/wizlist" \
  || printf '%s\n' 'forceprobe (admin)' >> "$TEMP_ROOT/mudlib/adm/etc/wizlist"

(
  cd "$TEMP_ROOT"
  exec "$DRIVER_BIN" -f neolith.conf
) > "$TEMP_ROOT/driver.stdout" 2>&1 &
driver_pid=$!

ES2_TEST_PORT=4000 node -e '
  const net = require("net");
  const deadline = Date.now() + 30000;
  function probe() {
    const socket = net.createConnection({host:"127.0.0.1", port:Number(process.env.ES2_TEST_PORT)});
    socket.once("connect", () => { socket.destroy(); process.exit(0); });
    socket.once("error", () => { socket.destroy(); Date.now() < deadline ? setTimeout(probe, 100) : process.exit(1); });
  }
  probe();
'

(
  cd "$REPO_ROOT/webtelnet"
  ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs
) > "$TEMP_ROOT/bridge.stdout" 2>&1 &
bridge_pid=$!

ES2_TEST_PORT="$WEB_PORT" node -e '
  const http = require("http");
  const deadline = Date.now() + 10000;
  function probe() {
    http.get({host:"127.0.0.1", port:Number(process.env.ES2_TEST_PORT), path:"/health"}, response => {
      response.resume();
      if (response.statusCode === 200) process.exit(0);
      Date.now() < deadline ? setTimeout(probe, 100) : process.exit(1);
    }).on("error", () => Date.now() < deadline ? setTimeout(probe, 100) : process.exit(1));
  }
  probe();
'

JOURNEY_LOG="$TEMP_ROOT/original-internal-skill.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" \
ES2_E2E_KING_PASSWORD="$TEST_PASSWORD" \
ES2_E2E_ACCOUNT="forceprobe" \
node "$REPO_ROOT/scripts/test_original_internal_skill_runtime_e2e.mjs" | tee "$JOURNEY_LOG"

for marker in \
  "INTERNAL_SKILL_PASS:exists-enable-map" \
  "INTERNAL_SKILL_PASS:combat-integration" \
  "INTERNAL_SKILL_PASS:exert-resource" \
  "INTERNAL_SKILL_PASS:save-quit-relogin-restore" \
  "INVENTORY_PASS:autoload-combined-amount" \
  "ORIGINAL_INTERNAL_SKILL_RUNTIME_PASS"
do
  grep -Fq "$marker" "$JOURNEY_LOG" || {
    echo "ORIGINAL INTERNAL SKILL RUNTIME FAIL：缺少 $marker" >&2
    exit 1
  }
done

echo "ORIGINAL INTERNAL SKILL RUNTIME PASS：Original force mapping、enable、exert、資源消耗、戰鬥、save／quit／relogin／restore 均由真實 Driver 通過；Inventory autoload 數量亦已精確還原。"
