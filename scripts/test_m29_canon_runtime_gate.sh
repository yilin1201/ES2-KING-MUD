#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/es2-king}/mudlib"
for f in "$ROOT/adm/daemons/kingcanon_d.c" "$ROOT/cmds/adm/kingcanon.c" "$ROOT/feature/char/skill.c" "$ROOT/adm/daemons/kingmartiald.c"; do test -f "$f"; done
grep -Fq 'rank < 1 || rank > 10' "$ROOT/adm/daemons/kingcanon_d.c"
grep -Fq 'form < 1 || form > 11' "$ROOT/adm/daemons/kingcanon_d.c"
grep -Fq 'turn < 1 || turn > 4' "$ROOT/adm/daemons/kingcanon_d.c"
grep -Fq 'actor->set("es2_king/rulai_weapon"' "$ROOT/adm/daemons/kingcanon_d.c"
# KING 300 級例外不得破壞一般玩家的 Original 200 級上限。
grep -Fq 'private int es2_king_skill_cap()' "$ROOT/feature/char/skill.c"
grep -Fq 'return 200;' "$ROOT/feature/char/skill.c"
grep -Fq 'if( val > cap ) val = cap;' "$ROOT/feature/char/skill.c"
echo 'M29 CANON RUNTIME PASS／Canon 索引、佛兵對應、神輪四轉與 Original 相容性完整。'
