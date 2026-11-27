#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.runtime/es2-king}/mudlib"
ROOM="$ROOT/d/king/wuji_realm.c"
COMMAND="$ROOT/cmds/adm/kinghome.c"
SQUARE="$ROOT/d/snow/square.c"
KHOME="$ROOT/cmds/adm/khome.c"
HOME="$ROOT/custom/home/room/home_hall.c"
ARENA="$ROOT/d/arena/yanwujie.c"
MEI="$ROOT/d/arena/npc/mei_hanshuang.c"

for file in "$ROOM" "$COMMAND" "$SQUARE" "$KHOME" "$HOME" "$ARENA" "$MEI"; do
  test -f "$file" || { echo "M27 RUNTIME FAIL：缺少 $file"; exit 1; }
done

grep -Fq 'set("short", "天神殿・無極之境")' "$ROOM"
grep -Fq '"down" : "/d/snow/square"' "$ROOM"
grep -Fq 'set("no_fight", 1)' "$ROOM"
grep -Fq 'SECURED_ADMIN_COMMAND' "$COMMAND"
grep -Fq 'me->move("/d/king/wuji_realm")' "$COMMAND"
grep -Fq 'set("short", "廣場中央")' "$SQUARE"

# Khome／KING Owner 私人家園必須在生成後的 Runtime 保留正確載入路徑。
grep -Fq 'new("/custom/home/room/home_hall")' "$KHOME"
grep -Fq 'home->set_home_owner(me)' "$KHOME"
grep -Fq 'KING_D->authorized(me)' "$KHOME"
grep -Fq 'void set_home_owner(object ob)' "$HOME"

# 梅寒霜／演武界房間與 NPC 必須一起存在於生成 Runtime，並保留雙向出口及自動生成設定。
grep -Fq '"enter" : "/d/arena/yanwujie"' "$ROOM"
grep -Fq '"out" : "/d/king/wuji_realm"' "$ARENA"
grep -Fq '"/d/arena/npc/mei_hanshuang" : 1' "$ARENA"
grep -Fq 'setup();' "$ARENA"
grep -Fq 'set_name("梅寒霜"' "$MEI"

# M26 Regression／M26 回歸：創造服務仍使用登錄表，沒有因 M27 開放任意路徑。
grep -Fq 'file = creation_registry[id]' "$ROOT/adm/daemons/kingd.c"

echo 'M27 WUJI REALM RUNTIME PASS／神域、凡間出口與 M26 權限邊界完整。'
