// KING 神聖Ω七件固定順序：神盔、神甲、神翼、神鎖、拳套、腿甲、神靴。
// 僅重新排列展示用物件陣列，不改變實際背包、裝備欄或 Original ES2 玩家行為。
#include <command.h>
inherit F_DBASE;

private string *omega_ids = ({
    "omega crown", "omega plate", "omega wings", "omega girth",
    "omega gloves", "omega leggings", "omega boots",
});

object *ordered(object *items)
{
    object *result, *remaining;
    int i, j;
    object item;

    if (!pointerp(items)) return ({});
    result = ({});
    remaining = items + ({});
    for (i = 0; i < sizeof(omega_ids); i++) {
        for (j = 0; j < sizeof(remaining); j++) {
            item = remaining[j];
            if (objectp(item) && item->query("es2_king/omega_cloth") == 1
            && item->id(omega_ids[i])) {
                result += ({ item });
                remaining -= ({ item });
                break;
            }
        }
    }
    return result + remaining;
}
