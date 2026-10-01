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

// Owner Weapon Registry／KING 專屬武器配置。
// 登入只確保物品存在於 Inventory；絕不自動 wield，正式登入狀態維持空手。
private mapping owner_weapon_registry = ([
    "guxiao"        : "/obj/king/guxiao",
    "feiyun"        : "/obj/king/feiyun",
    "guxiao feiyun" : "/obj/king/guxiao_feiyun",
    "blood blade"   : "/obj/king/blood_blade",
    "god cane"      : "/obj/king/god_cane",
]);

private mapping owner_relic_registry = ([
    "god ring" : "/obj/king/god_ring",
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

int apply_creator_profile(object actor)
{
    string *attrs = ({ "str", "cor", "int", "spi", "cps", "dex", "con", "wis" });
    string attr;

    if (!authorized(actor)) return 0;

    // Project Canon：KING 八項基礎屬性固定 99。
    // 只使用正式 attribute API，不用 temp/apply 偽裝顯示值。
    foreach (attr in attrs)
        if (actor->set_attr(attr, 99) != 99)
            return 0;

    // Project Canon：KING 六項正式生存狀態固定 999。
    // Original ES2 F_STATISTIC 對應：精 gin、氣 kee、神 sen、形體 HP、飲水 water、食物 food。
    // Maximum／Effective／Current 三層同步，避免只改畫面或登入後立即被 Original regeneration 校正。
    foreach (string stat in ({ "gin", "kee", "sen", "HP", "water", "food" })) {
        if (actor->set_stat_maximum(stat, 999) != 999)
            return 0;
        if (actor->set_stat_effective(stat, 999) != 999)
            return 0;
        if (actor->set_stat_current(stat, 999) != 999)
            return 0;
    }

    actor->set("es2_king/creator_profile", 1);
    actor->set("es2_king/creator_attribute", 99);
    actor->set("es2_king/creator_statistic", 999);
    return 1;
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
    // 新物件先交給 Owner；無法放入物品欄時才放到所在房間。
    if (!created->move(actor) && environment(actor)) created->move(environment(actor));
    return created;
}


// provision_creator_relics()／KING 神物配置：只補缺失神之戒，不自動穿戴。
int provision_creator_relics(object actor)
{
    object item;
    string id, file;
    mapping found = ([]);

    if (!authorized(actor)) return 0;
    foreach (item in all_inventory(actor))
        foreach (id, file in owner_relic_registry)
            if (item->id(id)) found[id] = 1;

    foreach (id, file in owner_relic_registry) {
        if (found[id]) continue;
        if (file_size(file + ".c") < 0) return 0;
        item = new(file);
        if (!objectp(item) || !item->move(actor)) {
            if (objectp(item)) destruct(item);
            return 0;
        }
    }
    actor->set("es2_king/creator_relics", 1);
    return 1;
}

// provision_creator_weapons()／KING 登入武器配置。
// 只補齊缺少的武器，不重複 clone；不呼叫 wield()，確保 KING 登入保持空手。
int provision_creator_weapons(object actor)
{
    object item;
    string id, file;
    mapping found = ([]);

    if (!authorized(actor)) return 0;

    foreach (item in all_inventory(actor)) {
        foreach (id, file in owner_weapon_registry)
            if (item->id(id)) found[id] = 1;
    }

    foreach (id, file in owner_weapon_registry) {
        if (found[id]) continue;
        if (file_size(file + ".c") < 0) return 0;
        item = new(file);
        if (!objectp(item) || !item->move(actor)) {
            if (objectp(item)) destruct(item);
            return 0;
        }
    }

    actor->set("es2_king/creator_weapons", 1);
    return 1;
}
