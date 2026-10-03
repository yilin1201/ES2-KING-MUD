#!/usr/bin/env bash
# 普通玩家資料與裝備檔案的隔離存檔路徑測試；不使用 KING、不連線 Neon。
set -euo pipefail
unset DATABASE_URL
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export ES2_RUNTIME_DIR="$TMP/runtime"
export ES2_SAVE_DIR="$TMP/backing"
export ES2_DATA_SEED_DIR="$TMP/runtime/mudlib/data.seed"
mkdir -p "$ES2_DATA_SEED_DIR/login/a" "$ES2_DATA_SEED_DIR/user/a" \
         "$ES2_SAVE_DIR/user/a" "$ES2_SAVE_DIR/login/a"
# 既有普通玩家進度必須優先於 image seed；此測試不代表 Driver 真正讀寫成功。
printf '%s\n' 'seed-account' > "$ES2_DATA_SEED_DIR/login/a/alpha.o"
printf '%s\n' 'seed-inventory' > "$ES2_DATA_SEED_DIR/user/a/alpha.o"
printf '%s\n' 'player-inventory-before-restart' > "$ES2_SAVE_DIR/user/a/alpha.o"
bash "$ROOT/scripts/prepare_es2_persistence.sh"
test ! -L "$ES2_RUNTIME_DIR/mudlib/data"
grep -Fqx 'player-inventory-before-restart' "$ES2_RUNTIME_DIR/mudlib/data/user/a/alpha.o"
grep -Fqx 'saved-account' "$ES2_RUNTIME_DIR/mudlib/data/login/a/alpha.o"
# 模擬普通玩家更新背包／裝備資料，然後手動執行既有同步入口。
printf '%s\n' 'player-inventory-after-save' > "$ES2_RUNTIME_DIR/mudlib/data/user/a/alpha.o"
bash "$ROOT/scripts/sync_es2_persistence.sh"
grep -Fqx 'player-inventory-after-save' "$ES2_SAVE_DIR/user/a/alpha.o"
# 隔離模擬程序重啟，驗證同一路徑恢復已同步的玩家檔案。
rm -rf "$ES2_RUNTIME_DIR/mudlib/data"
bash "$ROOT/scripts/prepare_es2_persistence.sh"
grep -Fqx 'player-inventory-after-save' "$ES2_RUNTIME_DIR/mudlib/data/user/a/alpha.o"\ngrep -Fqx 'saved-account' "$ES2_RUNTIME_DIR/mudlib/data/login/a/alpha.o"
echo "NORMAL_PLAYER_LOCAL_PERSISTENCE_PASS (file-path simulation only; Driver/Neon/Gameplay UNKNOWN)"
