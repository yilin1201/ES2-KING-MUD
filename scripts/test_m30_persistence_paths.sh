#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEMP_ROOT"' EXIT

mkdir -p "$TEMP_ROOT/runtime/mudlib/data.seed/login/k" "$TEMP_ROOT/runtime/mudlib/data"
printf '%s\n' 'seed-account' > "$TEMP_ROOT/runtime/mudlib/data.seed/login/k/king.o"

export ES2_RUNTIME_DIR="$TEMP_ROOT/runtime"
export ES2_DATA_SEED_DIR="$TEMP_ROOT/runtime/mudlib/data.seed"
export ES2_SAVE_DIR="$TEMP_ROOT/persistent/data"

"$REPO_ROOT/scripts/prepare_es2_persistence.sh"
test -L "$TEMP_ROOT/runtime/mudlib/data"
test "$(readlink "$TEMP_ROOT/runtime/mudlib/data")" = "$TEMP_ROOT/persistent/data"
test -f "$TEMP_ROOT/persistent/data/login/k/king.o"

printf '%s\n' 'player-progress' > "$TEMP_ROOT/persistent/data/user/k/king.o"
"$REPO_ROOT/scripts/prepare_es2_persistence.sh"
grep -Fqx 'player-progress' "$TEMP_ROOT/persistent/data/user/k/king.o"

echo "M30 PERSISTENCE PATH PASS：seed、symlink、restart 保存均通過"
