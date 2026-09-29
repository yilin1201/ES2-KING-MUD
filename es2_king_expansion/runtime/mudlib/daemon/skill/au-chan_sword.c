// ES2-KING：傲劍訣 Combat daemon。
// Original ES2 公開 Evidence 確認 skill id「au-chan sword」；招式與配色依使用者實機截圖重建。
// 未知 Original 命中、傷害倍率、無視防禦公式、消耗與 cooldown 不補造。
#include <ansi.h>
inherit SKILL;

mapping *aojian_actions = ({
([ "name":"千嬌百媚柔似水", "action":HIG "$N劍光一閃，一招「" HIM "千嬌百媚柔似水" HIG "」，挑起$w，輕靈曼妙的刺向$n的$l……" NOR, "attack":0,"force":0,"defense":0,"damage_type":"刺傷" ]),
([ "name":"佳人在殘醉臥君", "action":HIG "$N虛轉反側，一招「" HIR "佳人在殘醉臥君" HIG "」，手中$w上刺，隨後迴鋒下引攻$n的$l……" NOR, "attack":0,"force":0,"defense":0,"damage_type":"刺傷" ]),
([ "name":"了絕紅塵遁山林", "action":HIG "$N獰笑一聲，一招「" HIC "了絕紅塵遁山林" HIG "」使將開來，手中$w真氣貫注，劍芒四射，一道長虹貫過$n的$l……" NOR, "attack":0,"force":0,"defense":0,"damage_type":"刺傷" ]),
([ "name":"清風送爽墨雲飛", "action":HIG "$N一招「" HIB "清風送爽墨雲飛" HIG "」，手中$w劍氣大盛，$w挾著勁風迎面攻$n的$l……" NOR, "attack":0,"force":0,"defense":0,"damage_type":"割傷" ]),
});

mapping *aojian_parries = ({
([ "name":"渺盡人世絕惡意", "action":HIG "$N手中$w劍芒大盛，一招「" HIG "渺盡人世絕惡意" HIG "」將$n的攻勢完全封住。" NOR ]),
([ "name":"天始一乾景初開", "action":HIG "$N將手中$w一展，一式「" HIY "天始一乾景初開" HIG "」將$n的攻勢化開。" NOR ]),
([ "name":"不識江山多嬌媚", "action":HIG "$N身體有如陀螺急轉，一招「" HIM "不識江山多嬌媚" HIG "」將$n的所有攻勢帶開。" NOR ]),
});

mapping *jianling_forms = ({
([ "name":"忠","color":HIG,"color_name":"綠色" ]), ([ "name":"武","color":HIR,"color_name":"紅色" ]),
([ "name":"義","color":HIM,"color_name":"紫色" ]), ([ "name":"德","color":HIC,"color_name":"青色" ]),
([ "name":"狂","color":HIY,"color_name":"金色" ]), ([ "name":"情","color":HIB,"color_name":"藍色" ]),
});

private void create(){ seteuid(getuid()); DAEMON_D->register_skill_daemon("au-chan sword"); setup(); }
int valid_enable(string usage){ return usage=="sword" || usage=="twohanded sword" || usage=="parry"; }

void attack_using(object me, object opponent, object weapon)
{
    mapping action; int index;
    if (!opponent) return;
    index=me->query_temp("aojian/form_index");
    if(index<0 || index>=sizeof(aojian_actions)) index=0;
    action=aojian_actions[index];
    me->set_temp("aojian/form_index",(index+1)%sizeof(aojian_actions));
    me->set_temp("aojian/last_form",action["name"]);
    COMBAT_D->fight(me,opponent,"sword",action,weapon);
}

int parry_using(object me, int ability, int strength, object from)
{
    mapping action; int index;
    index=me->query_temp("aojian/parry_index");
    if(index<0 || index>=sizeof(aojian_parries)) index=0;
    action=aojian_parries[index];
    me->set_temp("aojian/parry_index",(index+1)%sizeof(aojian_parries));
    message_vision(action["action"]+"\n",me,from);
    return 0;
}

int perform_action(object me, string form, object target)
{
    object weapon; mapping action,stage; int i;
    if(form!="jianling" && form!="jianlingfengsao" && form!="劍領風騷") return notify_fail("傲劍訣沒有這一式極招。\n");
    if(!objectp(target) || !living(target)) return notify_fail("劍領風騷需要一個仍可戰鬥的目標。\n");
    if(me->query_skill("au-chan sword",1)<=0) return notify_fail("你尚未學會傲劍訣。\n");
    if(me->skill_mapped("sword")!="au-chan sword" && me->skill_mapped("twohanded sword")!="au-chan sword") return notify_fail("你尚未啟用傲劍訣。\n");
    weapon=me->query_temp("weapon/sword");
    if(!objectp(weapon)) weapon=me->query_temp("weapon/twohanded sword");
    if(!objectp(weapon)) return notify_fail("你必須裝備劍類兵刃才能施展劍領風騷。\n");
    message_vision(HIG "\n$N猛然施展傲劍訣中華麗的劍舞「" HIR "劍領風騷" HIG "」！\n" NOR,me,target);
    for(i=0;i<sizeof(jianling_forms);i++){
        stage=jianling_forms[i];
        action=([ "name":"劍領風騷・"+stage["name"],
          "action":HIG "$N施展傲劍訣中的極招「" HIR "劍領風騷" HIG "」『"+stage["color"]+stage["name"]+HIG+"』，一道"+stage["color"]+stage["color_name"]+HIG+"的劍氣射向$n！" NOR,
          "attack":0,"force":0,"defense":0,"damage_type":"刺傷" ]);
        COMBAT_D->fight(me,target,"sword",action,weapon);
    }
    return 1;
}
