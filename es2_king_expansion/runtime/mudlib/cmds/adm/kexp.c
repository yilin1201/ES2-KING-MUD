/* ES2-KING 人物管理系統 V0：經驗／潛能正式欄位管理。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){string id,field,op;int v;object who;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 KING Owner 可使用 kexp。\n");if(!arg||sscanf(arg,"%s %s %s %d",id,field,op,v)!=4)return notify_fail("格式：kexp <玩家帳號> exp|potential add|set <數值>\n");if(field=="exp")field="combat_exp";else if(field!="potential")return notify_fail("欄位只能是 exp 或 potential。\n");if(v<0)return notify_fail("數值不得為負數。\n");who=K->resolve_target(me,id);if(!who)return notify_fail("找不到在線玩家帳號。\n");if(!K->change_score_field(me,who,field,op,v))return notify_fail("經驗／潛能修改失敗。\n");write("經驗／潛能修改完成。\n");return 1;}
int help(object me){if(!K->authorized(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("kexp <玩家帳號> exp|potential add|set <數值>\n");return 1;}
