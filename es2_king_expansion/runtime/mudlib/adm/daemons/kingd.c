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

    // ES2M Race/Class：人類族 avatar、武者 fighter；僅更動唯一已授權 KING。
    // set_race/set_class 走角色正式 API，避免僅改顯示名稱而保留盜賊升級邏輯。
    if (actor->query_race() != "avatar") actor->set_race("avatar");
    if (actor->query_race() != "avatar") return 0;
    if (actor->query_class() != "fighter") actor->set_class("fighter");
    if (actor->query_class() != "fighter") return 0;

    // KING 八項基礎屬性採 ES2M 正式 1..50 上限。
    // 只使用正式 attribute API，不用 temp/apply 偽裝顯示值。
    foreach (attr in attrs)
        if (actor->set_attr(attr, 50) != 50)
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
    actor->set("es2_king/creator_attribute", 50);
    actor->set("es2_king/creator_statistic", 999);
    return 1;
}


/* V0 人物管理核心：所有修改均由此服務集中驗證，避免指令直接建立平行人物資料。 */
int set_managed_attr(object actor, object target, string attr, int value)
{
    if(!authorized(actor)||!objectp(target)||!userp(target)||member_array(attr,({"str","cor","int","spi","cps","dex","con","wis"}))<0) return 0;
    if(value<1||value>99) return 0;
    return target->set_attr(attr,value)==value;
}
int set_managed_stat(object actor, object target, string stat, int value)
{
    if(!authorized(actor)||!objectp(target)||!userp(target)||member_array(stat,({"gin","kee","sen"}))<0) return 0;
    if(value<1||value>999) return 0;
    if(target->set_stat_maximum(stat,value)!=value) return 0;
    if(target->set_stat_effective(stat,value)!=value) return 0;
    if(target->set_stat_current(stat,value)!=value) return 0;
    return 1;
}
int set_managed_skill(object actor, object target, string skill, int value)
{
    object daemon;
    if(!authorized(actor)||!objectp(target)||!userp(target)||!stringp(skill)||skill==""||value<0||value>300) return 0;
    daemon=SKILL_D(skill);
    if(!objectp(daemon)) return 0;
    target->set_skill(skill,value);
    return target->query_skill(skill,1)==value;
}
int set_managed_class(object actor, object target, string class_id)
{
    object daemon;
    if(!authorized(actor)||!objectp(target)||!userp(target)||!stringp(class_id)||class_id=="") return 0;
    daemon=CLASS_D(class_id);
    if(!objectp(daemon)) return 0;
    return target->set_class(class_id);
}
int add_managed_money(object actor, object target, int amount)
{
    object ob; int total,gold,silver,coin;
    if(!authorized(actor)||!objectp(target)||!userp(target)||amount==0) return 0;
    ob=present("gold_money",target); if(ob) total+=(int)ob->value();
    ob=present("silver_money",target); if(ob) total+=(int)ob->value();
    ob=present("coin_money",target); if(ob) total+=(int)ob->value();
    total+=amount; if(total<0) return 0;
    gold=total/10000; total%=10000; silver=total/100; coin=total%100;
    ob=present("gold_money",target); if(gold){if(!ob){ob=new("/obj/money/gold");if(!ob||!ob->move(target)){if(ob)destruct(ob);return 0;}}ob->set_amount(gold);}else if(ob)ob->set_amount(0);
    ob=present("silver_money",target); if(silver){if(!ob){ob=new("/obj/money/silver");if(!ob||!ob->move(target)){if(ob)destruct(ob);return 0;}}ob->set_amount(silver);}else if(ob)ob->set_amount(0);
    ob=present("coin_money",target); if(coin){if(!ob){ob=new("/obj/money/coin");if(!ob||!ob->move(target)){if(ob)destruct(ob);return 0;}}ob->set_amount(coin);}else if(ob)ob->set_amount(0);
    return 1;
}

mapping query_creation_registry(object actor)
{
    mapping result;
    if (!authorized(actor)) return ([]);
    // V0 Item Registry／人物管理道具登錄：只回傳已存在且可驗證的 KING 物件。
    // 不接受使用者輸入任意 LPC 路徑，避免任意物件注入。
    result = copy(creation_registry);
    foreach (string id, string file in owner_weapon_registry)
        result[id] = file;
    foreach (string id, string file in owner_relic_registry)
        result[id] = file;
    return result;
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
