/* V0：武功／技能等級管理。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object t;string id,s;int v;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 ES2-KING Owner 可以使用 kskill。\n");if(!arg||sscanf(arg,"%s %s %d",id,s,v)!=3)return notify_fail("格式：kskill <玩家帳號> <Skill ID> <等級>\n");t=K->resolve_target(me,id);if(!objectp(t)||v<0||v>300||!K->set_skill_level(me,t,s,v))return notify_fail("技能修改失敗：Skill ID 不存在或 Original API 拒絕。\n");write("武功技能修改完成："+id+" "+s+" = "+v+"\n");return 1;}
int help(object me){write("格式：kskill <玩家帳號> <Skill ID> <等級>\n範例：kskill king sword 300\n");return 1;}
