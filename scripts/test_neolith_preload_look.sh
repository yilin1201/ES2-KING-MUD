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
cleanup() {
  rm -f -- "$APP"
  if [[ "${KEEP_LOOK_PRELOAD_LOG:-0}" != "1" ]]; then rm -f -- "$LOG"; else echo "LOOK PRELOAD LOG: $LOG"; fi
}
trap cleanup EXIT

mkdir -p "$(dirname "$APP")"
cat > "$APP" <<'LPC'
// ES2-KING LOOK PRELOAD GATE／只在隔離建置 Runtime 中使用。
object connect(int port) { return this_object(); }

void logon()
{
    object look_object;
    look_object = load_object("/cmds/std/look");
    if (!objectp(look_object)) {
        write("ES2_KING_LOOK_PRELOAD_FAIL\n");
        shutdown(1);
        return;
    }
    write("ES2_KING_LOOK_PRELOAD_PASS\n");
    shutdown(0);
}
LPC

# 使用原 Runtime 設定，讓 driver 按實際 LPC 編譯／載入路徑處理 /cmds/std/look。
if ! (cd "$RUNTIME" && timeout 30 "$DRIVER_BIN" -f neolith.conf -c mudlib/adm/apps/es2_king_preload_look_test.c) >"$LOG" 2>&1; then
  cat "$LOG" >&2
  echo "LOOK PRELOAD FAIL：Neolith 執行或載入 look.c 失敗。" >&2
  exit 1
fi
cat "$LOG"
grep -Fq "ES2_KING_LOOK_PRELOAD_PASS" "$LOG" || {
  echo "LOOK PRELOAD FAIL：driver 未回報 look.c 載入成功。" >&2
  exit 1
}
if grep -Eiq '編譯時段錯誤|compile error|Runtime error|Cannot #include|Undefined variable|Undefined function|syntax error' "$LOG"; then
  echo "LOOK PRELOAD FAIL：driver log 出現編譯／Runtime 錯誤。" >&2
  exit 1
fi
echo "ES2-KING LOOK PRELOAD PASS／Neolith 已實際載入 /cmds/std/look。"
