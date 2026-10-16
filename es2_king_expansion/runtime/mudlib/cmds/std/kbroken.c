#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object e=environment(me),ob;mapping x;string d,p,err;int n;if(!KADMIN_D->can_arch(me))return notify_fail("只有 KING／大巫師可以使用 kbroken。\n");x=e->query("exits");if(mapp(x))foreach(d,p in x)if(file_size(p+".c")>=0){err=catch(ob=load_object(p));if(err||!objectp(ob)){write("BROKEN: "+d+" -> "+p+"\n");n++;}}if(!n)write("目前可定位 Source 的 RAW EXIT 未發現 BROKEN Runtime target；Missing 請使用 kmiss。\n");return 1;}
int help(object me){if(!KADMIN_D->can_arch(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("指令格式：kbroken\n\n檢查 Source 存在但 Runtime 無法載入的 RAW EXIT；不存在的 Source 由 kmiss 報告。\n");return 1;}
