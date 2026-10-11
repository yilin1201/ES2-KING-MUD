#!/usr/bin/env bash
set -euo pipefail

# Regression Test／回歸測試：確認新增 M6-M9 種族後，已完成的 M2/M5 Human、Avatar 基準沒有被破壞。
ROOT="${1:-.runtime/original-es2}"
RACE_DIR="$ROOT/mudlib/daemon/race"
LOGIN="$ROOT/mudlib/adm/daemons/logind.c"

# Original preservation／原作保護：Human 與 Avatar 必須仍由 Original ES2 原始種族程式提供。
test -f "$RACE_DIR/human.c"
test -f "$RACE_DIR/avatar.c"

# Human M2 baseline／人類 M2 基準：八項屬性仍使用 Original 的 13 + random(6)，不能被暫定 25 覆寫。
grep -q '13 + random(6)' "$RACE_DIR/human.c"
if grep -q '"str":25' "$RACE_DIR/human.c"; then
  echo 'FAIL／失敗：Original Human 被 M6-M9 暫定屬性覆寫' >&2
  exit 1
fi

# Avatar M5 baseline／化身 M5 基準：保留 Original Avatar 程式，不由歷史種族覆蓋層重新產生。
if grep -q 'ES2-KING Runtime reconstruction overlay' "$RACE_DIR/avatar.c"; then
  echo 'FAIL／失敗：Original Avatar 被 Runtime overlay 覆寫' >&2
  exit 1
fi

# Login registry／登入種族清單：Human、Avatar 與全部歷史重建種族都必須出現在登入選單。
ALL_RACES=(human avatar blackteeth yenhold woochan dingling jiaojao rainnar ashura headless yaksa malik)
for race in "${ALL_RACES[@]}"; do
  grep -q "\"$race\"" "$LOGIN"
done

# Race acceptance／種族接受邏輯：只出現在選單仍不夠；get_race() 的 switch 必須真的接受每一個種族，避免選完又被退回選單。
for race in "${ALL_RACES[@]}"; do
  grep -q "case \"$race\":" "$LOGIN" || {
    echo "FAIL／失敗：登入接受邏輯缺少種族 $race" >&2
    exit 1
  }
done

# M6-M9 baseline／M6-M9 基準：四個優先歷史種族八項出生屬性維持 50。
for race in headless yaksa ashura rainnar; do
  file="$RACE_DIR/$race.c"
  for attr in str cps int spi cor dex con wis; do
    grep -q "\"$attr\":50" "$file"
  done
done

# Other historical races／其他歷史重建種族：暫定八項出生屬性維持 25。
for race in blackteeth yenhold woochan dingling jiaojao malik; do
  file="$RACE_DIR/$race.c"
  for attr in str cps int spi cor dex con wis; do
    grep -q "\"$attr\":25" "$file"
  done
done

echo 'RACE ES2M REGRESSION PASS／靜態回歸契約通過：Human/Avatar/Headless ES2M 設定與登入接受邏輯正確；不代表 LPC Runtime 已通過。'
