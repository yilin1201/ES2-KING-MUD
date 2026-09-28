// ES2-KING Project Canon：青邪杖法正式杖法 Combat daemon。
#include <ansi.h>
inherit SKILL;
private void create(){ seteuid(getuid()); DAEMON_D->register_skill_daemon("chin_staff"); setup(); }
int valid_enable(string usage){ return usage == "staff"; }
void attack_using(object me, object opponent, object weapon)
{
    mapping action;
    if (!opponent) return;
    // 青邪宮哭笑九曲杖法七式：戰鬥時依序輪轉，確保已裝備杖法會實際出招。
    string *forms = ({ "哭天搶地", "笑裡藏刀", "九曲回腸", "邪影纏身", "杖鎮八方", "哭笑無常", "九曲歸邪" });
    int index = me->query_temp("es2_king/chin_staff/index");
    if (index < 0 || index >= sizeof(forms)) index = 0;
    action = ([ "name":forms[index],
        "action":HIG "$N運起青邪杖法，手中$w九曲翻轉，使出「" + forms[index] + "」，杖影直取$n的$l！" NOR,
        "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]);
    me->set_temp("es2_king/chin_staff/index", (index + 1) % sizeof(forms));
    COMBAT_D->fight(me, opponent, "staff", action, weapon);
}
