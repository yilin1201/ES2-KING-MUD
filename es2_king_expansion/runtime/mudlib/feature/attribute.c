/*
 * ES2-KING Expansion overlay for Original ES2 attribute handling.
 * 一般角色維持 Original／ES2M 的 1..50；授權 KING 管理服務可設定 1..99。
 */
#include <dbase.h>
#include <attribute.h>

mapping attribute = ([]);

mapping query_attribute() { return attribute; }

varargs int query_attr(string what, int raw)
{
    int a;
    if (!mapp(attribute) || undefinedp(a = attribute[what]))
        return 0;
    if (raw)
        return a;
    return a + (int)query_temp("apply/" + what);
}

int set_attr(string what, int value)
{
    object caller;
    string caller_name;
    int king_admin;

    if (!mapp(attribute))
        attribute = ([]);

    // Original 初始化規則保留；只允許兩個受權限保護的 KING 管理 daemon 突破一般上限。
    caller = previous_object();
    caller_name = objectp(caller) ? file_name(caller) : "";
    king_admin = caller_name == "/adm/daemons/kingd";

    // 八大屬性：一般角色上限 ATTRVAL_MAX；KING 管理 API 上限 99；所有角色均不得低於 ATTRVAL_MIN。
    if (userp(this_object())
    && (undefinedp(attribute[what])
        || value < ATTRVAL_MIN
        || (value > ATTRVAL_MAX && (!king_admin || value > 99))))
        return 0;

    return (attribute[what] = value);
}

varargs void init_attribute(mapping base)
{
    mapping attr;
    string name;
    int value;

    if (mapp(attr = query("attribute"))) {
        attribute = attr;
        delete("attribute");
    }

    if (!mapp(attribute))
        attribute = allocate_mapping(NUM_ATTRIBUTES);

    if (!mapp(base) || !sizeof(base))
        return;

    foreach (name, value in base)
        if (undefinedp(attribute[name]))
            attribute[name] = value;
}
