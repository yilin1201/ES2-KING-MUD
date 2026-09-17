#!/usr/bin/env bash
set -euo pipefail
ROOT="es2_king_expansion/runtime/mudlib"
DOC="es2_king_expansion/research/m28_yijinjing_batian.md"
for file in "$ROOT/adm/daemons/kingmartiald.c" "$ROOT/cmds/adm/kingmartial.c" "$DOC"; do test -f "$file"; done
grep -Fq 'level > 300' "$ROOT/adm/daemons/kingmartiald.c"
grep -Fq 'phase != "zhao" && phase != "ji"' "$ROOT/adm/daemons/kingmartiald.c"
grep -Fq 'es2_king/yijinjing_level' "$ROOT/adm/daemons/kingmartiald.c"
for term in '紅級通脈' '黃級鍛骨' '青級生生' '藍級冰魄' '金級破虛' '白級聖光' '黑級無極' 'UNKNOWN' 'Original ES2'; do grep -Fq "$term" "$DOC"; done
echo 'M28 MARTIAL STATIC PASS／七境、兆／極與 Original 邊界正常。'
