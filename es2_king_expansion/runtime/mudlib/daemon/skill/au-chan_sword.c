// ES2-KING：傲劍訣 Combat daemon。
// Original ES2 公開 Evidence 確認 skill id「au-chan sword」；招式與配色依使用者實機截圖重建。
// 未知 Original 命中、傷害倍率、無視防禦公式、消耗與 cooldown 不補造。
#include <ansi.h>
inherit SKILL;

mapping *aojian_actions = ({
([ "name":"千嬌百媚柔似水", "action":HIW "$N劍光一閃，一招「" HIM "千嬌百媚柔似水" HIW "」，挑起$w，輕靈曼妙的刺向$n的$l……" NOR, "attack":0,"force":0,"defense":0,"damage_type":"刺傷" ]),
([ "name":"佳人在殘醉臥君", "action":HIW "$N虛轉反側，一招「" HIR "佳人在殘醉臥君" HIW "」，手中$w上刺，隨後迴鋒下引攻$n的$l……" NOR, "attack":0,"force":0,"defense":0,"damage_type":"刺傷" ]),
([ "name":"了絕紅塵遁山林", "action":HIW "$N獰笑一聲，一招「" HIC "了絕紅塵遁山林" HIW "」使將開來，手中$w真氣貫注，劍芒四射，一道長虹貫過$n的$l……" NOR, "attack":0,"force":0,"defense":0,"damage_type":"刺傷" ]),
([ "name":"清風送爽墨雲飛", "action":HIW "$N一招「" HIB "清風送爽墨雲飛" HIW "」，手中$w劍氣大盛，$w挾著勁風迎面攻$n的$l……" NOR, "attack":0,"force":0,"defense":0,"damage_type":"割傷" ]),
([ "name":"渺盡人世絕惡意", "action":HIW "$N手中$w劍芒大盛，一招「" HIG "渺盡人世絕惡意" HIW "」，劍勢封鎖中路，直逼$n的$l！" NOR, "attack":0,"force":0,"defense":0,"damage_type":"刺傷" ]),
([ "name":"天始一乾景初開", "action":HIW "$N將手中$w一展，一式「" HIY "天始一乾景初開" HIW "」，展劍引勁後順勢攻向$n的$l！" NOR, "attack":0,"force":0,"defense":0,"damage_type":"刺傷" ]),
([ "name":"不識江山多嬌媚", "action":HIW "$N身體有如陀螺急轉，一招「" HIM "不識江山多嬌媚" HIW "」，旋身劍勢席捲$n的$l！" NOR, "attack":0,"force":0,"defense":0,"damage_type":"割傷" ]),
});

mapping *aojian_parries = ({
([ "name":"千嬌百媚柔似水", "action":HIW "$N劍光一閃，一招「" HIM "千嬌百媚柔似水" HIW "」，輕靈曼妙地引開$n的攻勢。" NOR ]),
([ "name":"佳人在殘醉臥君", "action":HIW "$N虛轉反側，一招「" HIR "佳人在殘醉臥君" HIW "」，虛實變向間卸開$n的攻勢。" NOR ]),
([ "name":"了絕紅塵遁山林", "action":HIW "$N真氣貫注$w，一招「" HIC "了絕紅塵遁山林" HIW "」，劍芒四射震開$n的攻勢。" NOR ]),
([ "name":"清風送爽墨雲飛", "action":HIW "$N手中$w劍氣大盛，一招「" HIB "清風送爽墨雲飛" HIW "」，挾著勁風盪開$n的攻勢。" NOR ]),
([ "name":"渺盡人世絕惡意", "action":HIW "$N手中$w劍芒大盛，一招「" HIG "渺盡人世絕惡意" HIW "」將$n的攻勢完全封住。" NOR ]),
([ "name":"天始一乾景初開", "action":HIW "$N將手中$w一展，一式「" HIY "天始一乾景初開" HIW "」將$n的攻勢化開。" NOR ]),
([ "name":"不識江山多嬌媚", "action":HIW "$N身體有如陀螺急轉，一招「" HIM "不識江山多嬌媚" HIW "」將$n的所有攻勢帶開。" NOR ]),
});

