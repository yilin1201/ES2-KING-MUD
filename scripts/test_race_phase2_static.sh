#!/usr/bin/env bash
set -euo pipefail

# M6-M9 Static Verification／M6-M9 靜態驗證：只檢查 overlay 接線，不啟動遊戲。
RUNTIME_SCRIPT="scripts/apply_race_phase2_runtime.sh"

# ES2M source overlay／人類、化身、刑天與歷史種族直接由保存的 ES2M 快照匯入；
# 不再檢查已不存在於 overlay 的舊 write_race 生成器。
grep -Fq 'es2m_races=(human avatar' "$RUNTIME_SCRIPT"
grep -Fq 'ES2M_RACE_DIR="$REPO_ROOT/es2m_snapshot/mudlib/daemon/race"' "$RUNTIME_SCRIPT"
grep -Fq 'cp "$ES2M_RACE_DIR/$race.c" "$RACE_DIR/$race.c"' "$RUNTIME_SCRIPT"
grep -Fq 'headless' "$RUNTIME_SCRIPT"

# All 12 race daemons／12 個登入種族均應納入 ES2M Runtime overlay。
for race in human avatar blackteeth yenhold woochan dingling jiaojao rainner ashura headless yaksa malik; do
  grep -q "$race" "$RUNTIME_SCRIPT"
  test -f "es2m_snapshot/mudlib/daemon/race/$race.c"
done

# Priority race commands／歷史種族的專屬指令需由 overlay 明確接線。
for token in '[blackteeth]=gnaw' '[yenhold]=breathe' '[woochan]=replete' '[dingling]=hoof' '[jiaojao]=hide' '[rainner]=feed' '[headless]=dance' '[yaksa]=devour'; do
  grep -Fq "$token" "$RUNTIME_SCRIPT"
done

echo 'M6-M9 STATIC PASS／靜態驗證通過：12 個 ES2M 種族快照、Runtime 匯入與種族指令接線存在。'
