#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"

private void create()
{
    seteuid(getuid());
}

int main(object me, string arg)
{
    object home;

    SECURED_ADMIN_COMMAND;

    if (!KING_D->authorized(me))
        return notify_fail("只有 ES2-KING Owner 可以使用 khome。\n");

    // Khome／自宅入口：與 kinghome 神域傳送分開，避免兩個指令落到同一房間。
    // 每次建立 Owner 專屬大廳，先綁定玩家，再移動玩家，確保管家／儲物箱／告示板取得正確主人。
    home = new("/custom/home/room/home_hall");
    if (!objectp(home))
        return notify_fail("私人家園大廳目前無法載入。\n");

    home->set_home_owner(me);
    if (!me->move(home)) {
        destruct(home);
        return notify_fail("無法進入你的私人家園。\n");
    }

    write("你回到了自己的私人家園。\n");
    return 1;
}

int help(object me)
{
    if (!KING_D->authorized(me))
        return notify_fail("沒有針對這項主題的說明文件。\n");

    write("指令格式：khome\n\n");
    write("將 KING Owner 送入專屬私人家園大廳；kinghome 則保留作為天神殿・無極之境入口。\n");
    return 1;
}
