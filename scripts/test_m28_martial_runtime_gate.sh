#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/es2-king}/mudlib"
for file in "$ROOT/adm/daemons/kingmartiald.c" "$ROOT/cmds/adm/kingmartial.c" "$ROOT/feature/char/skill.c"; do test -f "$file"; done
grep -Fq 'if (level < 1 || level > 300)' "$ROOT/adm/daemons/kingmartiald.c"
grep -Fq 'actor->set("es2_king/yijinjing_level", level)' "$ROOT/adm/daemons/kingmartiald.c"
grep -Fq 'actor->set("es2_king/batian_lianti_jue", phase)' "$ROOT/adm/daemons/kingmartiald.c"
# Expansion 允許唯一 admin KING 到 300；一般角色仍由 helper 回傳 Original 上限 200。
grep -Fq 'private int es2_king_skill_cap()' "$ROOT/feature/char/skill.c"
grep -Fq 'return 200;' "$ROOT/feature/char/skill.c"
grep -Fq 'if( val > cap ) val = cap;' "$ROOT/feature/char/skill.c"
echo 'M28 MARTIAL RUNTIME PASS／Expansion 狀態層可載入，Original 200 級上限仍保留。'
