// ES2-KING Project Canon：青邪杖法正式杖法 Combat daemon。
#include <ansi.h>
inherit SKILL;
private void create(){ seteuid(getuid()); DAEMON_D->register_skill_daemon("chin_staff"); setup(); }
int valid_enable(string usage){ return usage == "staff"; }
void attack_using(object me, object opponent, object weapon)
{
    mapping action;
    if (!opponent) return;
    action = ([ "name":"青邪杖法",
        "action":HIG "$N運起青邪杖法，手中$w盤旋一轉，杖影直取$n的$l！" NOR,
        "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]);
    COMBAT_D->fight(me, opponent, "staff", action, weapon);
}
