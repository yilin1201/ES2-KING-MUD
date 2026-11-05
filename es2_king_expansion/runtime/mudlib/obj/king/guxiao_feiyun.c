#include <weapon.h>

inherit F_SWORD;

void create()
{
    set_name("古霄・飛雲", ({ "guxiao feiyun", "merged sword", "sword" }));
    set_weight(8000);
    // ES2-KING Expansion：合刃數值尚無 Canon 定稿；暫借 Original ES2 短劍基準。
    // wield_as 才是本階段正式設定：可單手 sword 或雙手 twohanded sword。
    setup_sword(1, 15, 40, 1);

    if (!clonep()) {
        set("wield_as", ({ "sword", "twohanded sword" }));
        set("unit", "把");
        set("value", 0);
        set("rigidity", 20);
        set("es2_king/owner_weapon", 1);
        set("es2_king/evidence", "ES2-KING Expansion / Project Canon");
        set("long", "古霄與飛雲的合刃形態，可依 Original ES2 架構單手或雙手使用。\n");
    }
    setup();
}
