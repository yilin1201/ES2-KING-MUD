#!/usr/bin/env bash
set -euo pipefail
# ES2-KING 人物管理系統 V0：只檢查 Expansion 管理層，不改寫 Original snapshot。
ROOT="es2_king_expansion/runtime/mudlib"
for f in kinfo kset kskill kclass kexp kmoney kitem klocate ksave kadmin khelp; do test -f "$ROOT/cmds/adm/$f.c"; done
test -f "$ROOT/adm/daemons/kingd.c"
test -f "$ROOT/adm/daemons/kadmind.c"
grep -Fq 'interactive(actor)' "$ROOT/adm/daemons/kingd.c"
grep -Fq 'query("id") == KING_OWNER_ID' "$ROOT/adm/daemons/kingd.c"
grep -Fq 'wiz_level(actor) >= wiz_level("(admin)")' "$ROOT/adm/daemons/kingd.c"
grep -Fq 'value>99' "$ROOT/adm/daemons/kingd.c"
grep -Fq 'value>999' "$ROOT/adm/daemons/kingd.c"
grep -Fq 'set_stat_maximum' "$ROOT/adm/daemons/kingd.c"
grep -Fq 'set_stat_effective' "$ROOT/adm/daemons/kingd.c"
grep -Fq 'set_stat_current' "$ROOT/adm/daemons/kingd.c"
grep -Fq 'val > 300' "$ROOT/feature/char/skill.c"
grep -Fq 's > 300' "$ROOT/feature/char/skill.c"
! grep -Fq 'val > 300' "es2m_snapshot/mudlib/feature/char/skill.c"
grep -Fq 'audit_log' "$ROOT/adm/daemons/kadmind.c"
grep -Fq 'query_audit' "$ROOT/adm/daemons/kadmind.c"
grep -Fq 'kadmin audit' "$ROOT/cmds/adm/kadmin.c"
for f in kset kskill kclass kmoney kitem klocate ksave; do grep -Fq 'SECURED_ADMIN_COMMAND' "$ROOT/cmds/adm/$f.c"; done
grep -Fq 'BLOCKED' "$ROOT/cmds/adm/kexp.c"
grep -Fq '01 kinfo' "$ROOT/cmds/adm/khelp.c"
grep -Fq '21 help kset' "$ROOT/cmds/adm/khelp.c"
echo "ES2-KING 人物管理系統 V0 STATIC SOURCE GATE PASS"
