#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object ob;if(!KADMIN_D->can_view(me))return notify_fail("你沒有 K 查詢權限。\n");ob=arg?find_player(arg):me;if(!objectp(ob))ob=arg?find_living(arg):0;if(!objectp(ob))return notify_fail("找不到目標。\n");write((string)ob->query("id")+" -> "+(environment(ob)?file_name(environment(ob)):"NO ENV")+"\n");return 1;}
int help(object me){if(!KADMIN_D->can_view(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("指令格式：kwhere [玩家或 living id]\n\n唯讀顯示目標目前 Runtime 位置。\n");return 1;}
