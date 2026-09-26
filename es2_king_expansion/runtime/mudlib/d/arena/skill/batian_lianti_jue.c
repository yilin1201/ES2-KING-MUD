// ES2-KING Project Canon：霸天煉體訣正式 parry Skill Daemon。
// M28 的兆／極、不滅金身與 150% Canon 不轉換成未經證實的 Combat 倍率。
#include <ansi.h>
inherit SKILL;

private void create()
{
    seteuid(getuid());
    DAEMON_D->register_skill_daemon("batian lianti jue");
    setup();
}

int valid_enable(string usage) { return usage == "parry"; }

// Original Combat 的 parry_using 正式入口；現階段不虛構額外拆招卸力數值。
int parry_using(object me, int ability, int strength, object from)
{
    return 0;
}
