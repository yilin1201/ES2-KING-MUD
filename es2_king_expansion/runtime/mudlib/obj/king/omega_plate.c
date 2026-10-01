#include <armor.h>
#include <ansi.h>
inherit F_ARMOR;
void create(){set_name(HIW "超級Ω神聖衣。" HIY "盔甲" NOR,({"omega plate","plate"}));set_weight(4500);setup_armor();if(!clonep()){set("unit","件");set("value",0);set("long","覆蓋胸腹與脊骨的厚重主神甲，融合十二黃金星座至純星鋼與神之血淬煉而成。甲面流轉青銅銀光與不滅金紋，具備絕對護體之威能。\n");set("wear_as","armor");set("apply_armor/armor",(["armor":100,"omega_god_protection":1]));set("es2_king/omega_cloth",1);}setup();}
