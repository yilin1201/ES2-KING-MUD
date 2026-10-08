/* V0：人物位置查詢。 */
#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object t,e;SECURED_ADMIN_COMMAND;if(!KADMIN_D->is_owner(me))return notify_fail("只有 KING Owner 可以使用 klocate。\n");if(!arg)return notify_fail("格式：klocate <玩家帳號>\n");t=find_player(arg);if(!objectp(t)||!userp(t)||t->query("id")!=arg)return notify_fail("找不到在線玩家帳號。\n");e=environment(t);write(sprintf("%s：environment=%s\n",arg,objectp(e)?file_name(e):"UNKNOWN"));return 1;}
int help(object me){write("格式：klocate <玩家帳號>\n範例：klocate king\n");return 1;}
