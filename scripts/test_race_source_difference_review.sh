#!/usr/bin/env bash
set -euo pipefail

# Race Source Difference Review Gate／種族來源差異門檻：
# 驗證 Original ES2、第三方重建與 ES2-KING Expansion 有明確分層，
# 並鎖定本次數字開頭帳號修正的程式與回歸測試契約。
DOC="docs/research/RACE_SOURCE_DIFFERENCE_REVIEW_20261011.md"
M5="original_es2/runtime/m5_race_framework_result.md"
HEADLESS="es2_king_expansion/races/headless.md"
HUMAN_AVATAR="es2_king_expansion/races/human.md"
ES2M_RACES="es2m_snapshot/mudlib/daemon/race"
RACE_OVERLAY="scripts/apply_race_phase2_runtime.sh"
BOOTSTRAP="scripts/bootstrap_original_es2.sh"
E2E_SH="scripts/test_original_player_creation_e2e.sh"
E2E_JS="scripts/test_original_player_creation_e2e.mjs"
PERSIST="scripts/prepare_es2_persistence.sh"
PERSIST_TEST="scripts/test_m30_persistence_paths.sh"
SOURCES="docs/SOURCES.md"
INVENTORY="docs/research/THIRD_PARTY_CONTENT_INVENTORY_20261011.md"
ORACLE_README="deploy/oracle/README.md"

for file in "$DOC" "$M5" "$HEADLESS" "$HUMAN_AVATAR" "$ES2M_RACES/human.c" "$ES2M_RACES/avatar.c" "$ES2M_RACES/headless.c" "$RACE_OVERLAY" "$BOOTSTRAP" "$E2E_SH" "$E2E_JS" "$PERSIST" "$PERSIST_TEST" "$SOURCES" "$INVENTORY" "$ORACLE_README"; do
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
grep -Fq '第三方重建資料與目前 Runtime 採用值對照' "$HEADLESS"
grep -Fq '第三方資料索引（不在本原版考證檔保存數值）' original_es2/races/headless.md
if grep -Fq '自然護甲 | +50' original_es2/races/headless.md; then
  echo 'FAIL／Original ES2 刑天考證檔不應內嵌第三方數值。' >&2
  exit 1
fi
grep -Fq '自然護甲 | +50' "$INVENTORY"
grep -Fq '攻擊／防禦 | +30／+20' "$INVENTORY"

# ES2M Human / Avatar / Headless runtime contract／人類、化身、刑天採用 ES2M 快照。
# 此處驗證 KING 的明確採用決策，不代表這些第三方數值是 Original ES2 Canon。
grep -Fq 'ES2M Runtime 採用基準' "$HUMAN_AVATAR"
grep -Fq '13 + random(6)' "$ES2M_RACES/human.c"
grep -Fq '"gin":35, "kee":35, "sen":35' "$ES2M_RACES/human.c"
grep -Fq '"apply/armor", 10' "$ES2M_RACES/human.c"
grep -Fq 'random(10000) == 9999' "$ES2M_RACES/human.c"
grep -Fq '15 + random(6)' "$ES2M_RACES/avatar.c"
grep -Fq '"gin":30, "kee":30, "sen":30' "$ES2M_RACES/avatar.c"
grep -Fq '"apply/armor", 10' "$ES2M_RACES/avatar.c"
grep -Fq '25+random(6)' "$ES2M_RACES/headless.c"
grep -Fq '"gin":80, "kee":100, "sen":30' "$ES2M_RACES/headless.c"
grep -Fq '"apply/armor", 50' "$ES2M_RACES/headless.c"
grep -Fq '"apply/attack", 30' "$ES2M_RACES/headless.c"
grep -Fq '"apply/defense", 20' "$ES2M_RACES/headless.c"
grep -Fq 'member_array(part, ({ "armor", "cloth", "head_eq", "neck_eq" }))' "$ES2M_RACES/headless.c"
grep -Fq 'es2m_races=(human avatar' "$RACE_OVERLAY"
grep -Fq 'cp "$ES2M_RACE_DIR/$race.c" "$RACE_DIR/$race.c"' "$RACE_OVERLAY"
grep -Fq '目前 Runtime 採用' "$HEADLESS"

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

# AntiSpam policy／KING 保留獨立 Runtime 政策，不覆寫 Original ES2 保存來源。
grep -Fq 'ENABLE_ANTISPAM disabled' "$BOOTSTRAP"
grep -Fq 'ENABLE_ANTISPAM is still active' "$BOOTSTRAP"

# Port contract／連線契約：Web 8080 僅綁本機，Neolith 4000 不直接公開。
grep -Fq 'Neolith TCP 4000 remains internal only' "$ORACLE_README"
grep -Fq 'Do not expose 4000' "$ORACLE_README"
grep -Fq '127.0.0.1' "$ORACLE_README"

# Third-party provenance／第三方來源必須明確標記且有獨立清單。
grep -Fq 'wolfer168/es2-webmud' "$SOURCES"
grep -Fq 'Third-party reconstruction' "$INVENTORY"
grep -Fq '不得自動套用到 Original ES2' "$INVENTORY"
grep -Fq '老松林' "$INVENTORY"

# Oracle backup contract／Oracle 備份契約：確認有獨立腳本與隔離還原冒煙測試。
# 這只驗證備份政策與測試存在；不把靜態檢查冒充成真實異地備份／還原。
BACKUP="deploy/oracle/backup.sh"
BACKUP_TEST="scripts/test_oracle_backup_smoke.sh"
test -f "$BACKUP"
test -f "$BACKUP_TEST"
grep -Fq 'BACKUP_DIR' "$BACKUP"
grep -Fq 'RETENTION_DAYS' "$BACKUP"
grep -Fq 'sha256sum' "$BACKUP"
grep -Fq '同一檔案系統' "$BACKUP"
grep -Fq 'tar -xzf "$ARCHIVE" -C "$RESTORE_DIR"' "$BACKUP_TEST"
grep -Fq 'cmp "$DATA_DIR/user/7/7probe.o" "$RESTORE_DIR/user/7/7probe.o"' "$BACKUP_TEST"
grep -Fq 'ALLOW_SAME_DEVICE_BACKUP=1' "$BACKUP_TEST"

echo 'RACE_SOURCE_DIFFERENCE_REVIEW_PASS／來源分層、M5 基準、數字帳號、AntiSpam、Port、第三方索引與備份契約靜態檢查通過。'
