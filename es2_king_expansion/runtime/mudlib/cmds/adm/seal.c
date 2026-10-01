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

    // 先驗證全部物件，再卸裝回收，避免同名偽物件造成部分封印。
    for (i = 0; i < sizeof(omega_ids); i++) {
        item = present(omega_ids[i], me);
        if (objectp(item) && item->query("es2_king/omega_cloth") != 1)
            return notify_fail("Ω神聖衣封印中止：發現同名但不屬於神聖衣的物件。\n");
    }

    write(HIW "\n你深吸一口氣，翻湧沸騰的小宇宙如潮水般緩緩平息，氣沉丹田。\n" NOR);
    write(HIW "指間的「神之戒」泛起溫潤柔和的星芒，發出清越的空靈錚鳴。\n" NOR);
    write("周身金色甲胄劇烈震顫，各處金屬扣鎖應聲解開——\n\n");
    write(HIY ">>> 聖衣解鎖！歸還神戒（Unequip Omega Cloth）<<<\n\n" NOR);

    // 先正常 unequip，再由神戒回收實體；特效是敘事，不代表額外戰鬥倍率。
    for (i = 0; i < sizeof(omega_ids); i++) {
        item = present(omega_ids[i], me);
        if (!objectp(item)) continue;
        if (item->query("equipped") && !item->unequip())
            return notify_fail("Ω神聖衣封印失敗：" + item->name() + " 無法正常卸下。\n");
        destruct(item);
    }

    // Original apply 必須隨裝備解除。
    if (me->query_temp("apply/omega_god_protection") > 0
    || me->query_temp("apply/omega_absolute_body") > 0
    || me->query_temp("apply/omega_lightspeed_realm") > 0)
        return notify_fail("Ω神聖衣封印失敗：仍有神聖狀態殘留。\n");

    write("【背部】：十二道燦金神翼微振合攏，漫天羽光自背脊收斂。\n");
    write("【頭部】：天馬戰盔自兩鬢彈開，額前星芒漸歸沉寂。\n");
    write("【雙手】：神拳套寸寸鬆脫，指節星痕悄然隱去。\n");
    write("【身體】：主神甲解開神鎖，青銅與黃金神紋化光褪去。\n");
    write("【腰部】：Ω神徽化為一縷璀璨金絲。\n");
    write("【腿部】：雲紋甲片自雙膝與脛骨脫離，逆流而上。\n");
    write("【雙腳】：踏星戰靴金炎熄滅，足底重歸凡塵。\n\n");
    write(HIW "七件神甲於半空重組為黃道戰神法相，向你微微頷首，隨即化為星塵漩渦，盡數斂入神之戒。\n" NOR);
    write("四周罡風止歇，天地復歸寂靜，你斂去神威，重現宗師從容本色。\n\n");
    ring->set("es2_king/omega_sealed", 1);
    write(HIY "【神戒封印】七件神聖衣已全部收回；再次輸入 release omega 即可重新解封。\n" NOR);
    write(HIW "（系統提示：你卸下了「超級Ω神聖衣」全套防具，聖衣已完整收納回「神之戒」中，狀態「神之庇護」、「絕對霸體」、「光速境界」解除。）\n" NOR);
    return 1;
}

int help(object me)
{
    write("指令格式：seal omega\n\n卸下超級Ω神聖衣全套，解除其裝備狀態，並將七件重新封回神之戒。\n");
    return 1;
}
