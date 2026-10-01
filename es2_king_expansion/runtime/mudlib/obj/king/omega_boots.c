#include <armor.h>
inherit F_FEET_EQ;
void create(){set_name("超級Ω神聖衣。鞋子",({"omega boots","boots"}));set_weight(1200);setup_feet_eq();if(!clonep()){set("unit","雙");set("value",0);set("long","銘刻天馬踏雲紋的金色戰靴，足下彷彿踏過無盡星河。\n");set("wear_as","feet_eq");set("apply_armor/feet_eq",(["armor":30]));set("es2_king/omega_cloth",1);}setup();}