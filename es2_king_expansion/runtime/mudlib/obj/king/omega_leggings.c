#include <armor.h>
#include <ansi.h>
inherit F_LEG_EQ;
void create(){set_name(HIW "神聖Ω腿甲" HIY "" NOR,({"omega leggings","leggings"}));set_weight(1500);setup_leg_eq();if(!clonep()){set("unit","副");set("value",0);set("long","流雲金紋重甲完美包覆雙膝與小腿，質地輕盈如羽卻堅若磐石，足以承受極速奔馳與萬鈞踢擊帶來的反震巨力。\n");set("wear_as","leg_eq");set("apply_armor/leg_eq",(["armor":35]));set("es2_king/omega_cloth",1);}setup();}
