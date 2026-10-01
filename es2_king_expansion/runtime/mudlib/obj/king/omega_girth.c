#include <armor.h>
inherit F_WAIST_EQ;
void create(){set_name("超級Ω神聖衣。腰帶",({"omega girth","girth"}));set_weight(700);setup_waist_eq();if(!clonep()){set("unit","條");set("value",0);set("long","繁複神聖星鎖環扣成金色束腰，中央Ω神徽鎖定星宿本源與氣海。\n");set("wear_as","waist_eq");set("apply_armor/waist_eq",(["armor":30]));set("es2_king/omega_cloth",1);}setup();}