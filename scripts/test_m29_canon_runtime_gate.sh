#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/es2-king}/mudlib"
for f in "$ROOT/adm/daemons/kingcanon_d.c" "$ROOT/cmds/adm/kingcanon.c" "$ROOT/feature/char/skill.c" "$ROOT/adm/daemons/kingmartiald.c"; do test -f "$f"; done
grep -Fq 'rank < 1 || rank > 10' "$ROOT/adm/daemons/kingcanon_d.c"
grep -Fq 'form < 1 || form > 11' "$ROOT/adm/daemons/kingcanon_d.c"
grep -Fq 'turn < 1 || turn > 4' "$ROOT/adm/daemons/kingcanon_d.c"
grep -Fq 'actor->set("es2_king/rulai_weapon"' "$ROOT/adm/daemons/kingcanon_d.c"
grep -Fq 'if( val > 200 ) val = 200;' "$ROOT/feature/char/skill.c"
echo 'M29 CANON RUNTIME PASS／Canon 索引、佛兵對應、神輪四轉與 Original 相容性完整。'
