#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
#define KING_MARTIAL_D "/adm/daemons/kingmartiald"

private void create() { seteuid(getuid()); }

int main(object me, string arg)
{
    SECURED_ADMIN_COMMAND;

    if (!KING_D->authorized(me))
        return notify_fail("只有 ES2-KING Owner 帳號可以進入此境。\n");

    // kinghome 只負責 KING 神域移動；8×99 與冷梅武學已在正式登入流程配置並保存。
    // 將能力配置與移動指令分離，避免「必須先輸入傳送指令才成為 KING」的錯誤生命週期。
    if (!me->move("/d/king/wuji_realm"))
        return notify_fail("無法進入天神殿・無極之境。\n");

    write("你跨越凡塵界限，進入天神殿・無極之境。\n");
        return 1;
}

int help(object me)
{
    write("指令格式：kinghome\n唯一 KING Owner 從正常遊戲位置直接前往天神殿・無極之境。\n");
    return 1;
}
