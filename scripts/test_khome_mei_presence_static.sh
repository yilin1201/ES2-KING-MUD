#!/usr/bin/env bash
set -euo pipefail

# Khome／梅寒霜靜態入口檢查：只檢查指定路徑與載入接線，不冒充真實 Driver Runtime PASS。
ROOT="${1:-.}"
MUDLIB="$ROOT/es2_king_expansion/runtime/mudlib"
KHOME="$MUDLIB/cmds/adm/khome.c"
HOME="$MUDLIB/custom/home/room/home_hall.c"
ARENA="$MUDLIB/d/arena/yanwujie.c"
WUJI="$MUDLIB/d/king/wuji_realm.c"
MEI="$MUDLIB/d/arena/npc/mei_hanshuang.c"
HELP="$MUDLIB/docs/help/home_help.txt"

for file in "$KHOME" "$HOME" "$ARENA" "$WUJI" "$MEI" "$HELP" \
  "$MUDLIB/custom/home/npc/butler.c" \
  "$MUDLIB/custom/home/obj/storage_chest.c" \
  "$MUDLIB/custom/home/obj/development_board.c"; do
  test -f "$file" || { echo "KHOME/MEI STATIC FAIL：缺少 $file"; exit 1; }
done

grep -Fq 'new("/custom/home/room/home_hall")' "$KHOME"
grep -Fq 'home->set_home_owner(me)' "$KHOME"
grep -Fq 'SECURED_ADMIN_COMMAND' "$KHOME"
grep -Fq 'KING_D->authorized(me)' "$KHOME"
grep -Fq '"/d/arena/npc/mei_hanshuang" : 1' "$ARENA"
grep -Fq '"enter" : "/d/arena/yanwujie"' "$WUJI"
grep -Fq '"out" : "/d/king/wuji_realm"' "$ARENA"
grep -Fq 'setup();' "$ARENA"
grep -Fq 'set_name("梅寒霜"' "$MEI"
grep -Fq '入口指令：khome' "$HELP"
grep -Fq 'kinghome' "$HELP"
grep -Fq '/d/arena/yanwujie' "$HELP"

echo "KHOME/MEI STATIC PASS：Owner 自宅入口、家園大廳依賴、無極之境→演武界→梅寒霜 NPC 載入拓撲存在。"
