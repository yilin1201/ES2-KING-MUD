#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
#define D "/adm/daemons/kingmartiald"
private void create(){seteuid(getuid());}
int main(object me,string arg){string n,v;int x;SECURED_ADMIN_COMMAND;if(!KING_D->authorized(me))return notify_fail("只有 ES2-KING Owner 可以使用 kmartial。\n");if(!arg||sscanf(arg,"%s %s",n,v)!=2)return notify_fail("格式：kmartial yijinjing <1..300> | batian zhao|ji | daxie <1..200|status>\n");if(n=="yijinjing"&&sscanf(v,"%d",x)==1&&D->set_yijinjing(me,x)){write("易筋經設定完成。\n");return 1;}if(n=="batian"&&D->set_batian(me,v)){write("霸天煉體訣設定完成。\n");return 1;}if(n=="daxie"&&v=="status"){write(sprintf("哭笑門心法 Lv.%d／大邪七損刀 Lv.%d／大邪金身：%s\n",me->query_skill("kuxiao force",1),me->query_skill("daxie qisun blade",1),me->query("es2_king/daxie_jinshen")?"ON":"OFF"));return 1;}if(n=="daxie"&&sscanf(v,"%d",x)==1&&D->set_daxie(me,x)){write("大邪武學設定完成。\n");return 1;}return notify_fail("未知或未授權設定。\n");}
