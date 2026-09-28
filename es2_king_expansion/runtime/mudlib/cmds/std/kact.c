#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){if(!KADMIN_D->can_view(me))return notify_fail("你沒有 K Trigger 巡查權限。\n");write("KACT：Runtime 不安全推測 add_action()/move()/Quest Trigger。\nSTATIC SOURCE ANALYSIS REQUIRED：push/open/enter/climb/search/say/give 等。\n");return 1;}