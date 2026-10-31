/*
 * ES2-KING K 管理團隊指令。
 * 保留必要的角色授權功能；不包含已移除的人物管理 V0 修改紀錄查詢。
 */
#include <command.h>

inherit F_CLEAN_UP;

#define K "/adm/daemons/kadmind"

private void create()
{
    seteuid(getuid());
}

int main(object me, string arg)
{
    string id, role_name;
    string *ids;
    mapping roles;
    object target;

    SECURED_ADMIN_COMMAND;

    if (!K->is_owner(me))
        return notify_fail("只有 KING Owner 可以管理 k* 權限。\n");

    if (!arg || arg == "list") {
        roles = K->query_roles(me);
        ids = sort_array(keys(roles), 1);
        write("K 管理團隊：\n");
        foreach (id in ids)
            write(sprintf("%-16s %s\n", id, roles[id]));
        if (!sizeof(ids))
            write("（目前沒有授權成員）\n");
        return 1;
    }

    if (sscanf(arg, "%s status", id) == 1) {
        target = find_player(id);
        roles = K->query_roles(me);
        write(id + "：" +
              (objectp(target) ? K->role(target) : (roles[id] || "player")) +
              "\n");
        return 1;
    }

    if (sscanf(arg, "%s %s", id, role_name) != 2)
        return notify_fail(
            "格式：kadmin list | kadmin <ID> wizard|arch|remove|status\n");

    if (!K->set_role(me, id, role_name))
        return notify_fail("權限變更失敗。\n");

    write("K 權限已更新：" + id + " -> " + role_name + "\n");
    return 1;
}

int help(object me)
{
    write("kadmin list\n"
          "kadmin <ID> wizard|arch|remove|status\n");
    return 1;
}
