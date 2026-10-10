/*
 * ES2-KING Expansion overlay for Original ES2 attribute handling.
 * 八大屬性：一般角色沿用 Original／ES2M 的 ATTRVAL_MAX；授權 KING 管理服務可設定 1..99。
 * 僅修改 Expansion overlay，不修改 Original ES2 原始碼。
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

    // 保留 Original 初始化要求；只有指定的 KING 管理 daemon 可突破一般屬性上限。
    caller = previous_object();
    caller_name = objectp(caller) ? file_name(caller) : "";
    king_admin = caller_name == "/adm/daemons/kcharadmind"
              || caller_name == "/adm/daemons/kingd";

    // 八大屬性管理設定上限為 99；一般角色仍受 ATTRVAL_MAX 原始上限限制。
    if (userp(this_object())
    && (undefinedp(attribute[what])
        || value < ATTRVAL_MIN
        || value > (king_admin ? 99 : ATTRVAL_MAX)))
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
