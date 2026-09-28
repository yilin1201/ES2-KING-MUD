#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object e=environment(me);mapping x;string d,p;int n;if(!KADMIN_D->can_arch(me))return notify_fail("只有 KING／大巫師可以使用 kbroken。\n");x=e->query("exits");if(mapp(x))foreach(d,p in x)if(file_size(p+".c")<0){write(d+" -> "+p+" [BROKEN/MISSING]\n");n++;}if(!n)write("目前 Raw exits 未發現失效目標。\n");return 1;}