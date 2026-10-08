/* V0：武功／技能等級管理。 */
#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object t;string id,s;int v;SECURED_ADMIN_COMMAND;if(!KING_D->authorized(me))return notify_fail("只有 ES2-KING Owner 可以使用 kskill。\n");if(!arg||sscanf(arg,"%s %s %d",id,s,v)!=3)return notify_fail("格式：kskill <玩家帳號> <Skill ID> <等級>\n");if(v<0||v>300)return notify_fail("技能等級必須介於 0～300。\n");t=find_player(id);if(!objectp(t)||!userp(t)||t->query("id")!=id)return notify_fail("找不到在線玩家帳號。\n");if(!KING_D->set_managed_skill(me,t,s,v))return notify_fail("技能修改失敗：Skill ID 不存在或 Original API 拒絕。\n");KADMIN_D->record(me,t,"kskill",s,v,"PASS");write("武功技能修改完成："+id+" "+s+" = "+v+"\n");return 1;}
int help(object me){write("格式：kskill <玩家帳號> <Skill ID> <等級>\n範例：kskill king sword 300\n");return 1;}
