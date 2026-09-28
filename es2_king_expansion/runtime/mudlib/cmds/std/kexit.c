#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object e,ob;mapping x;string d,p,err;if(!KADMIN_D->can_view(me))return notify_fail("你沒有 K 出口巡查權限。\n");e=environment(me);if(!objectp(e))return 0;x=e->query("exits");if(!mapp(x)||!sizeof(x)){write("沒有 RAW EXIT。\nSTATIC SOURCE ANALYSIS REQUIRED：條件／add_action 隱藏出口。\n");return 1;}foreach(d,p in x){if(file_size(p+".c")<0){write(sprintf("[MISSING]  %-10s -> %s\n",d,p));continue;}err=catch(ob=load_object(p));if(err||!objectp(ob))write(sprintf("[BROKEN]   %-10s -> %s\n",d,p));else write(sprintf("[VISIBLE / RAW EXIT] %-10s -> %s\n",d,p));}write("STATIC SOURCE ANALYSIS REQUIRED：條件／add_action／valid_leave／move／call_other／Quest Trigger。\n");return 1;}
int help(object me){if(!KADMIN_D->can_view(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("指令格式：kexit\n\n分類目前房間出口為 VISIBLE / RAW EXIT、MISSING 或 BROKEN；隱藏與條件出口標記 STATIC SOURCE ANALYSIS REQUIRED。\n");return 1;}
