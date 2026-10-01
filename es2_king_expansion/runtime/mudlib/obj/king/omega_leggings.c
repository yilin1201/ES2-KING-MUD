#include <armor.h>
inherit F_LEG_EQ;
void create(){set_name("超級Ω神聖衣。腳套",({"omega leggings","leggings"}));set_weight(1500);setup_leg_eq();if(!clonep()){set("unit","副");set("value",0);set("long","流雲金紋重甲包覆雙膝與小腿，輕盈如羽而堅若磐石。\n");set("wear_as","leg_eq");set("apply_armor/leg_eq",(["armor":35]));set("es2_king/omega_cloth",1);}setup();}