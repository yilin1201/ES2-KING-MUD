#!/usr/bin/env bash
set -euo pipefail

# M5/M18 Closure Static Test（收斂靜態測試）：確認證據缺口被明確保留，不能被誤報為完成。
M5="${M5_CLOSURE_FILE:-original_es2/research/m5_evidence_closure.md}"
M18="${M18_CLOSURE_FILE:-original_es2/research/m18_quest_closure.md}"
REG="${M18_REGISTRY_FILE:-original_es2/research/m18_quest_evidence_registry.md}"
PLAN="${M18_PLAN_FILE:-original_es2/research/m18_quest_runtime_plan.md}"
test -f "$M5"; test -f "$M18"; test -f "$REG"; test -f "$PLAN"

grep -Fq 'M5 維持 `PARTIAL`' "$M5"
grep -Fq '`UNKNOWN`' "$M5"
grep -Fq 'M18 維持 `PARTIAL`' "$M18"
grep -Fq '`UNKNOWN`' "$M18"
grep -Fq '不補造' "$REG"
grep -Fq '完整觸發→進度→完成→獎勵鏈' "$PLAN"

# Original evidence boundary（Original 證據邊界）：不得用 Expansion 反推任務內容。
if rg -n 'ES2-KING Expansion.*反推|自行設定任務經驗值' "$REG" >/dev/null; then
  echo 'M5/M18 CLOSURE PASS：禁止補造規則存在。'
else
  echo 'M5/M18 CLOSURE FAIL：缺少 Original 證據邊界規則。'
  exit 1
fi
