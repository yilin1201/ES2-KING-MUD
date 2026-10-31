#!/usr/bin/env bash
set -euo pipefail
F="es2_king_expansion/runtime/mudlib/daemon/skill/daxie_qisun_blade.c"
grep -Fq '"sunpi" : "雷霆震不還"' "$F"
grep -Fq '"sunpi" : "損皮"' "$F"
grep -Fq '"sunpi" : "第一損"' "$F"
grep -Fq 'HIG + "【" + form_names[form] + "・"' "$F"
grep -Fq 'HIR + form_damage_names[form] + HIG + "】" + NOR' "$F"
echo "DAXIE QISUN COLOR STATIC PASS"
