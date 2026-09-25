#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEMP_ROOT"' EXIT

mkdir -p \
  "$TEMP_ROOT/runtime/mudlib/data.seed/login/k" \
  "$TEMP_ROOT/runtime/mudlib/data/user/k" \
  "$TEMP_ROOT/persistent/data/user/k"
printf '%s\n' 'seed-account' > "$TEMP_ROOT/runtime/mudlib/data.seed/login/k/king.o"
printf '%s\n' 'runtime-only-state' > "$TEMP_ROOT/runtime/mudlib/data/runtime-only.o"
printf '%s\n' 'image-default' > "$TEMP_ROOT/runtime/mudlib/data/user/k/king.o"
printf '%s\n' 'player-progress' > "$TEMP_ROOT/persistent/data/user/k/king.o"

export ES2_RUNTIME_DIR="$TEMP_ROOT/runtime"
export ES2_DATA_SEED_DIR="$TEMP_ROOT/runtime/mudlib/data.seed"
export ES2_SAVE_DIR="$TEMP_ROOT/persistent/data"

"$REPO_ROOT/scripts/prepare_es2_persistence.sh"
test -d "$TEMP_ROOT/runtime/mudlib/data"
test ! -L "$TEMP_ROOT/runtime/mudlib/data"
test -f "$TEMP_ROOT/persistent/data/login/k/king.o"
grep -Fqx 'runtime-only-state' "$TEMP_ROOT/persistent/data/runtime-only.o"
grep -Fqx 'player-progress' "$TEMP_ROOT/runtime/mudlib/data/user/k/king.o"

# Runtime save 模擬：Driver 寫入 mudlib/data 後，背景同步必須更新 backing store。
printf '%s\n' 'new-player-progress' > "$TEMP_ROOT/runtime/mudlib/data/user/k/king.o"
bash "$REPO_ROOT/scripts/sync_es2_persistence.sh"
grep -Fqx 'new-player-progress' "$TEMP_ROOT/persistent/data/user/k/king.o"

# Process Restart／程序重啟：重新建立空的 Runtime data 後，prepare 必須由 backing store 還原角色。
mv "$TEMP_ROOT/runtime/mudlib/data" "$TEMP_ROOT/runtime/mudlib/data.before-restart"
mkdir -p "$TEMP_ROOT/runtime/mudlib/data"
"$REPO_ROOT/scripts/prepare_es2_persistence.sh"
grep -Fqx 'new-player-progress' "$TEMP_ROOT/runtime/mudlib/data/user/k/king.o"

echo "M30 PERSISTENCE PATH PASS：in-mudlib Driver 寫入路徑、backing 同步與 process restart 還原均通過"
