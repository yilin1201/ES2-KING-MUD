#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/m30/.runtime/es2-king}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((44000 + $$ % 1000))"
# 特殊字元相容測試：前導 ! 與 Base64 符號會觸發舊 Telnet 命令語意，必須仍能安全認領。
CLAIM_TOKEN="${ES2_TEST_CLAIM_TOKEN:-!$(openssl rand -base64 48 | tr -d '\n')}"
CLAIM_TRANSPORT="es2claim1:$(printf '%s' "$CLAIM_TOKEN" | od -An -tx1 -v | tr -d ' \n')"
WRONG_TOKEN="?$(openssl rand -base64 48 | tr -d '\n')"
KING_PASSWORD="$(openssl rand -hex 16)"
PLAYER_PASSWORD="$(openssl rand -hex 16)"
GAME_COMPLETION_FIXTURE_DIR="${ES2_GAME_COMPLETION_FIXTURE_DIR:-}"
SOURCE_HASH_BEFORE="$(sha256sum "$SOURCE_RUNTIME/mudlib/adm/daemons/logind.c" | cut -d' ' -f1)"
driver_pid=""
bridge_pid=""

cleanup() {
  status=$?
  if (( status != 0 )); then
    echo "M30 KING CLAIM E2E FAIL（測試失敗）：Runtime 診斷紀錄如下（不輸出測試秘密）。" >&2
    tail -n 80 "$TEMP_ROOT/mudlib/log/debug.log" 2>/dev/null || true
    tail -n 80 "$TEMP_ROOT/mudlib/log/log" 2>/dev/null || true
    tail -n 80 "$TEMP_ROOT/driver.stdout" 2>/dev/null || true
    tail -n 80 "$TEMP_ROOT/bridge.stdout" 2>/dev/null || true
  fi
  [[ -z "$bridge_pid" ]] || kill "$bridge_pid" 2>/dev/null || true
  [[ -z "$driver_pid" ]] || kill "$driver_pid" 2>/dev/null || true
  wait "$bridge_pid" 2>/dev/null || true
  wait "$driver_pid" 2>/dev/null || true
  # Debug Retention／除錯保留：僅由本機明確要求時保留不含實際報告輸出的暫存 Runtime。
  if [[ "${ES2_TEST_KEEP_TEMP:-0}" == "1" ]]; then
    echo "M30 TEST TEMP RETAINED：$TEMP_ROOT" >&2
  else
    rm -rf -- "$TEMP_ROOT"
  fi
  return "$status"
}
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"
mkdir -p "$TEMP_ROOT"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
# Driver Contract Evidence／Driver 契約證據：Final Runtime Assertion 需要核對
# Neolith 的 CR/LF 處理；只複製唯讀來源證據，不複製或重建整套 Driver。
mkdir -p "$TEMP_ROOT/neolith/src"
cp "$SOURCE_RUNTIME/neolith/src/comm.c" "$TEMP_ROOT/neolith/src/comm.c"
mkdir -p "$TEMP_ROOT/mudlib/data/login/k" "$TEMP_ROOT/mudlib/data/user/k" "$TEMP_ROOT/mudlib/log"
bash "$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"
bash "$REPO_ROOT/scripts/assert_m30_final_runtime.sh" "$TEMP_ROOT"

# Runtime Secret（執行階段秘密）只注入 Neolith process；不寫檔、不輸出。
(
  cd "$TEMP_ROOT"
  ES2_KING_CLAIM_TOKEN="$CLAIM_TOKEN" exec "$DRIVER_BIN" -f neolith.conf
) > "$TEMP_ROOT/driver.stdout" 2>&1 &
driver_pid=$!

