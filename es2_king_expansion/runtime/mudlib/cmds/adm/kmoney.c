/* ES2-KING 人物管理系統 V0：正式 money object 管理。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){string id,op;int v;object who;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 KING Owner 可使用 kmoney。\n");if(!arg||sscanf(arg,"%s %s %d",id,op,v)!=3)return notify_fail("格式：kmoney <玩家帳號> add|set <數值>\n");if(v<0)return notify_fail("金額不得為負數。\n");who=K->resolve_target(me,id);if(!who)return notify_fail("找不到在線玩家帳號。\n");if(!K->change_money(me,who,op,v))return notify_fail("金錢修改失敗。\n");write("金錢修改完成。\n");return 1;}
int help(object me){if(!K->authorized(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("kmoney <玩家帳號> add|set <最小貨幣單位數值>\n範例：kmoney king add 10000\n");return 1;}
