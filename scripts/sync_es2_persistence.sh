#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${ES2_RUNTIME_DIR:-/opt/es2-king/runtime}"
SAVE_DIR="${ES2_SAVE_DIR:-/var/lib/es2-king/data}"
RUNTIME_DATA="$RUNTIME_DIR/mudlib/data"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

test -d "$RUNTIME_DATA" || {
  echo "PERSISTENCE SYNC FAIL：找不到 Runtime data：$RUNTIME_DATA" >&2
  exit 1
}

# Local backing 保留既有 process-restart 行為。
if [[ "$SAVE_DIR" != "$RUNTIME_DATA" ]]; then
  mkdir -p "$SAVE_DIR"
  cp -a "$RUNTIME_DATA/." "$SAVE_DIR/"
fi

# Durable backing 只封裝 Original save_object() 已完成的檔案，不解析或輸出角色內容。
if [[ -n "${DATABASE_URL:-}" ]]; then
  python3 "$SCRIPT_DIR/es2_neon_persistence.py" upload --source "$RUNTIME_DATA"
fi
