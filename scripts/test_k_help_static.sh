#!/usr/bin/env bash
set -euo pipefail
ROOT="es2_king_expansion/runtime/mudlib"
for f in k wiz; do test -f "$ROOT/cmds/usr/$f.c"; grep -Fq 'ES2-KING 管理指令' "$ROOT/cmds/usr/$f.c"; done
grep -Fq '一般玩家：k = kill' "$ROOT/cmds/usr/k.c"
echo 'K HELP STATIC PASS'
