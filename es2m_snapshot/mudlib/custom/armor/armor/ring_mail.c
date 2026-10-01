/* ES2M source: wolfer168/es2-webmud @ 10aa4561; 參考裝備，未指定 NPC 掉落。 */
#include <ansi.h>
#include <armor.h>
inherit F_ARMOR;
void create(){set_name("鎖子鎧",({"ring mail","mail"}));set_weight(8000);setup_armor();if(!clonep()){set("unit","件");set("value",8000);set("long","上千個鐵環嵌結而成的鎖子鎧，輕便堅固，不妨礙行動。\n");set("wear_as","armor");set("apply_armor/armor",(["armor":5]));}setup();}
