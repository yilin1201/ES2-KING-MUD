// ES2-KING Project Canon：傲梅暗劍訣正式左手劍術 Combat daemon。
#include <ansi.h>
inherit SKILL;
private void create(){ seteuid(getuid()); DAEMON_D->register_skill_daemon("advance_lunmay"); setup(); }
int valid_enable(string usage){ return usage == "secondhand sword"; }
void attack_using(object me, object opponent, object weapon)
{
    mapping action;
    if (!opponent) return;
    // KING 防禦開場由實際攻擊入口觸發，避免依賴 parry daemon 是否收到 attack hook。
    if (me->skill_mapped("parry") == "batian lianti jue")
        call_other("/d/arena/skill/batian_lianti_jue", "show_immortal_intro", me);
    action = ([ "name":"傲梅暗劍訣",
        "action":HIW "$N左手暗劍藏於明劍之後，傲梅暗劍訣驟然折出，無聲刺向$n的$l！" NOR,
        "attack":15, "force":15, "defense":10, "damage_type":"刺傷" ]);
    COMBAT_D->fight(me, opponent, "secondhand sword", action, weapon);
}
