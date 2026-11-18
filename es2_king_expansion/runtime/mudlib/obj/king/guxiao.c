#include <weapon.h>

inherit F_SWORD;

void create()
{
    set_name("古霄", ({ "guxiao", "sword" }));
    set_weight(4000);
    // ES2-KING Expansion：數值尚無 Canon 定稿；暫借 Original ES2 短劍基準，
    // 只為保留 Original 武器傷害資料結構，後續平衡定稿時再獨立調整。
    setup_sword(1, 15, 40, 1);

    if (!clonep()) {
        set("wield_as", ({ "sword", "secondhand sword" }));
        set("unit", "把");
        set("value", 0);
        set("rigidity", 20);
        set("es2_king/owner_weapon", 1);
        set("es2_king/evidence", "ES2-KING Expansion / Project Canon");
        set("long", "KING 專屬子母神劍中的母劍「古霄」，主攻伐、破法。\n");
    }
    setup();
}
