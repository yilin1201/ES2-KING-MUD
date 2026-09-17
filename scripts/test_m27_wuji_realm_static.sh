#!/usr/bin/env bash
set -euo pipefail

ROOM="es2_king_expansion/runtime/mudlib/d/king/wuji_realm.c"
COMMAND="es2_king_expansion/runtime/mudlib/cmds/adm/kingrealm.c"
DOC="es2_king_expansion/research/m27_wuji_realm_runtime.md"
for file in "$ROOM" "$COMMAND" "$DOC" es2_king_expansion/admin_rooms/wuji_realm.md; do
  test -f "$file" || { echo "M27 STATIC FAIL：缺少 $file"; exit 1; }
done

grep -Fq 'SECURED_ADMIN_COMMAND' "$COMMAND"
grep -Fq '"down" : "/d/snow/square"' "$ROOM"
grep -Fq 'wiz_level(visitor) < wiz_level("(admin)")' "$ROOM"
grep -Fq '此境超脫凡塵，不承常理，亦不受三千天地法則所拘。' "$ROOM"
for term in 'ES2-KING Expansion' 'Project Canon' 'Admin Room' UNKNOWN 'Original `/d/snow/square.c` 不修改'; do
  grep -Fq "$term" "$DOC" || { echo "M27 STATIC FAIL：缺少 $term"; exit 1; }
done

echo 'M27 WUJI REALM STATIC PASS／Canon 描述、唯一出口與管理邊界正常。'
