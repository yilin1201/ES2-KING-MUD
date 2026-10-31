#!/usr/bin/env bash
set -euo pipefail

# Game Completion One Shot／單次完整驗收入口。
# 在具備 Linux + git + cmake + node/npm 的開發環境中，從乾淨 Original ES2 建立 Runtime，
# 套用 Expansion、建置 Neolith、以 real E2E 產生 KING fixture，再執行 Full Journey gates。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
FIXTURE="$REPO_ROOT/.runtime/game-completion-fixture/king"
DATA="$REPO_ROOT/.runtime/game-completion-data"

command -v git >/dev/null; command -v cmake >/dev/null; command -v node >/dev/null; command -v npm >/dev/null
rm -rf -- "$RUNTIME" "$FIXTURE" "$DATA"
bash "$REPO_ROOT/scripts/bootstrap_original_es2.sh" "$RUNTIME"
git -C "$RUNTIME" checkout cc45c06af4852380e5148dad3c9d53ff06854f2c
git -C "$RUNTIME" submodule update --init --recursive
bash "$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$RUNTIME"
bash "$REPO_ROOT/scripts/assert_m30_final_runtime.sh" "$RUNTIME"

# Neolith Build／優先使用 upstream linux preset；輸出路徑交給 find 確認，不猜 binary 位置。
(
  cd "$RUNTIME/neolith"
  cmake --preset linux -DBUILD_TESTING=OFF
  cmake --build --preset dev-linux
)
DRIVER_BIN="$(find "$RUNTIME/neolith" -type f -name neolith -perm -111 -print -quit)"
test -n "$DRIVER_BIN" || { echo "GAME COMPLETION FAIL：Neolith build 後找不到可執行檔。" >&2; exit 1; }

# Web bridge dependencies／只安裝 lockfile 已固定的相依套件。
( cd "$REPO_ROOT/webtelnet" && npm ci --omit=dev )

ES2_DRIVER_BIN="$DRIVER_BIN" \
ES2_GAME_COMPLETION_FIXTURE_DIR="$FIXTURE" \
bash "$REPO_ROOT/scripts/test_m30_king_claim_e2e.sh" "$RUNTIME"

ES2_DRIVER_BIN="$DRIVER_BIN" \
bash "$REPO_ROOT/scripts/test_game_completion_journey.sh" "$RUNTIME" "$FIXTURE" "$DATA"

echo "GAME COMPLETION ONE SHOT PASS：Game Completion Runtime、real KING fixture 與 Full Journey gates 全部通過；Public Device 仍為獨立 Release Gate。"
