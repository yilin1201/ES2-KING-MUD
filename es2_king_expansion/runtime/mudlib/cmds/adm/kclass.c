/* V0：職業管理，沿用 Original set_class()。 */
#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object t;string id,c;SECURED_ADMIN_COMMAND;if(!KING_D->authorized(me))return notify_fail("只有 ES2-KING Owner 可以使用 kclass。\n");if(!arg||sscanf(arg,"%s %s",id,c)!=2)return notify_fail("格式：kclass <玩家帳號> <職業ID>\n");t=find_player(id);if(!objectp(t)||!userp(t)||t->query("id")!=id)return notify_fail("找不到在線玩家帳號。\n");if(!KING_D->set_managed_class(me,t,c))return notify_fail("職業修改失敗：Class ID 不存在、種族限制拒絕或 Original API 拒絕。\n");KADMIN_D->record(me,t,"kclass","class",c,"PASS");write("職業修改完成："+id+" class="+c+"\n");return 1;}
int help(object me){write("格式：kclass <玩家帳號> <職業ID>\n範例：kclass king fighter\n");return 1;}
