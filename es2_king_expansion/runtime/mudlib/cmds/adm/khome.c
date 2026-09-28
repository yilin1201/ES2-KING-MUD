#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
private void create(){seteuid(getuid());}
int main(object me,string arg){ SECURED_ADMIN_COMMAND; if(!KING_D->authorized(me)) return notify_fail("只有 ES2-KING Owner 可以使用 khome。\n"); if(!me->move("/d/king/wuji_realm")) return notify_fail("無法進入天神殿・無極之境。\n"); write("你進入天神殿・無極之境。\n"); return 1; }
