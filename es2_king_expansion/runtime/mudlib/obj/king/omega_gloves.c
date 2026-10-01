#include <armor.h>
#include <ansi.h>
inherit F_HAND_EQ;
void create(){set_name(HIY "神聖Ω拳套" NOR,({"omega gloves","gloves"}));set_weight(500);setup_hand_eq();if(!clonep()){set("unit","副");set("value",0);set("long","金銀交織的流線型神拳套，指節刻滿弒神星痕；出拳之際引動宇宙萬千星辰共鳴，將意志凝聚為粉碎次元的毀滅拳壓。\n");set("wear_as","hand_eq");set("apply_armor/hand_eq",(["armor":30]));set("es2_king/omega_cloth",1);}setup();}
