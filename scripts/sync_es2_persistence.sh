#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${ES2_RUNTIME_DIR:-/opt/es2-king/runtime}"
SAVE_DIR="${ES2_SAVE_DIR:-/var/lib/es2-king/data}"
RUNTIME_DATA="$RUNTIME_DIR/mudlib/data"

test -d "$RUNTIME_DATA" || {
  echo "PERSISTENCE SYNC FAIL：找不到 Runtime data：$RUNTIME_DATA" >&2
  exit 1
}

# Same Path／相同路徑：掛載點若直接位於 mudlib/data，不需要重複複製。
if [[ "$SAVE_DIR" == "$RUNTIME_DATA" ]]; then
  exit 0
fi

mkdir -p "$SAVE_DIR"

# Runtime → Backing／執行資料同步至備份層：玩家存檔仍由 Original save_object() 產生，
# 本腳本只複製完成後的檔案，不解析、不記錄 Password、Hash 或角色內容。
cp -a "$RUNTIME_DATA/." "$SAVE_DIR/"
