#!/usr/bin/env bash
set -euo pipefail

ROOT="es2_king_expansion/runtime/mudlib"
for file in \
  "$ROOT/daemon/skill/kuxiao_force.c" \
  "$ROOT/daemon/skill/daxie_qisun_blade.c" \
  "$ROOT/cmds/std/perform.c" \
  "$ROOT/adm/daemons/kingmartiald.c" \
  "$ROOT/cmds/adm/kingmartial.c"
do
  test -f "$file"
done

grep -Fq 'valid_enable(string usage)' "$ROOT/daemon/skill/kuxiao_force.c"
grep -Fq 'actor->skill_mapped("force") == "kuxiao force"' "$ROOT/daemon/skill/daxie_qisun_blade.c"
grep -Fq '大邪金身已啟動；反震、減傷與持續時間仍為 UNKNOWN' "$ROOT/daemon/skill/daxie_qisun_blade.c"
grep -Fq 'actor->delete("es2_king/daxie_jinshen")' "$ROOT/daemon/skill/daxie_qisun_blade.c"
for form in sunpi sunrou sunjin sungu sunmai sunqi qisun; do
  grep -Fq "\"$form\"" "$ROOT/daemon/skill/daxie_qisun_blade.c"
done
grep -Fq 'target->receive_damage' "$ROOT/daemon/skill/daxie_qisun_blade.c"
grep -Fq 'target->add_temp("apply/armor", -balance_penalty)' "$ROOT/daemon/skill/daxie_qisun_blade.c"
grep -Fq 'target->consume_stat("sen", damage, actor)' "$ROOT/daemon/skill/daxie_qisun_blade.c"
grep -Fq 'target->consume_stat("gin", damage, actor)' "$ROOT/daemon/skill/daxie_qisun_blade.c"
grep -Fq 'es2_king/daxie_qisun/block_perform' "$ROOT/cmds/std/perform.c"
grep -Fq 'actor->set_skill("kuxiao force", level)' "$ROOT/adm/daemons/kingmartiald.c"
grep -Fq 'actor->set_skill("daxie qisun blade", level)' "$ROOT/adm/daemons/kingmartiald.c"
grep -Fq 'Expansion Overlay' "$ROOT/cmds/std/perform.c"
echo 'DAXIE QISUN STATIC PASS／Canon、Original 邊界、依賴與七式入口完整。'
