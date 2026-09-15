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

# Login registry／登入種族清單：Human、Avatar 與 M6-M9 歷史種族都必須可被登入系統辨識。
for race in human avatar headless yaksa ashura rainnar; do
  grep -q "\"$race\"" "$LOGIN"
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

echo 'M2/M5/M6-M9 REGRESSION PASS／回歸驗證通過：Original Human/Avatar 保留，歷史種族 50/25 設定正確。'
