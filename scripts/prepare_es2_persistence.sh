#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${ES2_RUNTIME_DIR:-/opt/es2-king/runtime}"
SAVE_DIR="${ES2_SAVE_DIR:-/var/lib/es2-king/data}"
SEED_DIR="${ES2_DATA_SEED_DIR:-$RUNTIME_DIR/mudlib/data.seed}"
RUNTIME_DATA="$RUNTIME_DIR/mudlib/data"

test -d "$RUNTIME_DIR/mudlib" || {
  echo "PERSISTENCE FAIL：找不到 Runtime mudlib：$RUNTIME_DIR/mudlib" >&2
  exit 1
}

mkdir -p "$SAVE_DIR"

# Persistent Volume（持久磁碟）首次掛載時只補初始資料，絕不覆寫既有玩家存檔。
if [[ -d "$SEED_DIR" ]]; then
  cp -a --update=none "$SEED_DIR/." "$SAVE_DIR/"
fi

mkdir -p "$SAVE_DIR/login" "$SAVE_DIR/user" "$SAVE_DIR/mail"
for letter in {a..z}; do
  mkdir -p "$SAVE_DIR/login/$letter" "$SAVE_DIR/user/$letter" "$SAVE_DIR/mail/$letter"
done

if [[ -L "$RUNTIME_DATA" ]]; then
  [[ "$(readlink "$RUNTIME_DATA")" == "$SAVE_DIR" ]] || {
    echo "PERSISTENCE FAIL：$RUNTIME_DATA 已連到其他目錄。" >&2
    exit 1
  }
elif [[ -d "$RUNTIME_DATA" ]]; then
  # 容器映像中的空掛載點可安全替換；非空資料必須先成為 seed，避免遺失。
  if find "$RUNTIME_DATA" -mindepth 1 -print -quit | grep -q .; then
    cp -a --update=none "$RUNTIME_DATA/." "$SAVE_DIR/"
  fi
  rmdir "$RUNTIME_DATA" 2>/dev/null || {
    echo "PERSISTENCE FAIL：Runtime data 仍有未搬移項目。" >&2
    exit 1
  }
  ln -s "$SAVE_DIR" "$RUNTIME_DATA"
else
  ln -s "$SAVE_DIR" "$RUNTIME_DATA"
fi

echo "ES2 PERSISTENCE READY：$RUNTIME_DATA -> $SAVE_DIR"
