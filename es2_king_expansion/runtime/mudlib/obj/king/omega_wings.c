#include <armor.h>
#include <ansi.h>
inherit F_NECK_EQ;
// Original ES2 沒有獨立背部／護肩槽；neck_eq 是最接近 mantle／披風且不占用身體盔甲的合法槽位。
void create(){set_name(HIW "神聖Ω神翼" HIY "" NOR,({"omega wings","wings"}));set_weight(900);setup_neck_eq();if(!clonep()){set("unit","襲");set("value",0);set("long","十二重燦金光翼自聖衣後背自然延伸，每一片神羽皆承載黃道十二宮與青銅不屈之魂；振翅時撕裂虛空亂流，使穿戴者跨入光速神域。\n");set("wear_as","neck_eq");set("apply_armor/neck_eq",(["armor":40,"omega_lightspeed_realm":1]));set("es2_king/omega_cloth",1);}setup();}
