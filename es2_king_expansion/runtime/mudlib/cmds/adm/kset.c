/* V0：精氣神／八大屬性管理。 */
#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object t;string id,f;int v,ok;SECURED_ADMIN_COMMAND;if(!KING_D->authorized(me))return notify_fail("只有 ES2-KING Owner 可以使用 kset。\n");if(!arg||sscanf(arg,"%s %s %d",id,f,v)!=3)return notify_fail("格式：kset <玩家帳號> <欄位> <數值>\n");t=find_player(id);if(!objectp(t)||!userp(t)||t->query("id")!=id)return notify_fail("找不到在線玩家帳號。\n");if(v<1||v>999)return notify_fail("數值超出 V0 安全範圍。\n");if(sscanf(f,"max_%s",f)==1)ok=KING_D->set_managed_stat(me,t,f,v);else ok=KING_D->set_managed_attr(me,t,f,v);if(!ok)return notify_fail("kset 修改失敗：欄位不存在或 Original API 拒絕。\n");KADMIN_D->record(me,t,"kset",f,v,"PASS");write("人物修改完成："+id+" "+f+" = "+v+"\n");return 1;}
int help(object me){write(@HELP
ES2-KING 人物管理系統 V0
kset <玩家帳號> <欄位> <數值>
max_gin 精、max_kee 氣、max_sen 神（上限 999）
str 膂力、cor 膽識、int 悟性、spi 靈性、cps 定力、dex 機敏、con 根骨、wis 慧根（上限 99）
範例：kset king max_gin 999
HELP
);return 1;}
