#!/usr/bin/env bash
# M12 study 研讀系統靜態證據回歸。
# Static verification／靜態驗證：先鎖定已確認的 Original 研讀介面，再進入真實 Runtime 測試。
set -euo pipefail

RESEARCH="original_es2/research/original_study_learning_m12.md"
PLAN="original_es2/research/original_study_runtime_plan_m12.md"

test -f "$RESEARCH"
test -f "$PLAN"

# Original 玩家介面與核心學習函式必須保留在考證文件中。
grep -q 'study <' "$RESEARCH"
grep -q 'study_ob' "$RESEARCH"
grep -q 'improve_skill' "$RESEARCH"
grep -q 'literate' "$RESEARCH"
grep -q 'archaic attainment' "$RESEARCH"

# Runtime 計畫必須明確要求真實 study 與重新登入持久化，不得只直接 set_skill。
grep -q 'study <物品>' "$PLAN"
grep -q 'improve_skill()' "$PLAN"
grep -q '重新登入' "$PLAN"
grep -q 'Persistence' "$PLAN"

echo 'M12 STUDY STATIC PASS／靜態通過：Original 研讀學習 Runtime 邊界已鎖定。'
