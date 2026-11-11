#include <weapon.h>

inherit F_SWORD;

void create()
{
    set_name("飛雲", ({ "feiyun", "sword" }));
    set_weight(4000);
    // ES2-KING Expansion：數值尚無 Canon 定稿；暫借 Original ES2 短劍基準。
    setup_sword(1, 15, 40, 1);

    if (!clonep()) {
        set("wield_as", ({ "sword", "secondhand sword" }));
        set("unit", "把");
        set("value", 0);
        set("rigidity", 20);
        set("es2_king/owner_weapon", 1);
        set("es2_king/evidence", "ES2-KING Expansion / Project Canon");
        set("long", "KING 專屬子母神劍中的子劍「飛雲」，主神變、幻陣。\n");
    }
    setup();
}
