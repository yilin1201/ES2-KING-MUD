#!/usr/bin/env bash
set -euo pipefail

# Full Game Journey／完整遊戲旅程前置閘門。
# Public Race 與 Game Completion 分離；Test Character 必須來自 real Runtime save_object。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/m30/.runtime/es2-king}"
FIXTURE="${2:-$REPO_ROOT/.runtime/game-completion-fixture/king}"
DATA_ROOT="${3:-$REPO_ROOT/.runtime/game-completion-data}"
DRIVER_BIN="${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}"

test -x "$DRIVER_BIN" || { echo "GAME COMPLETION JOURNEY BLOCKED：缺少可執行 Neolith Driver；需在有本機 Runtime 的環境執行。" >&2; exit 2; }
test -f "$FIXTURE/login/king.o" -a -f "$FIXTURE/user/king.o" || {
  echo "GAME COMPLETION JOURNEY BLOCKED：缺少 real Runtime KING fixture。" >&2
  echo "先由 test_m30_king_claim_e2e.sh 搭配 ES2_GAME_COMPLETION_FIXTURE_DIR 產生。" >&2
  exit 2
}

bash "$REPO_ROOT/scripts/bootstrap_game_completion_character.sh" "$DATA_ROOT" "$FIXTURE"

# Existing Gates／既有閘門：先確保完整旅程依賴的 Original + Expansion 介面仍存在。
for gate in \
  test_m21_world_runtime_gate.sh \
  test_m22_npc_item_runtime_gate.sh \
  test_m23_core_gameplay_runtime_gate.sh \
  test_m24_data_integrity_runtime_gate.sh \
  test_m25_release_candidate_runtime_gate.sh \
  test_m26_king_admin_runtime_gate.sh \
  test_m27_wuji_realm_runtime_gate.sh \
  test_m28_martial_runtime_gate.sh \
  test_m29_canon_runtime_gate.sh \
  test_m30_alpha_runtime_gate.sh \
  test_game_completion_quest_evidence.sh
do
  if [[ "$gate" == "test_game_completion_quest_evidence.sh" ]]; then
    # Quest 是 Evidence gap，不得阻塞其餘可驗證 gameplay；狀態保留 BLOCKED/UNKNOWN。
    bash "$REPO_ROOT/scripts/$gate" "$SOURCE_RUNTIME/mudlib" || [[ $? -eq 2 ]]
  else
    bash "$REPO_ROOT/scripts/$gate" "$SOURCE_RUNTIME/mudlib"
  fi
done

echo "GAME COMPLETION JOURNEY READY：real Runtime Test Character 與 M21-M30 gameplay gates 已就緒；下一步執行單一 Driver Journey。"
