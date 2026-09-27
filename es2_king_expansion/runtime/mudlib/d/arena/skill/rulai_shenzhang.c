/*---
description: ES2-KING 如來神掌正式 Combat Skill／如來招式採青色【】外框＋黃色名稱，Combat 敘述維持原遊戲白色
---*/
#include <ansi.h>
#pragma save_binary
inherit SKILL;

// Evidence：招式名稱來自 ES2-KING Project Canon M29。
// Original ES2 未發現如來神掌 Combat Source；因此不補造傷害倍率、命中、Busy、消耗或特殊效果。
mapping *rulai_actions = ({
    ([ "name":"佛光初現", "action":HIW "$N使出如來神掌" HIC "【" HIY "佛光初現" HIC "】" HIW "，掌勢如晨曦初綻，直取$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"金頂佛燈", "action":HIW "$N使出如來神掌" HIC "【" HIY "金頂佛燈" HIC "】" HIW "，掌影如佛燈長明，直取$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"佛動山河", "action":HIW "$N使出如來神掌" HIC "【" HIY "佛動山河" HIC "】" HIW "，雙掌平推，掌勢直撼$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"佛問迦藍", "action":HIW "$N使出如來神掌" HIC "【" HIY "佛問迦藍" HIC "】" HIW "，掌意沉凝，直叩$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"迎佛西天", "action":HIW "$N使出如來神掌" HIC "【" HIY "迎佛西天" HIC "】" HIW "，掌勢迴轉，向$n的$l拍去！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"佛光普照", "action":HIW "$N使出如來神掌" HIC "【" HIY "佛光普照" HIC "】" HIW "，掌影展開，直逼$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"天佛降世", "action":HIW "$N使出如來神掌" HIC "【" HIY "天佛降世" HIC "】" HIW "，一掌自上而下壓向$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"佛鎮八荒", "action":HIW "$N使出如來神掌" HIC "【" HIY "佛鎮八荒" HIC "】" HIW "，掌勢橫掃八方，直取$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"佛法無邊", "action":HIW "$N使出如來神掌" HIC "【" HIY "佛法無邊" HIC "】" HIW "，掌勢連綿而出，攻向$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"九九歸一・萬佛朝宗", "action":HIW "$N使出如來神掌" HIC "【" HIY "九九歸一・萬佛朝宗" HIC "】" HIW "，前九佛意歸一，一掌直取$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"天舞梵輪・萬相歸墟",
       "action":HIW "$N神色淡漠超然，雙手緩緩於胸前結成「大日如來無相根本印」。\n"
                "嗡————！\n"
                "冥冥虛空之中，一道超越大千維度、純白無瑕的曼陀羅法輪悄然凝聚！\n"
                "輪身無量梵文流轉不息，神光照徹三千大千世界——\n"
                "正是諸法終點、萬相歸墟之輪——" HIC "【" HIY "阿賴耶識・歸墟神輪" HIC "】" HIW "！\n"
                "$N雙眸微闔，口中緩緩吐出八字：\n"
                "「天舞梵輪……萬相歸墟。」\n"
                "一語既出，四方天地剎那失色！\n"
                "整座空間維度轟然向內坍縮，化作一方絕對封閉的大日曼陀羅法界，將$n的因果、氣機與生機盡數鎖定於法界中央！\n"
                HIC "【" HIY "神輪四轉・因果寂滅" HIC "】\n"
                HIW "第一轉" HIC "【" HIY "斷五感" HIC "】" HIM " 肉體墜永夜！" HIW "\n"
                "純白神輪無聲轉過四分之一，金梵神芒驟然沖霄而起，化作遮天蔽日的無邊光幕！\n"
                "剎那間，虛空墜入永恆死寂——風止、雷歇、萬籟俱寂，天地萬象彷彿凝固於這一瞬！\n"
                "$n目不能視、耳不能聞、身不能觸，五感與外界的聯繫被層層斷絕！\n"
                "——五感斷！\n"
                "第二轉" HIC "【" HIY "絕六識" HIC "】" HIM " 思維盡停滯！" HIW "\n"
                "神輪再轉，半輪既成！\n"
                "浩瀚界神界力如萬重怒濤轟然爆發，席捲整座大日曼陀羅法界！\n"
                "所過之處，天地法則震盪、神識受制、意念凝滯；$n體內奔騰的護體真氣亦隨之層層紊亂！\n"
                "——六識絕！\n"
                "第三轉" HIC "【" HIY "滅七識" HIC "】" HIM " 本能悉瓦解！" HIW "\n"
                "神輪轉至四分之三，$N周身不滅戰意轟然攀至極境！\n"
                "戰意與阿賴耶識歸墟巨力交融為一，化作遮天蔽日的滅世磨盤，自九霄之上悍然鎮落！\n"
                "轟然巨響中，虛空寸寸崩裂，$n周身護體罡氣層層瓦解，本源氣機亦在歸墟巨力之下劇烈震盪！\n"
                "——七識滅！\n"
                "第四轉" HIC "【" HIY "破八識・萬相歸墟" HIC "】" HIM " 因果盡歸虛！" HIW "\n"
                "轟————！\n"
                "純白神輪完成最後一轉！\n"
                "$N身後那座遮天蔽日的大日曼陀羅法界驟然展開，旋即開始瘋狂旋轉、收縮、坍陷！\n"
                "金梵神芒！界神界力！不滅戰意！大日曼陀羅法界！\n"
                "四境於此刻盡數匯聚！\n"
                "億萬神光由無窮歸於唯一，浩瀚法界亦在剎那間極致坍縮——\n"
                "最終，所有光芒、戰意與法界之力凝聚成一道貫穿天地、純白無瑕的——\n"
                "「琉璃純白・歸墟神芒」！\n"
                "轟隆隆隆隆————！！！\n"
                "純白神芒悍然破界！所過之處，萬象失色、虛空震裂，層層空間如琉璃般轟然破碎！\n"
                "神芒挾神輪四轉歸一之威，跨越重重虛空，以萬相俱滅、諸法歸墟之勢——悍然轟向$n！\n"
                "——八識破！\n"
                "神輪四轉，五感斷、六識絕、七識滅、八識破！\n"
                "萬相歸墟，諸法寂滅！" NOR,
       "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
});

private void create()
{
    seteuid(getuid());
    // Original ES2 Combat 會透過 SKILL_D("rulai shenzhang") 尋找已登記的 Skill Daemon。
    DAEMON_D->register_skill_daemon("rulai shenzhang");
    setup();
}

int valid_enable(string usage) { return usage == "unarmed"; }

// Original ES2 feature/char/attack.c 的正式徒手 Combat 入口。
// 不自行建立第二套 heartbeat；由 Original attack() 每回合呼叫。
void attack_using(object me, object opponent, string skill)
{
    mapping action;
    int index;

    if (!opponent) return;

    index = me->query_temp("rulai/form_index");
    if (index < 0 || index >= sizeof(rulai_actions)) index = 0;
    action = rulai_actions[index];
    me->set_temp("rulai/form_index", (index + 1) % sizeof(rulai_actions));
    me->set_temp("rulai/last_form", action["name"]);

    // 不傳 weapon：如來神掌是正式 unarmed Combat。
    COMBAT_D->fight(me, opponent, "unarmed", action);
}
