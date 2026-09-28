#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
#define D "/adm/daemons/kingcanon_d"
private void create(){seteuid(getuid());}
int main(object me,string arg){string n,v;int x;SECURED_ADMIN_COMMAND;if(!KING_D->authorized(me))return notify_fail("只有 ES2-KING Owner 可以使用 kcanon。\n");if(!arg||sscanf(arg,"%s %s",n,v)!=2||sscanf(v,"%d",x)!=1)return notify_fail("格式：kcanon huntian 1..10 | rulai 1..11 | turn 1..4\n");if(n=="huntian"&&D->set_huntian(me,x)){write("渾天寶鑑設定完成。\n");return 1;}if(n=="rulai"&&D->set_rulai(me,x)){write("如來神掌設定完成。\n");return 1;}if(n=="turn"&&D->set_turn(me,x)){write("神輪四轉設定完成。\n");return 1;}return notify_fail("超出既定 Canon 範圍。\n");}
