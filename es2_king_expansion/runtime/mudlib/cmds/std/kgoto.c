#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){if(!KADMIN_D->can_arch(me))return notify_fail("只有 KING／大巫師可以使用 kgoto。\n");if(!arg)return notify_fail("格式：kgoto <room path>\n");if(file_size(arg+".c")<0)return notify_fail("Room 不存在。\n");if(!me->move(arg))return notify_fail("移動失敗。\n");write("KGOTO -> "+arg+"\n");return 1;}