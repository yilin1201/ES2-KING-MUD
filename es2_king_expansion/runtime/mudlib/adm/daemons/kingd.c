/*---
description: ES2-KING 管理員創造服務
---*/

#pragma save_binary

inherit F_CLEAN_UP;

// Registry／登錄表：只容許建立 Expansion 明確列入的物件，避免任意路徑注入。
private mapping creation_registry = ([
    "creation_mark" : "/obj/king/creation_mark",
]);

private void create()
{
    seteuid(getuid());
}

// Authorization／授權：KING 操作沿用 Original 已有最高 admin 權限，不另造旁路。
int authorized(object actor)
{
    return objectp(actor)
        && interactive(actor)
        && wiz_level(actor) >= wiz_level("(admin)");
}

mapping query_creation_registry(object actor)
{
    if (!authorized(actor)) return ([]);
    return copy(creation_registry);
}

object create_registered(object actor, string id)
{
    object created;
    string file;

    if (!authorized(actor)) return 0;
    file = creation_registry[id];
    if (!stringp(file) || file_size(file + ".c") < 0) return 0;

    created = new(file);
    if (!objectp(created)) return 0;

    // 新物件先交給管理員；無法放入物品欄時才放到所在房間。
    if (!created->move(actor) && environment(actor))
        created->move(environment(actor));
    return created;
}
