#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
#define KMAP_D "/adm/daemons/kmapd"
private void create(){seteuid(getuid());}
int main(object me,string arg){object e=environment(me);mapping a;mixed acts;if(!KADMIN_D->can_view(me))return notify_fail("你沒有 K Trigger 巡查權限。\n");if(!objectp(e))return notify_fail("目前沒有所在房間。\n");acts=KMAP_D->query_actions(file_name(e));write("KACT: "+file_name(e)+"\n");if(!pointerp(acts)||!sizeof(acts)){write("尚無已登錄的 Source-confirmed Action。\nSTATIC SOURCE ANALYSIS REQUIRED；不自行猜測 climb/push/open/enter/search 等。\n");return 1;}foreach(a in acts){write("\nCommand : "+a["verb"]+" "+a["arg"]+"\n");write("Handler : "+a["handler"]+"\n");write("Target  : "+a["target"]+"\n");write("Status  : SOURCE CONFIRMED\n");write("Evidence: "+a["evidence"]+"\n");}return 1;}
int help(object me){if(!KADMIN_D->can_view(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("指令格式：kact\n顯示目前房間已有 Original Source 證據的 add_action／特殊互動、參數、Handler 與移動目標。\n");return 1;}
