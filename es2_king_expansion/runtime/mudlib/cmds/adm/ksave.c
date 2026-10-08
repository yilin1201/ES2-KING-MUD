/* V0：Original save() 永久保存。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object t;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 KING Owner 可以使用 ksave。\n");if(!arg)return notify_fail("格式：ksave <玩家帳號>\n");t=find_player(arg);if(!objectp(t)||!userp(t)||t->query("id")!=arg)return notify_fail("找不到在線玩家帳號。\n");if(!K->save_target(me,t))return notify_fail("Original save() 儲存失敗。\n");write("永久保存完成："+arg+"\n");return 1;}
int help(object me){write("格式：ksave <玩家帳號>\n範例：ksave king\n");return 1;}
