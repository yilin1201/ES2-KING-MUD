#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
#define KMAP_D "/adm/daemons/kmapd"
private void create(){seteuid(getuid());}
int main(object me,string arg){object e=environment(me);mapping x,a;mixed acts;string d,p;if(!KADMIN_D->can_view(me))return notify_fail("你沒有 K 地圖巡查權限。\n");if(!objectp(e))return notify_fail("目前沒有所在房間。\n");write("Room: "+file_name(e)+"\n");write("Name: "+(string)e->query("short")+"\n");x=e->query("exits");write("\n【Visible / Raw Exits】\n");if(mapp(x))foreach(d,p in x)write(sprintf("  %-8s -> %s%s\n",d,p,file_size(p+".c")>=0?"":" [MISSING/BROKEN]"));else write("  無\n");acts=KMAP_D->query_actions(file_name(e));write("\n【Special Actions / Hidden Commands】\n");if(pointerp(acts)&&sizeof(acts)){foreach(a in acts)write(sprintf("  %s %s -> %s  [SOURCE CONFIRMED]\n",a["verb"],a["arg"],a["target"]));write("  詳細：kact\n");}else write("  尚無已登錄 Source Evidence；STATIC SOURCE ANALYSIS REQUIRED\n");return 1;}
int help(object me){if(!KADMIN_D->can_view(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("指令格式：kroom\n顯示目前房間 Visible/Raw Exits 與已有 Original Source 證據的特殊互動指令。\n未取得證據者不推測。\n");return 1;}
