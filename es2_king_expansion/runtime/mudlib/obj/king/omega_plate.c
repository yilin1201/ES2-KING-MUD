#include <armor.h>
inherit F_ARMOR;
void create(){set_name("超級Ω神聖衣。盔甲",({"omega plate","plate"}));set_weight(4500);setup_armor();if(!clonep()){set("unit","件");set("value",0);set("long","融合十二黃金星座星鋼與神之血淬煉的主神甲，金銀神紋覆蓋胸腹與脊骨。\n");set("wear_as","armor");set("apply_armor/armor",(["armor":100]));set("es2_king/omega_cloth",1);}setup();}