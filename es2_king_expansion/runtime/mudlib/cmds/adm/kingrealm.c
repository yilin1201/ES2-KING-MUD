#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
private void create() { seteuid(getuid()); }

int main(object me, string arg)
{
    SECURED_ADMIN_COMMAND;
    if (!KING_D->authorized(me))
        return notify_fail("只有 ES2-KING Owner 帳號可以進入此境。\n");
    if (!me->move("/d/king/wuji_realm"))
        return notify_fail("無法進入天神殿・無極之境。\n");
    write("你跨越凡塵界限，進入天神殿・無極之境。\n");
    return 1;
}
int help(object me)
{
    write("指令格式：kingrealm\n唯一 KING Owner 進入天神殿・無極之境。\n");
    return 1;
}
