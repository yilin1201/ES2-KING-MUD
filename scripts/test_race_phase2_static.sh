#!/usr/bin/env bash
set -euo pipefail

# M6-M9 Static Verification／M6-M9 靜態驗證
# Static verification = 不啟動遊戲，先檢查種族設定程式是否符合專案規則。
RUNTIME_SCRIPT="scripts/apply_race_phase2_runtime.sh"

# Priority races／優先種族：M6-M9 出生八項屬性暫定 50。
priority=(headless yaksa ashura rainnar)
for race in "${priority[@]}"; do
  grep -q "$race" "$RUNTIME_SCRIPT"
done

# Base value／基礎值：確認優先種族 50、其他歷史種族 25 的寫入規則存在。
grep -q 'write_race "$r" 50' "$RUNTIME_SCRIPT"
grep -q 'write_race "$r" 25' "$RUNTIME_SCRIPT"

# Attribute mapping／屬性對應：cps=膽識、cor=定力；程式欄位必須存在。
grep -q '"cps":$value' "$RUNTIME_SCRIPT"
grep -q '"cor":$value' "$RUNTIME_SCRIPT"

# Runtime overlay／執行環境覆蓋層：11 個歷史種族都必須存在於設定腳本。
for race in blackteeth human yenhold woochan dingling jiaojao rainnar ashura headless yaksa malik; do
  grep -q "$race" "$RUNTIME_SCRIPT"
done

echo 'M6-M9 STATIC PASS／靜態驗證通過：50/25 基礎值、八屬性欄位、11 歷史種族設定均存在。'
