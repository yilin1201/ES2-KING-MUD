#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.runtime/es2-king}/mudlib"
ROOM="$ROOT/d/king/wuji_realm.c"
COMMAND="$ROOT/cmds/adm/kinghome.c"
SQUARE="$ROOT/d/snow/square.c"

for file in "$ROOM" "$COMMAND" "$SQUARE"; do
  test -f "$file" || { echo "M27 RUNTIME FAIL：缺少 $file"; exit 1; }
done

grep -Fq 'set("short", "天神殿・無極之境")' "$ROOM"
grep -Fq '"down" : "/d/snow/square"' "$ROOM"
grep -Fq 'set("no_fight", 1)' "$ROOM"
grep -Fq 'SECURED_ADMIN_COMMAND' "$COMMAND"
grep -Fq 'me->move("/d/king/wuji_realm")' "$COMMAND"
grep -Fq 'set("short", "廣場中央")' "$SQUARE"

# M26 Regression／M26 回歸：創造服務仍使用登錄表，沒有因 M27 開放任意路徑。
grep -Fq 'file = creation_registry[id]' "$ROOT/adm/daemons/kingd.c"

echo 'M27 WUJI REALM RUNTIME PASS／神域、凡間出口與 M26 權限邊界完整。'