mapping *jianling_forms = ({
([ "name":"忠","color":HIG,"color_name":"綠色" ]), ([ "name":"武","color":HIR,"color_name":"紅色" ]),
([ "name":"義","color":HIM,"color_name":"紫色" ]), ([ "name":"德","color":HIC,"color_name":"青色" ]),
([ "name":"狂","color":HIY,"color_name":"金色" ]), ([ "name":"情","color":HIB,"color_name":"藍色" ]),
});

private void create(){ seteuid(getuid()); DAEMON_D->register_skill_daemon("au-chan sword"); setup(); }
int valid_enable(string usage){ return usage=="sword" || usage=="twohanded sword" || usage=="parry"; }

void jianling_combat_attack(object me, object opponent, object weapon)
{
    mapping action, stage;
    int i;

    message_vision(HIW "\n$N猛然施展傲劍訣中華麗的劍舞「" HIR "劍" HIY "領" HIG "風" HIC "騷" HIW "」！\n" NOR, me, opponent);
    for (i = 0; i < sizeof(jianling_forms); i++) {
        stage = jianling_forms[i];
        action = ([
          "name":"劍領風騷・"+stage["name"],
          // Historical Evidence 顯示每一段均以完整單行呈現：四色「劍領風騷」＋段名＋同色劍氣＋目標。
          "action":HIW "$N施展傲劍訣中的極招『" HIR "劍" HIY "領" HIG "風" HIC "騷" HIW "』『"+stage["color"]+stage["name"]+HIW+"』，一道"+stage["color"]+stage["color_name"]+HIW+"的劍氣射向$n！" NOR,
          "attack":0,"force":0,"defense":0,"damage_type":"刺傷"
        ]);
        COMBAT_D->fight(me, opponent, "sword", action, weapon);
    }
}

void attack_using(object me, object opponent, object weapon)
{
    mapping action; int index;
    if (!opponent) return;

    // 傲劍 Phase 2 持續攻擊池：七式一般招 + 劍領風騷。
    // 8 個等權入口，劍領風騷約 1/8 attack callback 觸發；不新增命中/傷害倍率。
    index=random(sizeof(aojian_actions) + 1);
    if (index == sizeof(aojian_actions)) {
        me->set_temp("aojian/last_form","劍領風騷");
        jianling_combat_attack(me, opponent, weapon);
        return;
    }

    action=aojian_actions[index];
    me->set_temp("aojian/last_form",action["name"]);
    COMBAT_D->fight(me,opponent,"sword",action,weapon);
}

int parry_using(object me, int ability, int strength, object from)
{
    mapping action; int index;
    // 同一套七式亦全部可於 Parry 時隨機觸發。
    index=random(sizeof(aojian_parries));
    action=aojian_parries[index];
    message_vision(action["action"]+"\n",me,from);
    return 0;
}

int perform_action(object me, string form, object target)
{
    object weapon;
    if(form!="jianling" && form!="jianlingfengsao" && form!="劍領風騷") return notify_fail("傲劍訣沒有這一式極招。\n");
    if(!objectp(target) || !living(target)) return notify_fail("劍領風騷需要一個仍可戰鬥的目標。\n");
    if(me->query_skill("au-chan sword",1)<=0) return notify_fail("你尚未學會傲劍訣。\n");
    if(me->skill_mapped("sword")!="au-chan sword" && me->skill_mapped("twohanded sword")!="au-chan sword") return notify_fail("你尚未啟用傲劍訣。\n");
    weapon=me->query_temp("weapon/sword");
    if(!objectp(weapon)) weapon=me->query_temp("weapon/twohanded sword");
    if(!objectp(weapon)) return notify_fail("你必須裝備劍類兵刃才能施展劍領風騷。\n");
    jianling_combat_attack(me, target, weapon);
    return 1;
}
