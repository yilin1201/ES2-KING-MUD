#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object e=environment(me);mapping x;string d,p;if(!KADMIN_D->can_view(me))return notify_fail("你沒有 K 出口巡查權限。\n");if(!objectp(e))return 0;x=e->query("exits");if(!mapp(x)||!sizeof(x)){write("沒有 Raw exits。\n");return 1;}foreach(d,p in x)write(sprintf("%-10s -> %-45s %s\n",d,p,file_size(p+".c")>=0?"OK":"MISSING/BROKEN"));write("條件／add_action 隱藏出口：STATIC SOURCE ANALYSIS REQUIRED\n");return 1;}