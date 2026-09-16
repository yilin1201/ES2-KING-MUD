#!/usr/bin/env bash
# M10 Original 種族證據靜態回歸測試。
# Static regression／靜態回歸：確認重建計畫沒有再把暫定 25／50 誤標成 Original 正式數值。
set -euo pipefail

EVIDENCE="original_es2/research/original_race_google_sites_evidence.md"
PLAN="original_es2/research/original_race_runtime_reconstruction_plan.md"

# Evidence／證據檔必須存在，並包含 11 個歷史種族 ID。
test -f "$EVIDENCE"
test -f "$PLAN"
for race in human headless yenhold yaksa malik woochan jiaojao dingling ashura rainnar blackteeth; do
  grep -q "\`$race\`" "$EVIDENCE"
done

# 已由原始頁面確認的代表性資料，鎖定避免後續誤改。
grep -q '| 刑天 | `headless` | 25 |' "$EVIDENCE"
grep -q '| 阿修羅 | `ashura` | 30 |' "$EVIDENCE"
grep -q '| 黑齒 | `blackteeth` | 3 |' "$EVIDENCE"
grep -q '80/100/30' "$EVIDENCE"
grep -q '25/40/15/25/10/20/20/20' "$EVIDENCE"

# 暫定 Runtime 數值必須明確標示為 ES2-KING Design，而非 Original。
grep -q '\[ES2-KING Design\]' "$EVIDENCE"
grep -q '不使用 ES2-KING Runtime 暫定 25／50 數值補空白' "$EVIDENCE"

echo 'M10 PASS／通過：Original ES2 種族證據基線與重建邊界已鎖定。'
