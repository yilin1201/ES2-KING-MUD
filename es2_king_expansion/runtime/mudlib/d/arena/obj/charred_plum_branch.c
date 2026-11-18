// 焦黑枯梅枝：梅寒霜演武界測試兵器。數值沿用 Original ES2 木劍模板，不新增特殊倍率。
#include <weapon.h>
inherit F_SWORD;

void create()
{
    set_name("焦黑枯梅枝", ({ "charred plum branch", "plum branch", "branch" }));
    set_weight(2000);
    setup_sword(1, 14, 40, 0);

    if (clonep()) set_default_object(__FILE__);
    else {
        set("wield_as", "sword");
        set("unit", "截");
        set("value", 0);
        set("rigidity", 10);
        set("long", "一截未開刃的焦黑枯梅枝，枝身乾裂，握在手中卻隱隱透著寒意。\n");
        set("es2_king_expansion", 1);
    }
    setup();
}