ES2_TEST_PORT=4000 node -e '
  const net = require("net");
  const deadline = Date.now() + 30000;
  function probe() {
    const socket = net.createConnection({ host: "127.0.0.1", port: Number(process.env.ES2_TEST_PORT) });
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

# Bridge Readiness／橋接服務就緒等待：避免把剛啟動、尚未 listen 的毫秒級競態誤判為健康檢查失敗。
ES2_TEST_PORT="$WEB_PORT" node -e '
  const http = require("http");
  const deadline = Date.now() + 10000;
  function probe() {
    http.get({ host: "127.0.0.1", port: Number(process.env.ES2_TEST_PORT), path: "/health" }, response => {
      response.resume();
      if (response.statusCode === 200) process.exit(0);
      Date.now() < deadline ? setTimeout(probe, 100) : process.exit(1);
    }).on("error", () => Date.now() < deadline ? setTimeout(probe, 100) : process.exit(1));
  }
  probe();
'

# Deployment Smoke／部署冒煙測試：同一條正式等效鏈驗證首頁、/health、WebSocket 與登入提示。
node "$REPO_ROOT/scripts/test_m30_deployment_smoke.mjs" "http://127.0.0.1:$WEB_PORT"

ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" \
ES2_E2E_SAVE_DIR="$TEMP_ROOT/mudlib/data" \
ES2_E2E_CLAIM_TOKEN="$CLAIM_TOKEN" \
ES2_E2E_WRONG_TOKEN="$WRONG_TOKEN" \
ES2_E2E_KING_PASSWORD="$KING_PASSWORD" \
ES2_E2E_PLAYER_PASSWORD="$PLAYER_PASSWORD" \
node "$REPO_ROOT/scripts/test_m30_king_claim_e2e.mjs"

# Game Completion Fixture／遊戲完成測試角色：只在本機明確指定輸出目錄時，
# 從「真正完成 save / quit / relogin 的 Runtime」複製 KING save_object 結果。
# Login save 可能含 Original password hash，因此不提交 Repository；fixture 只供同一台開發機後續 Full Journey 使用。
if [[ -n "$GAME_COMPLETION_FIXTURE_DIR" ]]; then
  case "$GAME_COMPLETION_FIXTURE_DIR" in
    "$REPO_ROOT"/.runtime/*|.runtime/*) ;;
    *) echo "M30 KING CLAIM FAIL：Game Completion fixture 只允許 .runtime 測試路徑。" >&2; exit 1 ;;
  esac
  rm -rf -- "$GAME_COMPLETION_FIXTURE_DIR"
  mkdir -p "$GAME_COMPLETION_FIXTURE_DIR/login" "$GAME_COMPLETION_FIXTURE_DIR/user"
  cp "$TEMP_ROOT/mudlib/data/login/k/king.o" "$GAME_COMPLETION_FIXTURE_DIR/login/king.o"
  cp "$TEMP_ROOT/mudlib/data/user/k/king.o" "$GAME_COMPLETION_FIXTURE_DIR/user/king.o"
  chmod 600 "$GAME_COMPLETION_FIXTURE_DIR/login/king.o" "$GAME_COMPLETION_FIXTURE_DIR/user/king.o"
  printf '%s\n' 'LOCAL ONLY：由 M30 real Runtime 產生；可能含 Original password hash，禁止 commit。' > "$GAME_COMPLETION_FIXTURE_DIR/README.LOCAL_ONLY"
  echo "GAME COMPLETION FIXTURE READY：已由 real Runtime 產生本機 KING fixture。"
fi

# Secret Exposure Check（秘密洩漏檢查）：只判斷是否存在，不把秘密值印到報告。
if grep -R -Fq -- "$CLAIM_TOKEN" "$TEMP_ROOT/mudlib/log" "$TEMP_ROOT/driver.stdout" "$TEMP_ROOT/bridge.stdout" \
  || grep -R -Fq -- "$CLAIM_TRANSPORT" "$TEMP_ROOT/mudlib/log" "$TEMP_ROOT/driver.stdout" "$TEMP_ROOT/bridge.stdout"; then
  echo "M30 KING CLAIM FAIL（測試失敗）：Claim Token 出現在 Runtime Log。" >&2
  exit 1
fi
if grep -R -Fq --exclude-dir=.git --exclude-dir=.runtime --exclude-dir=node_modules \
  -- "$CLAIM_TOKEN" "$REPO_ROOT" \
  || grep -R -Fq --exclude-dir=.git --exclude-dir=.runtime --exclude-dir=node_modules \
  -- "$CLAIM_TRANSPORT" "$REPO_ROOT"; then
  echo "M30 KING CLAIM FAIL（測試失敗）：臨時 Claim Token 出現在 Repository artifact。" >&2
  exit 1
fi

SOURCE_HASH_AFTER="$(sha256sum "$SOURCE_RUNTIME/mudlib/adm/daemons/logind.c" | cut -d' ' -f1)"
test "$SOURCE_HASH_BEFORE" = "$SOURCE_HASH_AFTER"
echo "M30 ORIGINAL HASH PASS（測試通過）：Original ES2 source hash 未被 Runtime Overlay 修改。"
