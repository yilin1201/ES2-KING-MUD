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

# Hosting Persistence Mode／主機保存模式：Render Free 等無 Persistent Disk 的環境會在重新部署後清空本機檔案。
# 明確輸出 EPHEMERAL，避免把「本次 Runtime 可 save」誤認為「跨部署永久保存」。
if [[ "${ES2_PERSISTENCE_MODE:-ephemeral}" == "persistent" ]]; then
  echo "ES2 PERSISTENCE MODE：PERSISTENT（跨部署保存由外部持久磁碟提供）"
else
  echo "ES2 PERSISTENCE MODE：EPHEMERAL（本次 Runtime 內可保存；重新部署後帳號資料可能重建）"
fi

# Neolith Sandbox／Neolith 檔案沙盒：save_object() 的實際目標必須位於 MudlibDir 內。
# 舊架構把 mudlib/data 連到 /var/lib，Static Path Test 雖能通過，真實 Driver 卻會拒絕寫入。
# Runtime data 因此固定保留為 mudlib 內的實體目錄；SAVE_DIR 只作為可掛載的備份儲存層。
if [[ -L "$RUNTIME_DATA" ]]; then
  legacy_target="$(readlink "$RUNTIME_DATA")"
  test -d "$legacy_target" || {
    echo "PERSISTENCE FAIL：舊 data symlink 目標不存在：$legacy_target" >&2
    exit 1
  }
  unlink "$RUNTIME_DATA"
  mkdir -p "$RUNTIME_DATA"
  cp -a "$legacy_target/." "$RUNTIME_DATA/"
elif [[ ! -d "$RUNTIME_DATA" ]]; then
  mkdir -p "$RUNTIME_DATA"
fi

# Initial Restore／首次還原：Image seed 先補齊基本目錄，再由既有持久層覆蓋為最新玩家資料。
if [[ -d "$SEED_DIR" ]]; then
  cp -a --update=none "$SEED_DIR/." "$RUNTIME_DATA/"
fi
if [[ "$SAVE_DIR" != "$RUNTIME_DATA" ]] && find "$SAVE_DIR" -mindepth 1 -print -quit | grep -q .; then
  cp -a "$SAVE_DIR/." "$RUNTIME_DATA/"
fi

mkdir -p "$RUNTIME_DATA/login" "$RUNTIME_DATA/user" "$RUNTIME_DATA/mail"
for letter in {a..z}; do
  mkdir -p "$RUNTIME_DATA/login/$letter" "$RUNTIME_DATA/user/$letter" "$RUNTIME_DATA/mail/$letter"
done

# 建立啟動時快照，之後由 sync_es2_persistence.sh 持續同步；不再讓 Driver 跨 Mudlib sandbox 寫 symlink。
bash "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/sync_es2_persistence.sh"

echo "ES2 PERSISTENCE READY：Runtime=$RUNTIME_DATA；Backing=$SAVE_DIR"
