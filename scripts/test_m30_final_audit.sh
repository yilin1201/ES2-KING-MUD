#!/usr/bin/env bash
set -euo pipefail

AUDIT="M30_ALPHA_FINAL_AUDIT.md"
MATRIX="original_es2/research/m30_completion_matrix.md"
test -f "$AUDIT"; test -f "$MATRIX"
for m in $(seq 0 30); do grep -Fq "M${m}" "$AUDIT" || { echo "M30 AUDIT FAIL：缺少 M$m"; exit 1; }; done
for status in 'IMPLEMENTED + LOCAL PASS' 'PARTIAL' 'UNKNOWN' 'ACTIONS-INFRA-BLOCKED'; do grep -Fq "$status" "$AUDIT" || { echo "M30 AUDIT FAIL：缺少狀態 $status"; exit 1; }; done
for path in original_es2/research/m30_completion_matrix.md scripts/test_m30_alpha_static.sh scripts/test_m30_alpha_runtime_gate.sh es2_king_expansion/runtime/m30_alpha_result.md; do test -f "$path" || { echo "M30 AUDIT FAIL：缺少證據路徑 $path"; exit 1; }; done
grep -Fq 'PR #13：Open；未 Merge' "$AUDIT"
grep -Fq '未建立 M31' "$AUDIT"
echo 'M30 FINAL AUDIT PASS／M0-M30 矩陣、證據路徑、狀態分類與 PR 邊界完整。'
