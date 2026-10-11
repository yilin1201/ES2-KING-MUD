#!/usr/bin/env bash
set -euo pipefail

# Race Regression／種族回歸測試：驗證 KING Runtime 明確採用的 ES2M 人類、化身、刑天設定。
ROOT="${1:-.runtime/original-es2}"
RACE_DIR="$ROOT/mudlib/daemon/race"
LOGIN="$ROOT/mudlib/adm/daemons/logind.c"

# ES2M source contract／來源契約：三個 Runtime daemon 必須存在。
for race in human avatar headless; do
  test -f "$RACE_DIR/$race.c"
done

# Human／人類：13–18 屬性、精氣神 35、自然護甲 +10、來源指定的 0.01% 化身轉換。
grep -Fq '13 + random(6)' "$RACE_DIR/human.c"
grep -Fq '"gin":35, "kee":35, "sen":35' "$RACE_DIR/human.c"
grep -Fq '"apply/armor", 10' "$RACE_DIR/human.c"
grep -Fq 'random(10000) == 9999' "$RACE_DIR/human.c"

# Avatar／化身：15–20 屬性、精氣神 30、自然護甲 +10。
grep -Fq '15 + random(6)' "$RACE_DIR/avatar.c"
grep -Fq '"gin":30, "kee":30, "sen":30' "$RACE_DIR/avatar.c"
grep -Fq '"apply/armor", 10' "$RACE_DIR/avatar.c"

# Headless／刑天：ES2M 隨機屬性、資源、自然護甲、攻防及裝備限制。
for token in '25+random(6)' '"cor":15+random(6)' '"int":8+random(6)' '"cps":11+random(6)' '"gin":80, "kee":100, "sen":30' '"apply/armor", 50' '"apply/attack", 30' '"apply/defense", 20' '"armor", "cloth", "head_eq", "neck_eq"'; do
  grep -Fq "$token" "$RACE_DIR/headless.c" || {
    echo "FAIL／刑天 ES2M 契約缺少：$token" >&2
    exit 1
  }
done

# Login registry／登入種族清單及接受邏輯均須包含所有 12 個種族。
ALL_RACES=(human avatar blackteeth yenhold woochan dingling jiaojao rainner ashura headless yaksa malik)
for race in "${ALL_RACES[@]}"; do
  grep -q "\"$race\"" "$LOGIN"
  grep -q "case \"$race\":" "$LOGIN" || {
    echo "FAIL／登入接受邏輯缺少種族 $race" >&2
    exit 1
  }
done

# Other M6-M9 races／其餘指定種族仍依既有 50/25 暫定基準，不影響 ES2M 刑天設定。
for race in yaksa ashura rainner; do
  file="$RACE_DIR/$race.c"
  for attr in str cps int spi cor dex con wis; do
    grep -q "\"$attr\":50" "$file"
  done
done
for race in blackteeth yenhold woochan dingling jiaojao malik; do
  file="$RACE_DIR/$race.c"
  for attr in str cps int spi cor dex con wis; do
    grep -q "\"$attr\":25" "$file"
  done
done

echo 'RACE ES2M STATIC REGRESSION PASS／靜態契約通過；不代表 LPC 編譯或 Runtime E2E 已通過。'
