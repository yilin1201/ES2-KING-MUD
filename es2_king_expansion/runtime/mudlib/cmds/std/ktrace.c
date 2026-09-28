#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object e=environment(me);mapping x;string d,p;if(!KADMIN_D->can_arch(me))return notify_fail("只有 KING／大巫師可以使用 ktrace。\n");if(!arg)return notify_fail("格式：ktrace <room path>\n");x=e->query("exits");if(mapp(x))foreach(d,p in x)if(p==arg){write("DIRECT: "+d+" -> "+p+"\n");return 1;}write("目前只做 Evidence-bounded 直接連結追蹤；未發現直接出口。\n");return 1;}