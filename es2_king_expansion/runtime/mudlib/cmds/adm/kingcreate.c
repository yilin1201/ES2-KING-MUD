#include <command.h>

inherit F_CLEAN_UP;

#define KING_D "/adm/daemons/kingd"

private void create()
{
    // Effective UID／有效權限身分：沿用 Original 管理指令的安全初始化方式。
    seteuid(getuid());
}

int main(object me, string arg)
{
    object created;
    mapping registry;

    // Secure Admin Command／安全管理指令：拒絕一般玩家、間接呼叫與偽造操作。
    SECURED_ADMIN_COMMAND;

    if (!arg || arg == "list") {
        registry = KING_D->query_creation_registry(me);
        write("KING 可建立項目：" + implode(sort_array(keys(registry), 1), "、") + "\n");
        return 1;
    }

    created = KING_D->create_registered(me, arg);
    if (!objectp(created))
        return notify_fail("建立失敗：未登錄項目或權限不足。\n");

    write("KING 建立完成：" + created->name() + "（" + arg + "）\n");
    return 1;
}

int help(object me)
{
    write(@HELP
指令格式：kingcreate list
          kingcreate <已登錄項目>

列出或建立 ES2-KING Expansion 已登錄的安全物件。此指令只供最高 admin 使用。
HELP
    );
    return 1;
}
