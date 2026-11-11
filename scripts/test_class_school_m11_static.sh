#!/usr/bin/env bash
# M11 Class/School／職業門派靜態回歸：保護使用者提供的 Original ES2 七職業與門派證據。
set -euo pipefail

DOC="original_es2/research/original_class_school_evidence.md"
test -f "$DOC"

# 七大職業 Original ID 與中文名稱都必須存在，避免後續重建漏掉職業。
for pair in \
  'fighter|武者' 'soldier|軍人' 'scholar|書生' 'taoist|道士' \
  'thief|盜賊／小偷' 'alchemist|方士' 'bonze|僧侶／和尚'; do
  id="${pair%%|*}"; zh="${pair#*|}"
  grep -q "\`$id\`" "$DOC"
  grep -q "$zh" "$DOC"
done

# School／門派證據：優先鎖住英文識別碼，中文低解析度名稱不拿來猜程式路徑。
for school in \
  fighter.fonxan fighter.snow fighter.lunmay fighter.au-chan fighter.tiger fighter.huge fighter.7b \
  soldier.ber scholar.sky scholar.myst \
  taoist.fire taoist.storm taoist.freeze taoist.thunder mao-shan.fog mao-shan.wind mao-shan.cloud taoist.adv \
  thief.longye thief.yin thief.adv \
  alchemist.wu alchemist.dragon alchemist.adv \
  bonze.moon bonze.wele bonze.kind; do
  grep -q "$school" "$DOC"
done

# 冷梅莊是後續 M14/M15 的重要交叉點，必須同時保留中文名稱與 fighter.lunmay 識別。
grep -q '冷梅莊' "$DOC"
grep -q 'fighter.lunmay' "$DOC"

echo 'M11 CLASS SCHOOL STATIC PASS／靜態通過：七職業與門派證據基線完整。'
