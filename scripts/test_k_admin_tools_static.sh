#!/usr/bin/env bash
set -euo pipefail
ROOT="es2_king_expansion/runtime/mudlib"
for f in kadmind kadmin khome kcreate kcanon kmartial; do
  case "$f" in kadmind) test -f "$ROOT/adm/daemons/$f.c";; *) test -f "$ROOT/cmds/adm/$f.c";; esac
done
for f in kroom kexit kgoto kmap kact kwhere knpc kitem kobj ktrace kbroken kmiss; do test -f "$ROOT/cmds/std/$f.c"; done
grep -Fq 'id=="king"' "$ROOT/adm/daemons/kadmind.c"
grep -Fq 'r=="wizard" || r=="arch"' "$ROOT/adm/daemons/kadmind.c"
grep -Fq 'SECURED_ADMIN_COMMAND' "$ROOT/cmds/adm/kadmin.c"
grep -Fq 'STATIC SOURCE ANALYSIS REQUIRED' "$ROOT/cmds/std/kact.c"
for f in kadmin khome kcreate kcanon kmartial; do grep -Fq 'int help(object me)' "$ROOT/cmds/adm/$f.c"; done
for f in kroom kexit kgoto kmap kact kwhere knpc kitem kobj ktrace kbroken kmiss; do grep -Fq 'int help(object me)' "$ROOT/cmds/std/$f.c"; done
for label in 'VISIBLE / RAW EXIT' 'MISSING' 'BROKEN' 'STATIC SOURCE ANALYSIS REQUIRED'; do grep -Fq "$label" "$ROOT/cmds/std/kexit.c"; done
# Original k=kill 由 aliasd 保持；Expansion 不得修改或覆蓋 Original alias daemon。
test ! -e "$ROOT/adm/daemons/aliasd.c"
echo 'K ADMIN TOOLS STATIC PASS'
