#!/usr/bin/env bash
set -euo pipefail
ROOT="es2_king_expansion/runtime/mudlib"
for f in k wiz; do test -f "$ROOT/cmds/usr/$f.c"; grep -Fq 'ES2-KING 管理指令' "$ROOT/cmds/usr/$f.c"; done
grep -Fq '一般玩家：k = kill' "$ROOT/cmds/usr/k.c"
grep -Fq 'if(lv>=99)' "$ROOT/cmds/usr/k.c"
grep -Fq 'if(lv>=2)' "$ROOT/cmds/usr/k.c"
cmp -s "$ROOT/cmds/usr/k.c" "$ROOT/cmds/usr/wiz.c"
echo 'K HELP STATIC PASS'
