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
echo 'K ADMIN TOOLS STATIC PASS'
