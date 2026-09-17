#include <command.h>

inherit F_CLEAN_UP;

private void create()
{
    seteuid(getuid());
}

int main(object me, string arg)
{
    SECURED_ADMIN_COMMAND;

    if (!me->move("/d/king/wuji_realm"))
        return notify_fail("無法進入天神殿・無極之境。\n");

    write("你跨越凡塵界限，進入天神殿・無極之境。\n");
    return 1;
}

int help(object me)
{
    write("指令格式：kingrealm\n最高 admin 進入 ES2-KING 天神殿・無極之境。\n");
    return 1;
}
