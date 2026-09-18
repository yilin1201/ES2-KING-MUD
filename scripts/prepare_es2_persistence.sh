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
  # 首次啟動可能遇到映像內殘留資料：先以不覆寫方式複製，再逐項確認目的端存在。
  # 只有驗證完成後才移除舊目錄並建立連結，Persistence Guard 不允許靜默遺失資料。
  if find "$RUNTIME_DATA" -mindepth 1 -print -quit | grep -q .; then
    cp -a --update=none "$RUNTIME_DATA/." "$SAVE_DIR/"
    while IFS= read -r -d '' source; do
      relative="${source#"$RUNTIME_DATA"/}"
      if [[ ! -e "$SAVE_DIR/$relative" && ! -L "$SAVE_DIR/$relative" ]]; then
        echo "PERSISTENCE FAIL：Runtime data 項目尚未安全複製：$relative" >&2
        exit 1
      fi
    done < <(find "$RUNTIME_DATA" -mindepth 1 -print0)
  fi

  rm -rf -- "$RUNTIME_DATA"
  if [[ -e "$RUNTIME_DATA" || -L "$RUNTIME_DATA" ]]; then
    echo "PERSISTENCE FAIL：無法替換 Runtime data；請檢查 mudlib 父目錄權限。" >&2
    exit 1
  fi
  ln -s "$SAVE_DIR" "$RUNTIME_DATA"
else
  ln -s "$SAVE_DIR" "$RUNTIME_DATA"
fi

echo "ES2 PERSISTENCE READY：$RUNTIME_DATA -> $SAVE_DIR"
