/* V0：金錢管理，使用 Original money object/value。 */
#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object t;string id,op;int a;SECURED_ADMIN_COMMAND;if(!KING_D->authorized(me))return notify_fail("只有 ES2-KING Owner 可以使用 kmoney。\n");if(!arg||sscanf(arg,"%s %s %d",id,op,a)!=3||(op!="add"&&op!="remove")||a<=0)return notify_fail("格式：kmoney <玩家帳號> <add|remove> <金額>\n");t=find_player(id);if(!objectp(t)||!userp(t)||t->query("id")!=id)return notify_fail("找不到在線玩家帳號。\n");if(op=="remove")a=-a;if(!KING_D->add_managed_money(me,t,a))return notify_fail("金錢修改失敗。\n");KADMIN_D->record(me,t,"kmoney",op,a,"PASS");write("金錢修改完成："+id+"\n");return 1;}
int help(object me){write("格式：kmoney <玩家帳號> <add|remove> <金額>\n範例：kmoney king add 10000\n");return 1;}
