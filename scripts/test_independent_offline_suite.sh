#!/usr/bin/env bash
# ES2-KING 獨立離線驗證入口：不連正式服務、不執行 Actions、不建立角色。
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
command -v node >/dev/null || { echo "BLOCKED: missing node" >&2; exit 2; }
command -v python3 >/dev/null || { echo "BLOCKED: missing python3" >&2; exit 2; }
# 檢查所有必需入口，避免執行一半才發現檔案遺失。
for path in \
  scripts/test_martial_arts_simulator.mjs \
  scripts/test_martial_simulator_edge_cases.mjs \
  scripts/test_player_persistence_evidence_static.mjs \
  scripts/test_m30_persistence_paths.sh \
  scripts/test_normal_player_local_persistence.sh \
  scripts/test_king_weapon_loadout_static.sh \
  scripts/test_es2m_skill_armor_import.py \
  scripts/test_audit_es2m_equipment_import.py; do
  test -f "$path" || { echo "BLOCKED: missing $path" >&2; exit 2; }
done
node scripts/test_martial_arts_simulator.mjs
node scripts/test_martial_simulator_edge_cases.mjs
node scripts/test_player_persistence_evidence_static.mjs
# 現有 persistence 腳本內部取消 DATABASE_URL 並使用 mktemp 隔離。
bash scripts/test_m30_persistence_paths.sh
bash scripts/test_normal_player_local_persistence.sh
bash scripts/test_king_weapon_loadout_static.sh "$ROOT"
# 91 件防具導入後的來源 SHA／部位／依賴證據檢查，及三方盤點隔離單元測試。
python3 scripts/test_es2m_skill_armor_import.py
python3 scripts/test_audit_es2m_equipment_import.py
echo "ES2_INDEPENDENT_OFFLINE_TESTS_PASS (static/local only; no Runtime or Gameplay claim)"
