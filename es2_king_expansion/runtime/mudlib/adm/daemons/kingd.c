/*---
description: ES2-KING Owner／Creator 授權與創造服務
---*/

#pragma save_binary
inherit F_CLEAN_UP;

#define KING_OWNER_ID "king"

// Registry／登錄表：只容許建立 Expansion 明確列入的物件，避免任意路徑注入。
private mapping creation_registry = ([
    "creation_mark" : "/obj/king/creation_mark",
]);

private void create() { seteuid(getuid()); }

// Authorization／授權：正常登入、精確帳號 ID 與 Original admin 三項必須同時成立。
// Display Name／顯示名稱完全不參與判定，避免名稱偽裝取得 Owner 權限。
int authorized(object actor)
{
    return objectp(actor)
        && interactive(actor)
        && actor->query("id") == KING_OWNER_ID
        && wiz_level(actor) >= wiz_level("(admin)");
}

string query_owner_id() { return KING_OWNER_ID; }

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
    // 新物件先交給 Owner；無法放入物品欄時才放到所在房間。
    if (!created->move(actor) && environment(actor)) created->move(environment(actor));
    return created;
}
