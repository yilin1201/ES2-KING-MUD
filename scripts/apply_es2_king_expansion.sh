#!/usr/bin/env bash
set -euo pipefail

# Overlay／覆蓋層：只寫入獨立 ES2-KING Runtime，不修改 Original 保存來源。
TARGET="${1:-.runtime/es2-king}"
SOURCE="es2_king_expansion/runtime/mudlib"

test -d "$TARGET/mudlib" || {
  echo "EXPANSION APPLY FAIL：缺少 $TARGET/mudlib，請先建立獨立 Runtime。" >&2
  exit 1
}
test -d "$SOURCE"

cp -a "$SOURCE/." "$TARGET/mudlib/"
echo "ES2-KING EXPANSION APPLY PASS／Expansion 已套用至獨立 Runtime：$TARGET"
