#!/usr/bin/env bash
set -euo pipefail

ROOT="es2_king_expansion/runtime/mudlib"
DOC="es2_king_expansion/research/m26_king_admin_creation.md"
for file in "$DOC" "$ROOT/adm/daemons/kingd.c" "$ROOT/cmds/adm/kingcreate.c" "$ROOT/obj/king/creation_mark.c" scripts/apply_es2_king_expansion.sh; do
  test -f "$file" || { echo "M26 STATIC FAIL：缺少 $file"; exit 1; }
done

grep -Fq 'SECURED_ADMIN_COMMAND' "$ROOT/cmds/adm/kingcreate.c"
grep -Fq 'wiz_level(actor) >= wiz_level("(admin)")' "$ROOT/adm/daemons/kingd.c"
grep -Fq 'creation_registry[id]' "$ROOT/adm/daemons/kingd.c"
grep -Fq 'es2_king_expansion/runtime/mudlib' scripts/apply_es2_king_expansion.sh
for term in 'ES2-KING Expansion' 'Project Canon' UNKNOWN 'Original／Expansion 分離' '任意路徑'; do
  grep -Fq "$term" "$DOC" || { echo "M26 STATIC FAIL：缺少邊界 $term"; exit 1; }
done

echo 'M26 KING ADMIN STATIC PASS／雙層權限、登錄表與 Original 分離正常。'
