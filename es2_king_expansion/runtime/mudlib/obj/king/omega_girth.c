#include <armor.h>
#include <ansi.h>
inherit F_WAIST_EQ;
void create(){set_name(HIW "超級Ω神聖衣。" HIY "神鎖" NOR,({"omega girth","girth"}));set_weight(700);setup_waist_eq();if(!clonep()){set("unit","條");set("value",0);set("long","無數繁複神聖星鎖環扣而成的金色束腰，中央Ω神徽鎖定穿戴者的星宿本源與氣海穴道，使小宇宙生生不息、下盤穩若泰山。\n");set("wear_as","waist_eq");set("apply_armor/waist_eq",(["armor":30,"omega_absolute_body":1]));set("es2_king/omega_cloth",1);}setup();}
