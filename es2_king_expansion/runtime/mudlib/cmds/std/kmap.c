#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object e=environment(me);mapping x;string d,p;if(!KADMIN_D->can_view(me))return notify_fail("你沒有 K 地圖巡查權限。\n");if(!objectp(e))return 0;x=e->query("exits");write("KMAP（目前房間／一層唯讀）\n"+file_name(e)+"\n");if(mapp(x))foreach(d,p in x)write("  "+d+" -> "+p+(file_size(p+".c")>=0?"":" [MISSING]")+"\n");write("特殊 Trigger 不由 Runtime 猜測；需 Static Source Analysis。\n");return 1;}