#include <armor.h>
#include <ansi.h>
inherit F_HEAD_EQ;
void create(){set_name(HIW "神聖Ω神盔" HIY "" NOR,({"omega crown","crown"}));set_weight(1200);setup_head_eq();if(!clonep()){set("unit","頂");set("value",0);set("long","閃耀永恆神芒的天馬戰盔，兩側舒展象徵弒神榮耀的金色天馬羽翼，額心星核寶石匯聚宏大小宇宙。群星意志護佑靈台，諸邪退避。\n");set("wear_as","head_eq");set("apply_armor/head_eq",(["armor":35]));set("es2_king/omega_cloth",1);}setup();}
