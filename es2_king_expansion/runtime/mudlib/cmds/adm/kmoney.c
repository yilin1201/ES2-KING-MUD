/* V0：金錢管理，使用 Original money object/value。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object t;string id,op;int a;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 ES2-KING Owner 可以使用 kmoney。\n");if(!arg||sscanf(arg,"%s %s %d",id,op,a)!=3||(op!="add"&&op!="remove")||a<=0)return notify_fail("格式：kmoney <玩家帳號> <add|remove> <金額>\n");t=K->resolve_target(me,id);if(!objectp(t)||!K->change_money(me,t,op,a))return notify_fail("金錢修改失敗。\n");write("金錢修改完成："+id+" "+op+" "+sprintf("%d",a)+"\n");return 1;}
int help(object me){write("格式：kmoney <玩家帳號> <add|remove> <金額>\n範例：kmoney king add 10000\n");return 1;}
