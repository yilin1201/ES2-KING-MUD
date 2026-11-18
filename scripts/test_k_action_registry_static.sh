#!/usr/bin/env bash
set -euo pipefail
ROOT="es2_king_expansion/runtime/mudlib"
grep -Fq '"verb":"climb"' "$ROOT/adm/daemons/kmapd.c"
grep -Fq '"arg":"榕樹"' "$ROOT/adm/daemons/kmapd.c"
grep -Fq '"target":"/d/snow/tree"' "$ROOT/adm/daemons/kmapd.c"
grep -Fq 'KMAP_D->query_actions' "$ROOT/cmds/std/kroom.c"
grep -Fq 'KMAP_D->query_actions' "$ROOT/cmds/std/kact.c"
echo 'K ACTION REGISTRY STATIC PASS'
