#include <armor.h>
inherit F_FINGER_EQ;
void create(){set_name("神之戒",({"god ring","ring"}));set_weight(100);setup_finger_eq();if(!clonep()){set("unit","枚");set("value",0);set("long","一枚封存神界時空矩陣的金色神戒，戒面深處沉睡著Ω神徽。KING 可輸入 release omega，或以快捷指令 kring，解封超級Ω神聖衣。\n");set("wear_as","finger_eq");set("apply_armor/finger_eq",(["armor":5]));set("es2_king/owner_relic",1);set("es2_king/evidence","ES2-KING Expansion / Project Canon");}setup();}
