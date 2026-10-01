#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-/opt/es2-king/runtime}"
M="$ROOT/mudlib"
files=(
  "$M/obj/king/god_ring.c"
  "$M/obj/king/omega_crown.c"
  "$M/obj/king/omega_plate.c"
  "$M/obj/king/omega_wings.c"
  "$M/obj/king/omega_girth.c"
  "$M/obj/king/omega_gloves.c"
  "$M/obj/king/omega_leggings.c"
  "$M/obj/king/omega_boots.c"
  "$M/cmds/adm/kring.c"
)
for f in "${files[@]}"; do test -r "$f" || { echo "KING OMEGA STATIC FAIL: missing $f"; exit 1; }; done
grep -Fq 'KING_D->authorized(me)' "$M/cmds/adm/kring.c"
grep -Fq 'present("god ring", me)' "$M/cmds/adm/kring.c"
grep -Fq '"armor":100' "$M/obj/king/omega_plate.c"
grep -Fq 'provision_creator_relics' "$M/adm/daemons/kingd.c"
echo 'KING_OMEGA_STATIC_PASS:ring-kring-seven-piece-original-wear-armor300'
