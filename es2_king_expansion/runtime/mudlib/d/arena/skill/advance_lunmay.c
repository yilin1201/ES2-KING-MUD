// ES2-KING Project Canon：傲梅暗劍訣正式左手劍術 Combat daemon。
#include <ansi.h>
inherit SKILL;
private void create(){ seteuid(getuid()); DAEMON_D->register_skill_daemon("advance_lunmay"); setup(); }
int valid_enable(string usage){ return usage == "secondhand sword"; }
void attack_using(object me, object opponent, object weapon)
{
    mapping action;
    if (!opponent) return;
    action = ([ "name":"傲梅暗劍訣",
        "action":HIW "$N左手暗劍藏於明劍之後，傲梅暗劍訣驟然折出，無聲刺向$n的$l！" NOR,
        "attack":0, "force":0, "defense":0, "damage_type":"刺傷" ]);
    COMBAT_D->fight(me, opponent, "secondhand sword", action, weapon);
}
