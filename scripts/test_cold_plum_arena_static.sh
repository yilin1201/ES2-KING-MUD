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
grep -Fq 'map_skill("force", "hainmay force")' "$NPC"
grep -Fq 'map_skill("sword", "lunmay")' "$NPC"
grep -Fq 'attack(opponent);' "$NPC"
grep -Fq 'activate_mirror_state' "$NPC"
grep -Fq 'cold_plum/mirror_state' "$NPC"
grep -Fq 'mirror_mind/sustain_formula", "UNKNOWN"' "$NPC"
# 梅寒霜正式 Phase Transition Canon：30 次 Combat callback 後冷梅→傲劍，戰後 reset。
grep -Fq 'add_temp("aojian/attack_rounds", 1)' "$NPC"
grep -Fq 'query_temp("aojian/attack_rounds") >= 30' "$NPC"
grep -Fq 'map_skill("sword", "au-chan sword")' "$NPC"
grep -Fq 'map_skill("parry", "au-chan sword")' "$NPC"
grep -Fq '寒霜碎裂，冷梅將折。' "$NPC"
grep -Fq '三十招了……能逼我棄冷梅、出傲劍，你足以自傲。' "$NPC"
grep -Fq '冷梅既凋——唯傲劍獨立！' "$NPC"
grep -Fq 'delete_temp("aojian")' "$NPC"
AOJIAN="$ROOT/mudlib/daemon/skill/au-chan_sword.c"
test -f "$AOJIAN"
# 實機 UI：人物/動作敘述維持白色，招式名稱才使用各式 ANSI 色。
grep -Fq 'HIW "$N劍光一閃' "$AOJIAN"
grep -Fq 'HIW "$N虛轉反側' "$AOJIAN"
# 劍領風騷必須進入 Phase 2 自動 attack pool，不可只存在 perform_action 手動極招。
# 實機 Historical Evidence 配色：劍紅、領黃、風綠、騷青；六段忠綠／武紅／義紫／德青／狂金／情藍。
test "$(grep -Fc 'HIR "劍" HIY "領" HIG "風" HIC "騷" HIW' "$AOJIAN")" -ge 2
grep -Fq '([ "name":"忠","color":HIG' "$AOJIAN"
grep -Fq '([ "name":"武","color":HIR' "$AOJIAN"
grep -Fq '([ "name":"義","color":HIM' "$AOJIAN"
grep -Fq '([ "name":"德","color":HIC' "$AOJIAN"
grep -Fq '([ "name":"狂","color":HIY' "$AOJIAN"
grep -Fq '([ "name":"情","color":HIB' "$AOJIAN"
# 原版劍舞版面：六段每段都是完整單行「劍領風騷『段名』，一道X色的劍氣射向目標」，不可拆成只有段名/特效的零碎行。
grep -Fq '"action":HIW "$N施展傲劍訣中的極招『" HIR "劍" HIY "領" HIG "風" HIC "騷" HIW "』『"+stage["color"]+stage["name"]+HIW+"』，一道"+stage["color"]+stage["color_name"]+HIW+"的劍氣射向$n！" NOR' "$AOJIAN"
# 原版人物敘述不可為了排版而縮寫：主詞＋施展傲劍訣＋極招＋劍領風騷＋段名＋劍氣＋目標必須全部存在。
grep -Fq '$N施展傲劍訣中的極招' "$AOJIAN"
grep -Fq '的劍氣射向$n！' "$AOJIAN"
grep -Fq 'index=random(sizeof(aojian_actions) + 1)' "$AOJIAN"
grep -Fq 'jianling_combat_attack(me, opponent, weapon)' "$AOJIAN"
grep -Fq 'me->set_temp("aojian/last_form","劍領風騷")' "$AOJIAN"
grep -Fq 'void jianling_combat_attack(object me, object opponent, object weapon)' "$AOJIAN"
# 梅寒霜 Phase 2 劍舞節奏：4～7 輪內保證一次，自動循環，不依賴玩家手動 perform。
grep -Fq 'set_temp("aojian/jianling_target", 4 + random(4))' "$NPC"
grep -Fq 'query_temp("aojian/jianling_rounds") >= query_temp("aojian/jianling_target")' "$NPC"
grep -Fq -- '->jianling_combat_attack(this_object(), opponent, weapon)' "$NPC"
for stage in 忠 武 義 德 狂 情; do grep -Fq "\"name\":\"$stage\"" "$AOJIAN"; done
grep -Fq 'carry_object("/d/arena/obj/charred_plum_branch")' "$NPC"
for form in 梅二方劍 梅四方劍 梅八方劍 愛霜恨雪 寒霜三千里 傲梅暗劍訣 傲雪藏鋒 逆折寒梅;do grep -Fq "$form" "$SKILL";done
# Gameplay Runtime Evidence／明鏡止水全白；梅二／四／八方劍【】外框紅色、框內名稱白色；愛霜恨雪使用青色「」；寒霜三千里使用全白【】；如來神掌另由其 Skill Gate 管理黃色名稱。
grep -Fq 'HIR "【" HIW "梅二方劍" HIR "】" HIW "」！\n"' "$SKILL"
grep -Fq 'HIR "【" HIW "梅四方劍" HIR "】" HIW "」！\n"' "$SKILL"
grep -Fq 'HIR "【" HIW "梅八方劍" HIR "】" HIW "」！\n"' "$SKILL"
grep -Fq 'HIY "二道" HIW' "$SKILL"
grep -Fq 'HIY "四道" HIW' "$SKILL"
grep -Fq 'HIY "八道" HIW' "$SKILL"
grep -Fq 'HIC "「愛霜恨雪」" HIW' "$SKILL"
! grep -Fq '【愛霜恨雪】' "$SKILL"
grep -Fq '"action":HIW "$N催運寒梅心法使出【 寒霜三千里 】劍氣' "$SKILL"
grep -Fq '竟漸入「【 明  鏡  止  水 】」之境界' "$NPC"
! grep -Fq 'HIC "【 明  鏡  止  水 】"' "$NPC"
grep -Fq '心摒若水，眼明如鏡' "$NPC"
grep -Fq '幻化出了" HIY "二道" HIW "劍氣' "$SKILL"
grep -Fq '幻化出了" HIY "四道" HIW "劍氣' "$SKILL"
grep -Fq '幻化出了" HIY "八道" HIW "劍氣' "$SKILL"
for phrase in "明劍欺敵，暗劍藏殺；傲雪藏鋒・逆折寒梅。" 咽喉 心口 氣海 "右手" "左袖";do grep -Fq "$phrase" "$SKILL";done
# 未知倍率／續航公式不得偷偷數值化；六式 action 係數維持 neutral 0。
test "$(grep -Fc '"attack":0, "force":0, "defense":0' "$SKILL")" -ge 6
! grep -Eq '1900|1850|35%|480000|360000|320000' "$NPC"
echo "COLD PLUM ARENA STATIC PASS：梅寒霜八屬性50、Arena effective Skill 300、明鏡止水狀態與冷梅六式 Combat mapping 完整；未知倍率仍 UNKNOWN。"