#!/usr/bin/env bash
set -euo pipefail

# Neolith LPC preload gate／實際啟動驅動程式並載入 look 指令，不能只做字串比對。
RUNTIME="${1:-/opt/es2-king/runtime}"
DRIVER_BIN="${ES2_DRIVER_BIN:-/opt/es2-king/bin/neolith}"
if [[ ! -x "$DRIVER_BIN" ]]; then
  DRIVER_BIN="$RUNTIME/neolith/out/build/linux/src/Debug/neolith"
fi
if [[ ! -x "$DRIVER_BIN" ]]; then
  echo "LOOK PRELOAD FAIL：找不到可執行的 Neolith driver。" >&2
  exit 1
fi
[[ -f "$RUNTIME/neolith.conf" ]] || {
  echo "LOOK PRELOAD FAIL：Runtime 缺少 neolith.conf。" >&2
  exit 1
}

APP="$RUNTIME/mudlib/adm/apps/es2_king_preload_look_test.c"
LOG="$(mktemp)"
TEST_CONF="$RUNTIME/neolith.look-preload.conf"
DEBUG_LOG="$RUNTIME/mudlib/log/look-preload-debug.log"
INPUT_DIR="$(mktemp -d)"
INPUT_FIFO="$INPUT_DIR/stdin"
INPUT_PID=""
cleanup() {
  if [[ -n "$INPUT_PID" ]]; then kill "$INPUT_PID" 2>/dev/null || true; wait "$INPUT_PID" 2>/dev/null || true; fi
  rm -rf -- "$INPUT_DIR"
  rm -f -- "$APP" "$TEST_CONF" "$DEBUG_LOG"
  if [[ "${KEEP_LOOK_PRELOAD_LOG:-0}" != "1" ]]; then rm -f -- "$LOG"; else echo "LOOK PRELOAD LOG: $LOG"; fi
}
trap cleanup EXIT

mkdir -p "$(dirname "$APP")" "$RUNTIME/mudlib/log"
# Debug logging／Original neolith.conf 將編譯錯誤寫入 mudlib/log/debug.log；測試使用獨立 log，確保錯誤可見。
sed -E \
  -e 's/^[[:space:]]*DebugLogFile[[:space:]]+.*/DebugLogFile look-preload-debug.log/' \
  -e 's/^[[:space:]]*Port[[:space:]]+.*/# Port disabled for look preload test/' \
  "$RUNTIME/neolith.conf" > "$TEST_CONF"
rm -f -- "$DEBUG_LOG"
cat > "$APP" <<'LPC'
// ES2-KING LOOK PRELOAD GATE／只在隔離建置 Runtime 中使用。
object connect(int port) { return this_object(); }

void logon()
{
    object look_object;
    mixed load_error;
    // Catch LPC compile/load exceptions and propagate them through the driver exit status.
    load_error = catch(look_object = load_object("/cmds/std/look"));
    if (load_error || !objectp(look_object)) {
        shutdown(1);
        return;
    }
    // shutdown(0) is the machine-readable PASS signal; console write output is not reliable in Docker.
    shutdown(0);
}
LPC

# Console stdin／Docker RUN 沒有互動式 stdin；維持 FIFO writer 開啟，避免 Neolith 在 logon 前收到 Console EOF。
mkfifo "$INPUT_FIFO"
tail -f /dev/null > "$INPUT_FIFO" &
INPUT_PID=$!
# 使用原 Runtime 設定，讓 driver 按實際 LPC 編譯／載入路徑處理 /cmds/std/look。
if ! (cd "$RUNTIME" && timeout 30 "$DRIVER_BIN" -f neolith.look-preload.conf -c mudlib/adm/apps/es2_king_preload_look_test.c < "$INPUT_FIFO") >"$LOG" 2>&1; then
  cat "$LOG" >&2
  [[ ! -f "$DEBUG_LOG" ]] || cat "$DEBUG_LOG" >&2
  echo "LOOK PRELOAD FAIL：Neolith 執行或載入 look.c 失敗。" >&2
  exit 1
fi
kill "$INPUT_PID" 2>/dev/null || true
wait "$INPUT_PID" 2>/dev/null || true
INPUT_PID=""
# Combine stdout and Neolith DebugLogFile／同時檢查 console output 與驅動程式診斷日誌。
cat "$LOG"
if [[ -f "$DEBUG_LOG" ]]; then cat "$DEBUG_LOG"; fi
# The LPC application returns exit 0 only after load_object succeeds; report pass from the shell.
if grep -Eiq '編譯時段錯誤|compile error|Runtime error|Cannot #include|Undefined variable|Undefined function|syntax error|Error in loading object: /cmds/std/look' "$LOG" "$DEBUG_LOG" 2>/dev/null; then
  echo "LOOK PRELOAD FAIL：driver log 出現 look.c 編譯／Runtime 錯誤。" >&2
  cat "$LOG" >&2
  [[ ! -f "$DEBUG_LOG" ]] || cat "$DEBUG_LOG" >&2
  exit 1
fi
echo "ES2-KING LOOK PRELOAD PASS／Neolith exit=0，load_object(\"/cmds/std/look\") 已完成且未回報編譯／Runtime 錯誤。"