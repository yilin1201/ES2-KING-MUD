/*
 * ES2-KING：KING 專屬 K 管理團隊授權。
 * 與 Original ES2 wiz_status 分離，不改寫 Original promote/security。
 * 人物管理 V0 的修改紀錄功能已移除；此 daemon 僅負責 K-team 角色授權。
 */
#pragma save_binary

inherit F_DBASE;

#define SAVE_FILE "/data/daemon/es2_king_kadmin"

private mapping roles = ([]);

private void create()
{
    seteuid(getuid());
    if (file_size(SAVE_FILE + ".o") >= 0)
        restore_object(SAVE_FILE);
    if (!mapp(roles))
        roles = ([]);
}

private int owner(object ob)
{
    return objectp(ob) && interactive(ob) &&
           ob->query("id") == "king" &&
           wiz_level(ob) >= wiz_level("(admin)");
}

int is_owner(object ob)
{
    return owner(ob);
}

string role(object ob)
{
    string id;

    if (owner(ob))
        return "king";
    if (!objectp(ob))
        return "player";

    id = ob->query("id");
    return stringp(roles[id]) ? roles[id] : "player";
}

int level(object ob)
{
    string role_name;

    role_name = role(ob);
    if (role_name == "king")
        return 99;
    if (role_name == "arch")
        return 2;
    if (role_name == "wizard")
        return 1;
    return 0;
}

int can_view(object ob)
{
    return level(ob) >= 1;
}

int can_arch(object ob)
{
    return level(ob) >= 2 || owner(ob);
}

mapping query_roles(object actor)
{
    if (!owner(actor))
        return ([]);
    return copy(roles);
}

int set_role(object actor, string id, string role_name)
{
    if (!owner(actor) || !stringp(id) || id == "" || id == "king")
        return 0;

    if (role_name == "remove" || role_name == "player")
        map_delete(roles, id);
    else if (role_name == "wizard" || role_name == "arch")
        roles[id] = role_name;
    else
        return 0;

    save_object(SAVE_FILE);
    return 1;
}
