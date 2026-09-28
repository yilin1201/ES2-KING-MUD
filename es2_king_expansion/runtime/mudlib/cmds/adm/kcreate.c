#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
private void create(){seteuid(getuid());}
int main(object me,string arg){ object ob; mapping m; SECURED_ADMIN_COMMAND; if(!KING_D->authorized(me)) return notify_fail("只有 ES2-KING Owner 可以使用 kcreate。\n"); if(!arg||arg=="list"){m=KING_D->query_creation_registry(me);write("KING 可建立項目："+implode(sort_array(keys(m),1),"、")+"\n");return 1;} ob=KING_D->create_registered(me,arg); if(!objectp(ob)) return notify_fail("建立失敗。\n"); write("KING 建立完成："+ob->name()+"（"+arg+"）\n"); return 1; }
