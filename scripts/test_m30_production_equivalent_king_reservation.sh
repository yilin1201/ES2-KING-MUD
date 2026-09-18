#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/m30/.runtime/es2-king}"
TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf -- "$TEMP_ROOT"' EXIT

test -d "$SOURCE_RUNTIME/mudlib"
mkdir -p "$TEMP_ROOT/runtime"
cp -a "$SOURCE_RUNTIME/." "$TEMP_ROOT/runtime/"

# Production-equivalent Order（等同正式部署的順序）：重現 Dockerfile 的 Overlay、
# data-seed 搬移與啟動前 Persistence 準備，再測試最終 Runtime tree。
bash "$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT/runtime"
mv "$TEMP_ROOT/runtime/mudlib/data" "$TEMP_ROOT/data-seed"
mkdir -p "$TEMP_ROOT/runtime/mudlib/data" "$TEMP_ROOT/save"

ES2_RUNTIME_DIR="$TEMP_ROOT/runtime" \
ES2_DATA_SEED_DIR="$TEMP_ROOT/data-seed" \
ES2_SAVE_DIR="$TEMP_ROOT/save" \
bash "$REPO_ROOT/scripts/prepare_es2_persistence.sh"

bash "$REPO_ROOT/scripts/assert_m30_final_runtime.sh" "$TEMP_ROOT/runtime"

ES2_E2E_SKIP_OVERLAY=1 \
ES2_DRIVER_BIN="${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}" \
bash "$REPO_ROOT/scripts/test_m30_king_reservation_e2e.sh" "$TEMP_ROOT/runtime"

echo "M30 PRODUCTION-EQUIVALENT KING RESERVATION PASS（等同正式部署的 KING 保留測試通過）：最終 Runtime tree 已完成拒絕訊息、登入返回與 king.o 不建立驗證。"
