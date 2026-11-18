#pragma save_binary

#include <ansi.h>

inherit SKILL;

void create()
{
    seteuid(getuid());
    DAEMON_D->register_skill_daemon("kuxiao force");
    setup();
}

// 哭笑門心法是青邪宮／哭笑門的內功基礎；只映射既有 force 類型，
// 不建立另一套內功或改寫 Original ES2 的技能上限與傷害公式。
int valid_enable(string usage)
{
    return usage == "force";
}

