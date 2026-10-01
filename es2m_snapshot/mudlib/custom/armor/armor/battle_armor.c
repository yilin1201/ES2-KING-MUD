/* ES2M source: wolfer168/es2-webmud @ 10aa4561; 參考裝備，未指定 NPC 掉落。 */
#include <ansi.h>
#include <armor.h>
inherit F_ARMOR;
void create(){set_name("步軍戰鎧",({"battle armor","armor"}));set_weight(12000);setup_armor();if(!clonep()){set("unit","套");set("value",26000);set("long","一套天朝步軍武將的制式戰甲，以硬化牛皮及鐵甲保護要害，厚重而堅固。\n");set("wear_as","armor");set("apply_armor/armor",(["armor":40,"wittiness":25]));}setup();}
