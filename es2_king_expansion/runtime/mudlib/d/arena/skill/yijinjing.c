// ES2-KING Project Canon：易筋經正式 force Skill Daemon。
// M28 只證實武學定位與境界；未知傷害、回復、消耗與倍率不在此補造。
#include <ansi.h>
inherit SKILL;

private void create()
{
    seteuid(getuid());
    DAEMON_D->register_skill_daemon("yijinjing");
    setup();
}

int valid_enable(string usage) { return usage == "force"; }
