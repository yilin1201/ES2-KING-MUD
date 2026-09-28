#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object e=environment(me),ob;if(!KADMIN_D->can_view(me))return notify_fail("你沒有 K 查詢權限。\n");foreach(ob in all_inventory(e))if(living(ob)&&!interactive(ob))write(sprintf("%-20s id=%O file=%s\n",(string)ob->name(),ob->query("id"),file_name(ob)));return 1;}