#!/usr/bin/env bash
set -euo pipefail
ROOT="es2_king_expansion/runtime/mudlib"; DOC="es2_king_expansion/research/m29_huntian_rulai_boundary.md"
for f in "$ROOT/adm/daemons/kingcanon_d.c" "$ROOT/cmds/adm/kingcanon.c" "$DOC"; do test -f "$f"; done
for term in 白雲煙 玫霞蕩 土崑崙 碧雪冰 紫星河 玄混沌 靛滄海 金晨曦 血穹蒼 玄宇宙 '九九歸一・萬佛朝宗' '天舞梵輪・萬相歸墟' '阿賴耶識・歸墟神輪' 斷五感 絕六識 滅七識 破八識 UNKNOWN; do grep -Fq "$term" "$DOC" "$ROOT/adm/daemons/kingcanon_d.c"; done
grep -Fq 'SECURED_ADMIN_COMMAND' "$ROOT/cmds/adm/kingcanon.c"
echo 'M29 CANON STATIC PASS／十層、十一式、佛兵與隱藏終式邊界正常。'
