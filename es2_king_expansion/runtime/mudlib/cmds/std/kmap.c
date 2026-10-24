#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object e=environment(me);mapping x;string d,p;if(!KADMIN_D->can_view(me))return notify_fail("你沒有 K 地圖巡查權限。\n");if(!objectp(e))return 0;x=e->query("exits");write("KMAP（目前房間／一層唯讀）\n"+file_name(e)+"\n");if(mapp(x))foreach(d,p in x)write("  [RAW EXIT] "+d+" -> "+p+(file_size(p+".c")>=0?" [VISIBLE]":" [MISSING]")+"\n");write("特殊 Trigger 不由 Runtime 猜測；STATIC SOURCE ANALYSIS REQUIRED。\n");return 1;}
int help(object me){if(!KADMIN_D->can_view(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("指令格式：kmap\n\n唯讀列出目前房間一層 RAW EXIT；不存在 Source 標記 MISSING，特殊 Trigger 需 Static Source Analysis。\n");return 1;}
