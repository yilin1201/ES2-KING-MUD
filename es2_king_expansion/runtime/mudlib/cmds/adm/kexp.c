/* ES2-KING 人物管理系統 V0：經驗／潛能管理。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object t;string id,field,op;int v;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 ES2-KING Owner 可以使用 kexp。\n");if(!arg||sscanf(arg,"%s %s %s %d",id,field,op,v)!=4||(field!="exp"&&field!="potential")||(op!="add"&&op!="set")||v<0)return notify_fail("格式：kexp <玩家帳號> exp|potential add|set <數值>\n");t=K->resolve_target(me,id);if(!objectp(t))return notify_fail("找不到在線玩家帳號。\n");if(field=="exp"){if(!K->change_score_field(me,t,"combat_exp",op,v))return notify_fail("經驗修改失敗。\n");}else{if(!K->change_score_field(me,t,"potential",op,v))return notify_fail("潛能修改失敗。\n");}write("經驗／潛能修改完成："+id+" "+field+" "+op+" "+v+"\n");return 1;}
int help(object me){write("格式：kexp <玩家帳號> exp|potential add|set <數值>\n範例：kexp king exp add 10000\n");return 1;}