#!/usr/bin/env bash
# ES2M Human／Avatar Runtime Fixture 的精準靜態門檻。
# 依最新 ES2M dynamic race menu 與 human/avatar daemon 驗證；不沿用已淘汰的固定 switch／舊屬性數值。
set -euo pipefail

ROOT="${1:-.runtime/original-es2}"
LOGIN="$ROOT/mudlib/adm/daemons/logind.c"
CHAR_D="$ROOT/mudlib/adm/daemons/chard.c"
HUMAN="$ROOT/mudlib/daemon/race/human.c"
AVATAR="$ROOT/mudlib/daemon/race/avatar.c"

for file in "$LOGIN" "$CHAR_D" "$HUMAN" "$AVATAR"; do
  test -f "$file" || {
    echo "FAIL／失敗：缺少 Human/Avatar dependency：$file" >&2
    exit 1
  }
done

# Dynamic Character Creation／最新 ES2M 以可負擔種族清單及 callback 建角。
grep -Fq 'private void show_race_menu (object ob)' "$LOGIN"
grep -Fq 'private void get_race (string arg, object ob, string *list)' "$LOGIN"
grep -Fq 'body->set_race (race);' "$LOGIN"
grep -Fq 'init_new_body (ob, body);' "$LOGIN"
grep -Fq 'user->set_class("commoner");' "$LOGIN"
grep -Fq 'user->set_level(1);' "$LOGIN"
grep -Fq 'CHAR_D->setup_char(user);' "$LOGIN"
grep -Fq 'if (race == "human" && random(100) < 1)' "$LOGIN"

# Daemon wiring／CHAR_D 必須依 race/class 呼叫對應 setup()。
grep -Fq 'RACE_D(ob->query_race())->setup (ob);' "$CHAR_D"
grep -Fq 'CLASS_D(ob->query_class())->setup (ob);' "$CHAR_D"

# Latest ES2M Human／人類：karma、八屬性、精氣神、護甲與年齡。
grep -Eq 'set\("karma", 5\);' "$HUMAN"
grep -Fq 'set("commoner_score_base", 100);' "$HUMAN"
for attr in str cor int spi cps dex con wis; do
  grep -Eq "\"$attr\"[[:space:]]*:[[:space:]]*13 \+ random\(6\)" "$HUMAN"
done
for stat in gin kee sen; do
  grep -Eq "\"$stat\"[[:space:]]*:[[:space:]]*35" "$HUMAN"
done
grep -Fq 'ob->add_temp("apply/armor", 10);' "$HUMAN"
grep -Fq '14 + random(4)' "$HUMAN"

# Latest ES2M Avatar／化身：獨立 daemon、較高屬性、karma 5、護甲 10。
grep -Eq 'set\("karma", 5\);' "$AVATAR"
grep -Fq 'set("commoner_score_base", 100);' "$AVATAR"
grep -Fq 'DAEMON_D->register_race_daemon("avatar");' "$AVATAR"
for attr in str cor int spi cps dex con wis; do
  grep -Eq "\"$attr\"[[:space:]]*:[[:space:]]*15 \+ random\(6\)" "$AVATAR"
done
for stat in gin kee sen; do
  grep -Eq "\"$stat\"[[:space:]]*:[[:space:]]*30" "$AVATAR"
done
grep -Fq 'ob->add_temp("apply/armor", 10);' "$AVATAR"
grep -Fq '14 + random(4)' "$AVATAR"

echo 'ES2M_AVATAR_SOURCE_PASS'
echo 'ES2M_AVATAR_STATIC_PASS:karma=5;attribute=15-20;armor=10;stats=30'
echo 'ES2M_HUMAN_SOURCE_PASS'
echo 'ES2M_HUMAN_STATIC_PASS:karma=5;attribute=13-18;armor=10;stats=35'
echo 'ES2M_DYNAMIC_RACE_CREATION_PASS'
echo 'RUNTIME_HANDOFF_TO_MAIN'
