/* ES2-KING 人物管理系統 V0：21 項說明。 */
#include <command.h>
inherit F_CLEAN_UP;
private void create(){seteuid(getuid());}
int main(object me,string arg){if(arg&&arg!="kset")return 0;write(@HELP
ES2-KING 人物管理系統 V0
01 kinfo king                 人物查詢
02 kset king max_gin 999      精上限
03 kset king max_kee 999      氣上限
04 kset king max_sen 999      神上限
05 kset king str 99           膂力上限
06 kset king cor 99           膽識上限
07 kset king int 99           悟性上限
08 kset king spi 99           靈性上限
09 kset king cps 99           定力上限
10 kset king dex 99           機敏上限
11 kset king con 99           根骨上限
12 kset king wis 99           慧根上限
13 kskill king sword 300      武功等級
14 kclass king fighter        門派／職業
15 kexp king add 10000        經驗潛能（目前 BLOCKED）
16 kmoney king add 10000      金錢
17 kitem king give <物品ID>   裝備／道具
18 klocate king               人物位置
19 ksave king                 永久保存
20 kadmin audit king          修改紀錄
21 help kset                  指令說明
HELP
);return 1;}
int help(object me){return main(me,"kset");}
