#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((49000 + $$ % 700))"
TEST_PASSWORD="$(openssl rand -hex 16)"
driver_pid=""; bridge_pid=""
cleanup(){
  status=$?
  [[ -z "$bridge_pid" ]] || kill "$bridge_pid" 2>/dev/null || true
  [[ -z "$driver_pid" ]] || kill "$driver_pid" 2>/dev/null || true
  wait "$bridge_pid" 2>/dev/null || true
  wait "$driver_pid" 2>/dev/null || true
  if ((status)); then
    echo "ORIGINAL PLAYER CREATION E2E FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2
    for log in driver.stdout bridge.stdout player-creation.log; do
      if [[ -s "$TEMP_ROOT/$log" ]]; then
        echo "--- $log (last 200 lines) ---" >&2
        tail -n 200 "$TEMP_ROOT/$log" >&2
      fi
    done
    echo "--- Runtime log files ---" >&2
    find "$TEMP_ROOT/mudlib/log" "$TEMP_ROOT/mudlib/logs" "$TEMP_ROOT/log" -maxdepth 3 -type f -print 2>/dev/null | while IFS= read -r file; do
      echo "--- $file (last 100 lines) ---" >&2
      tail -n 100 "$file" >&2 2>/dev/null || true
    done
    echo "--- Runtime files (max depth 2) ---" >&2
    find "$TEMP_ROOT" -maxdepth 2 -type f -printf '%p\\n' 2>/dev/null | head -n 100 >&2
  else
    rm -rf -- "$TEMP_ROOT"
  fi
  return "$status"
}
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
bash "$REPO_ROOT/scripts/apply_race_phase2_runtime.sh" "$TEMP_ROOT"
bash "$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"

# 確認 E2E 臨時 Runtime 確實使用 KING gender prompt adapter，且 input_prompt 模組存在。
python3 - "$TEMP_ROOT/mudlib" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1])
logind = (root / "adm/daemons/logind.c").read_text(encoding="utf-8", errors="replace")
input_feature = (root / "feature/user/input.c").read_text(encoding="utf-8", errors="replace")
if 'write ("\\n您要扮演的哪種性別的角色? (Male / Female) ");' not in logind:
    raise SystemExit("KING_GENDER_PROMPT_RUNTIME_FAIL: explicit gender prompt missing")
if "void input_prompt" not in input_feature:
    raise SystemExit("KING_GENDER_PROMPT_RUNTIME_FAIL: input_prompt feature missing")
print("KING_GENDER_PROMPT_RUNTIME_PASS")
PY
# Test-only Host Throttle／測試專用主機限流處理：12 個種族皆由同一個 localhost 建立，
# 會觸發 Original ES2 的每 IP 十帳號保護。只在 mktemp Runtime 套用既有 KING
# bootstrap 政策，不修改來源保存區，也不把「同 IP 大量創角」宣稱為正式 Gameplay。
# No-match is normal: avoid set -e/pipefail abort when antispam is already disabled.
# Preserve real grep errors (status > 1) instead of silently bypassing the gate.
if grep -RIl '^[[:space:]]*#define[[:space:]]\+ENABLE_ANTISPAM' \
  "$TEMP_ROOT/mudlib/include" "$TEMP_ROOT/mudlib/adm" > "$TEMP_ROOT/antispam-files" 2>"$TEMP_ROOT/antispam-grep.stderr"; then
  while IFS= read -r file; do
    sed -i 's/^[[:space:]]*#define[[:space:]]\+ENABLE_ANTISPAM.*/\/\/ ES2-KING isolated test: ENABLE_ANTISPAM disabled/' "$file"
  done < "$TEMP_ROOT/antispam-files"
else
  grep_status=$?
  if (( grep_status != 1 )); then
    cat "$TEMP_ROOT/antispam-grep.stderr" >&2
    echo 'ORIGINAL PLAYER CREATION E2E BLOCKED：無法確認測試 Runtime 的防洗版設定。' >&2
    exit 1
  fi
