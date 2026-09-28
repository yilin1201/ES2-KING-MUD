#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object ob;if(!KADMIN_D->can_arch(me))return notify_fail("只有 KING／大巫師可以使用 kobj。\n");if(!arg)return notify_fail("格式：kobj <id>\n");ob=present(arg,me);if(!ob&&environment(me))ob=present(arg,environment(me));if(!objectp(ob))return notify_fail("找不到物件。\n");write(sprintf("name=%O\nid=%O\nfile=%s\nenv=%s\n",ob->name(),ob->query("id"),file_name(ob),environment(ob)?file_name(environment(ob)):"NONE"));return 1;}
int help(object me){if(!KADMIN_D->can_arch(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("指令格式：kobj <id>\n\n唯讀顯示身上或目前房間 Runtime object 的名稱、ID、Source path 與環境。\n");return 1;}
