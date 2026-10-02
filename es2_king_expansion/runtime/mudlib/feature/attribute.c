/*
 * ES2-KING Expansion overlay for Original ES2 attribute handling.
 * 所有角色（包括 KING）均維持 Original／ES2M 的 1..50 正式屬性範圍。
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
    int maximum;

    if (!mapp(attribute))
        attribute = ([]);

    maximum = (query("id") == "king") ? 99 : ATTRVAL_MAX;

    // Original 規則保留：玩家屬性必須先由 init_attribute() 初始化。
    // Expansion 唯一例外只有精確 ID=king 的上限 99；其他玩家仍是 Original ATTRVAL_MAX=50。
    if (userp(this_object())
    && (undefinedp(attribute[what]) || value < ATTRVAL_MIN || value > ATTRVAL_MAX))
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