fi
if grep -R '^[[:space:]]*#define[[:space:]]\+ENABLE_ANTISPAM' \
  "$TEMP_ROOT/mudlib/include" "$TEMP_ROOT/mudlib/adm" 2>/dev/null; then
  echo 'ORIGINAL PLAYER CREATION E2E BLOCKED：測試 Runtime 仍啟用 localhost 創角限流。' >&2
  exit 1
fi
mkdir -p "$TEMP_ROOT/mudlib/data/login"/{a..z} "$TEMP_ROOT/mudlib/data/login"/{0..9} "$TEMP_ROOT/mudlib/data/user"/{a..z} "$TEMP_ROOT/mudlib/data/user"/{0..9} "$TEMP_ROOT/mudlib/log"
for id in humanprobe avatarprobe blackprobe yenprobe wooprobe dingprobe jiaoprobe rainprobe ashprobe headprobe yaksaprobe malikprobe 7probe; do
  initial="${id:0:1}"
  rm -f "$TEMP_ROOT/mudlib/data/login/$initial/$id.o" "$TEMP_ROOT/mudlib/data/user/$initial/$id.o"
done

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 & driver_pid=$!
# Passive Listen Check／被動監聽檢查：不可主動連線後立即斷線，Neolith 可能因此收到 SIGPIPE。
command -v ss >/dev/null 2>&1 || { echo 'ORIGINAL PLAYER CREATION E2E BLOCKED：缺少 ss 被動監聽檢查工具。' >&2; exit 1; }
driver_ready=0
for _ in $(seq 1 300); do
  if ! kill -0 "$driver_pid" 2>/dev/null; then
    echo 'ORIGINAL PLAYER CREATION E2E FAIL：Neolith 在 Port 4000 穩定前已退出。' >&2
    tail -n 100 "$TEMP_ROOT/driver.stdout" >&2 2>/dev/null || true
    exit 1
  fi
  if ss -H -ltn 2>/dev/null | grep -Eq 'LISTEN.*:4000[[:space:]]'; then
    driver_ready=1
    break
  fi
  sleep 0.1
done
if (( ! driver_ready )); then
  echo 'ORIGINAL PLAYER CREATION E2E FAIL：Port 4000 未進入 LISTENING。' >&2
  tail -n 100 "$TEMP_ROOT/driver.stdout" >&2 2>/dev/null || true
  exit 1
fi
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT=4000 PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 & bridge_pid=$!
echo "E2E_STAGE: waiting for WebTelnet bridge health on port $WEB_PORT"
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'
echo "E2E_STAGE: WebTelnet bridge health passed"

LOG="$TEMP_ROOT/player-creation.log"
# 將 Node 測試標準錯誤一併寫入 player-creation.log，避免 E2E 例外被 cleanup 遺漏。
echo "E2E_STAGE: starting player creation Node test"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_SAVE_DIR="$TEMP_ROOT/mudlib/data" ES2_E2E_PASSWORD="$TEST_PASSWORD" node "$REPO_ROOT/scripts/test_original_player_creation_e2e.mjs" 2>&1 | tee "$LOG"
echo "E2E_STAGE: player creation Node test returned"
for marker in ORIGINAL_PLAYER_CREATION_HUMAN_E2E_PASS ORIGINAL_PLAYER_CREATION_AVATAR_E2E_PASS ORIGINAL_PLAYER_CREATION_NUMERIC_ID_E2E_PASS ES2M_PLAYER_CREATION_12_RACES_E2E_PASS; do grep -Fq "$marker" "$LOG"; done
# Runtime evidence must be free of compilation/runtime errors, not merely JS markers.
test -r "$TEMP_ROOT/driver.stdout" || { echo 'ORIGINAL PLAYER CREATION E2E BLOCKED：缺少 Driver log。' >&2; exit 1; }
if grep -En '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable|Undefined function' "$TEMP_ROOT/driver.stdout"; then
  echo 'ORIGINAL PLAYER CREATION E2E FAIL：Driver Log 存在編譯／執行錯誤。' >&2
  exit 1
fi
echo "ES2M PLAYER CREATION E2E：12 種族由零存檔逐一驗證創角、世界指令、save、quit、relogin。"
