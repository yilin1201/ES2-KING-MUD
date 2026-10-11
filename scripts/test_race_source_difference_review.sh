#!/usr/bin/env bash
set -euo pipefail

# Race Source Difference Review Gate／種族來源差異門檻：
# 驗證 Original ES2、第三方重建與 ES2-KING Expansion 有明確分層，
# 並鎖定本次數字開頭帳號修正的程式與回歸測試契約。
DOC="docs/research/RACE_SOURCE_DIFFERENCE_REVIEW_20261011.md"
M5="original_es2/runtime/m5_race_framework_result.md"
HEADLESS="es2_king_expansion/races/headless.md"
BOOTSTRAP="scripts/bootstrap_original_es2.sh"
E2E_SH="scripts/test_original_player_creation_e2e.sh"
E2E_JS="scripts/test_original_player_creation_e2e.mjs"
PERSIST="scripts/prepare_es2_persistence.sh"
PERSIST_TEST="scripts/test_m30_persistence_paths.sh"

for file in "$DOC" "$M5" "$HEADLESS" "$BOOTSTRAP" "$E2E_SH" "$E2E_JS" "$PERSIST" "$PERSIST_TEST"; do
  test -f "$file" || { echo "FAIL／缺少必要檔案：$file" >&2; exit 1; }
done

# M5 原版契約：人類 13–18／護甲 +3，化身 16–18／護甲 +5，精氣神 30。
grep -Fq 'Original ES2 Human' "$DOC"
grep -Fq '13–18' "$DOC"
grep -Fq '16–18' "$DOC"
grep -Fq '+3' "$DOC"
grep -Fq '+5' "$DOC"
grep -Fq 'GIN=30/30 KEE=30/30 SEN=30/30' "$M5"

# 第三方資料只能作差異參考，不可冒充 Original ES2 或自動套用 KING Runtime。
grep -Fq '第三方重建差異' "$DOC"
grep -Fq '第三方重建資料對照（不自動採用）' "$HEADLESS"
grep -Fq '自然護甲 | +50' "$HEADLESS"
grep -Fq '攻擊／防禦 | +30／+20' "$HEADLESS"

# Numeric account shard／數字帳號分片：bootstrap 和獨立 E2E 都必須建立 0–9 目錄。
grep -Fq 'login"/{a..z}' "$BOOTSTRAP"
grep -Fq 'login"/{0..9}' "$BOOTSTRAP"
grep -Fq 'user"/{a..z}' "$BOOTSTRAP"
grep -Fq 'user"/{0..9}' "$BOOTSTRAP"
grep -Fq 'login"/{a..z}' "$E2E_SH"
grep -Fq 'login"/{0..9}' "$E2E_SH"
grep -Fq 'user"/{a..z}' "$E2E_SH"
grep -Fq 'user"/{0..9}' "$E2E_SH"
grep -Fq 'for digit in {0..9}' "$PERSIST"
grep -Fq 'data/login/7' "$PERSIST_TEST"
grep -Fq '["7probe"' "$E2E_JS"
grep -Fq 'ORIGINAL_PLAYER_CREATION_NUMERIC_ID_E2E_PASS' "$E2E_JS"
grep -Fq 'ORIGINAL_PLAYER_CREATION_NUMERIC_ID_E2E_PASS' "$E2E_SH"

echo 'RACE_SOURCE_DIFFERENCE_REVIEW_PASS／來源分層、M5 基準與數字帳號測試契約靜態檢查通過。'
