#!/usr/bin/env bash
# Original Human Runtime Fixture 的精準靜態門檻。
# 本測試只驗證 Source dependency 與固定初始化邊界；真正 Driver Runtime 仍由主線執行。
set -euo pipefail

ROOT="${1:-.runtime/original-es2}"
LOGIN="$ROOT/mudlib/adm/daemons/logind.c"
CHAR_D="$ROOT/mudlib/adm/daemons/chard.c"
HUMAN="$ROOT/mudlib/daemon/race/human.c"

for file in "$LOGIN" "$CHAR_D" "$HUMAN"; do
  test -f "$file" || {
    echo "FAIL／失敗：缺少 Human dependency：$file" >&2
    exit 1
  }
done

# Character Creation：選擇 human 後，建立 body 並進入共通角色初始化。
grep -q 'case "human":' "$LOGIN"
grep -q 'body->set_race (race);' "$LOGIN"
grep -q 'init_new_body (ob, body);' "$LOGIN"
grep -q 'user->set_class("commoner");' "$LOGIN"
grep -q 'user->set_level(1);' "$LOGIN"
grep -q 'CHAR_D->setup_char(user);' "$LOGIN"

# Daemon 串接：CHAR_D 必須依角色 race/class 呼叫對應 setup()。
grep -q 'RACE_D(ob->query_race())->setup (ob);' "$CHAR_D"
grep -q 'CLASS_D(ob->query_class())->setup (ob);' "$CHAR_D"

# Original Human 固定邊界：karma、八屬性公式、精氣神與 natural armor。
grep -q 'set ("karma", 5);' "$HUMAN"
for attr in str cor int spi cps dex con wis; do
  grep -Eq '"'"$attr"'"[[:space:]]*:[[:space:]]*13 \+ random\(6\)' "$HUMAN"
done
for stat in gin kee sen; do
  grep -Eq '"'"$stat"'"[[:space:]]*:[[:space:]]*30' "$HUMAN"
done
grep -q 'add_temp ("apply/armor", 3);' "$HUMAN"

echo 'ORIGINAL_HUMAN_SOURCE_PASS'
echo 'ORIGINAL_HUMAN_STATIC_PASS'
echo 'RUNTIME_HANDOFF_TO_MAIN'
