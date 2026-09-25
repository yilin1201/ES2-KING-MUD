#!/usr/bin/env bash
# M12 study 研讀系統靜態證據回歸。
# Static verification／靜態驗證：鎖定 Original 研讀介面與精確公式，再進入真實 Runtime 測試。
set -euo pipefail

RESEARCH="original_es2/research/original_study_learning_m12.md"
PLAN="original_es2/research/plans/original_study_runtime_plan_m12.md"
FORMULA="original_es2/research/original_study_formula_m12.md"

test -f "$RESEARCH"
test -f "$PLAN"
test -f "$FORMULA"

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

# Formula／公式回歸：鎖住 Original study.c 與 skill.c 已確認的重要邏輯，避免後續重建時被簡化成固定加點。
grep -q 'cost = 1 + (9 - wis / 3)' "$FORMULA"
grep -q 'point = int / content_count' "$FORMULA"
grep -q 'random(point + skill) >= max / 2' "$FORMULA"
grep -q 'improve_skill(target_skill, 1 + random(point))' "$FORMULA"
grep -q 'amount += amount \* random(level / 8)' "$FORMULA"
grep -q 'query_learn()' "$FORMULA"
grep -q 'quit → relogin' "$FORMULA"

echo 'M12 STUDY STATIC PASS／靜態通過：Original 研讀介面、精確公式與 Persistence 邊界已鎖定。'
