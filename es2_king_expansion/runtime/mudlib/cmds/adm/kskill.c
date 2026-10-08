/* ES2-KING 人物管理系統 V0：武功等級管理。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){string id,sk;int v;object who;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 KING Owner 可使用 kskill。\n");if(!arg||sscanf(arg,"%s %s %d",id,sk,v)!=3)return notify_fail("格式：kskill <玩家帳號> <Skill ID> <等級>\n");if(v<0||v>300||strsrch(sk,"/")>=0||strsrch(sk,".")>=0)return notify_fail("非法 Skill ID 或等級。\n");who=K->resolve_target(me,id);if(!who)return notify_fail("找不到在線玩家帳號。\n");if(!K->set_skill_level(me,who,sk,v))return notify_fail("武功修改失敗。\n");write(sprintf("武功修改完成：%s %s = %d\n",id,sk,v));return 1;}
int help(object me){if(!K->authorized(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("kskill <玩家帳號> <Skill ID> <等級>\n範例：kskill king sword 300\n");return 1;}
