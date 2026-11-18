#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
private void create() { seteuid(getuid()); }

int main(object me, string arg)
{
    object created;
    mapping registry;
    SECURED_ADMIN_COMMAND;
    if (!KING_D->authorized(me))
        return notify_fail("只有 ES2-KING Owner 帳號可以使用此指令。\n");
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
    write("指令格式：kingcreate list | kingcreate <已登錄項目>\n僅供唯一 KING Owner 使用。\n");
    return 1;
}
