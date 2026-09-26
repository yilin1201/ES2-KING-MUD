#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/es2-king}"
NPC="$ROOT/mudlib/d/arena/npc/mei_hanshuang.c"
ROOM="$ROOT/mudlib/d/arena/yanwujie.c"
SKILL="$ROOT/mudlib/d/arena/skill/lunmay.c"
WEAPON="$ROOT/mudlib/d/arena/obj/charred_plum_branch.c"
WUJI="$ROOT/mudlib/d/king/wuji_realm.c"
test -f "$NPC";test -f "$ROOM";test -f "$SKILL";test -f "$WEAPON";test -f "$WUJI"
grep -Fq '"/d/arena/npc/mei_hanshuang" : 1' "$ROOM"
grep -Fq '"enter" : "/d/arena/yanwujie"' "$WUJI"
grep -Fq '"out" : "/d/king/wuji_realm"' "$ROOM"
! grep -Fq '\\n        "enter"' "$WUJI"
for a in str cor int spi cps dex con wis;do grep -Fq "set_attr(\"$a\", 50)" "$NPC";done
for sk in "hainmay force" advance_lunmay lunmay mayin seven force sword parry dodge unarmed;do grep -Fq "set_skill(\"$sk\", 300)" "$NPC";done
grep -Fq 'map_skill("sword", "lunmay")' "$NPC"
grep -Fq 'activate_mirror_state' "$NPC"
grep -Fq 'cold_plum/mirror_state' "$NPC"
grep -Fq 'mirror_mind/sustain_formula", "UNKNOWN"' "$NPC"
grep -Fq 'carry_object("/d/arena/obj/charred_plum_branch")' "$NPC"
for form in 梅二方劍 梅四方劍 梅八方劍 愛霜恨雪 寒霜三千里 傲梅暗劍訣;do grep -Fq "$form" "$SKILL";done
# 未知倍率／續航公式不得偷偷數值化；六式 action 係數維持 neutral 0。
test "$(grep -Fc '"attack":0, "force":0, "defense":0' "$SKILL")" -ge 6
! grep -Eq '1900|1850|35%|480000|360000|320000' "$NPC"
echo "COLD PLUM ARENA STATIC PASS：梅寒霜八屬性50、Arena effective Skill 300、明鏡止水狀態與冷梅六式 Combat mapping 完整；未知倍率仍 UNKNOWN。"
