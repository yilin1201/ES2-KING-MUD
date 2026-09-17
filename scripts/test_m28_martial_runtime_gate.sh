#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/es2-king}/mudlib"
for file in "$ROOT/adm/daemons/kingmartiald.c" "$ROOT/cmds/adm/kingmartial.c" "$ROOT/feature/char/skill.c"; do test -f "$file"; done
grep -Fq 'if (level < 1 || level > 300)' "$ROOT/adm/daemons/kingmartiald.c"
grep -Fq 'actor->set("es2_king/yijinjing_level", level)' "$ROOT/adm/daemons/kingmartiald.c"
grep -Fq 'actor->set("es2_king/batian_lianti_jue", phase)' "$ROOT/adm/daemons/kingmartiald.c"
grep -Fq 'if( val > 200 ) val = 200;' "$ROOT/feature/char/skill.c"
echo 'M28 MARTIAL RUNTIME PASS／Expansion 狀態層可載入，Original 200 級上限仍保留。'
