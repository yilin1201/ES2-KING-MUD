#include <armor.h>
inherit F_CLOTH;
void create(){set_name("超級Ω神聖衣。披風光翼",({"omega wings","wings"}));set_weight(900);setup_cloth();if(!clonep()){set("unit","襲");set("value",0);set("long","十二重燦金光翼自背後舒展，每片神羽皆映照黃道十二宮與不屈星魂。\n");set("wear_as","cloth");set("apply_armor/cloth",(["armor":40]));set("es2_king/omega_cloth",1);}setup();}