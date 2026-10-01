#include <ansi.h>
#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"

private string *omega_ids = ({
    "omega crown", "omega plate", "omega wings", "omega girth",
    "omega gloves", "omega leggings", "omega boots",
});

private void create(){ seteuid(getuid()); }

// 神戒封印／先使用 Original ES2 unequip() 正常解除 armor/apply，再將七件收回神之戒。
// 封印後玩家 Inventory 不保留神聖衣實體；下次 release omega 再由神戒重新顯化。
int main(object me, string arg)
{
    object ring, item;
    int i;

    if (arg != "omega")
        return notify_fail("封印指令：seal omega\n");
    if (!KING_D->authorized(me))
        return notify_fail("只有 KING 能將超級Ω神聖衣封回神之戒。\n");

    ring = present("god ring", me);
    if (!objectp(ring) || ring->query("es2_king/owner_relic") != 1)
        return notify_fail("神之戒不在你的物品欄中，無法封印超級Ω神聖衣。\n");

    for (i = 0; i < sizeof(omega_ids); i++) {
        item = present(omega_ids[i], me);
        if (!objectp(item))
            continue;
        if (item->query("es2_king/omega_cloth") != 1)
            return notify_fail("Ω神聖衣封印中止：發現同名但不屬於神聖衣的物件。\n");
        if (item->query("equipped") && !item->unequip())
            return notify_fail("Ω神聖衣封印失敗：" + item->name() + " 無法正常卸下。\n");
        destruct(item);
    }

    // 三個 Ω 狀態必須隨 Original unequip/apply 機制解除，否則不可宣告封印成功。
    if (me->query_temp("apply/omega_god_protection") > 0
    || me->query_temp("apply/omega_absolute_body") > 0
    || me->query_temp("apply/omega_lightspeed_realm") > 0)
        return notify_fail("Ω神聖衣封印失敗：仍有神聖狀態殘留。\n");

    ring->set("es2_king/omega_sealed", 1);
    write(HIW "\n超級Ω神聖衣化作七道星光，自你周身解除著裝，依序回歸神之戒。\n" NOR);
    write(HIY "【神戒封印】七件神聖衣已全部收回；再次輸入 release omega 即可重新解封。\n" NOR);
    return 1;
}

int help(object me)
{
    write("指令格式：seal omega\n\n卸下超級Ω神聖衣全套，解除其裝備狀態，並將七件重新封回神之戒。\n");
    return 1;
}
