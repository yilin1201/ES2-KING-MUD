#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object e=environment(me);mapping x;if(!KADMIN_D->can_view(me))return notify_fail("你沒有 K 地圖巡查權限。\n");if(!objectp(e))return notify_fail("目前沒有所在房間。\n");write("Room: "+file_name(e)+"\n");write("Name: "+(string)e->query("short")+"\n");x=e->query("exits");write("Raw exits: "+(mapp(x)?sprintf("%O",x):"無")+"\n");write("Action/Trigger: STATIC SOURCE ANALYSIS REQUIRED\n");return 1;}