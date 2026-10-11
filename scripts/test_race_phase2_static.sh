#!/usr/bin/env bash
set -euo pipefail

# M6-M9 Static Verification／M6-M9 靜態驗證：只檢查設定與接線，不啟動遊戲。
RUNTIME_SCRIPT="scripts/apply_race_phase2_runtime.sh"

# Priority races／優先種族：刑天已改採 ES2M 隨機值；其餘三族仍保留暫定 50。
priority=(yaksa ashura rainnar)
for race in "${priority[@]}"; do
  grep -q "$race" "$RUNTIME_SCRIPT"
done

# Legacy bootstrap generator／歷史生成器仍須保留 50/25 契約，但最終 Human/Avatar/Headless 由 ES2M snapshot 覆蓋。
grep -q 'write_race "$r" 50' "$RUNTIME_SCRIPT"
grep -q 'write_race "$r" 25' "$RUNTIME_SCRIPT"
grep -Fq 'es2m_races=(human avatar' "$RUNTIME_SCRIPT"
grep -Fq 'headless' "$RUNTIME_SCRIPT"

# Attribute mapping／屬性代碼對應：cps=定力、cor=膽識。
grep -q '"cps":$value' "$RUNTIME_SCRIPT"
grep -q '"cor":$value' "$RUNTIME_SCRIPT"

# All 12 race daemons／12 個登入種族均應納入 Runtime overlay。
for race in human avatar blackteeth yenhold woochan dingling jiaojao rainnar ashura headless yaksa malik; do
  grep -q "$race" "$RUNTIME_SCRIPT"
done

echo 'M6-M9 STATIC PASS／靜態驗證通過：ES2M Human/Avatar/Headless overlay 與其餘種族暫定規則存在。'
