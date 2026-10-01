#include <armor.h>
inherit F_HAND_EQ;
void create(){set_name("超級Ω神聖衣。手套",({"omega gloves","gloves"}));set_weight(500);setup_hand_eq();if(!clonep()){set("unit","副");set("value",0);set("long","金銀交織的流線型神拳套，指節刻滿與群星共鳴的弒神星痕。\n");set("wear_as","hand_eq");set("apply_armor/hand_eq",(["armor":30]));set("es2_king/omega_cloth",1);}setup();}