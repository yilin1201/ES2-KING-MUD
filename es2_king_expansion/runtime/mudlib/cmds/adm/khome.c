#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
private void create(){seteuid(getuid());}
int main(object me,string arg){ SECURED_ADMIN_COMMAND; if(!KING_D->authorized(me)) return notify_fail("只有 ES2-KING Owner 可以使用 khome。\n"); if(!me->move("/d/king/wuji_realm")) return notify_fail("無法進入天神殿・無極之境。\n"); write("你進入天神殿・無極之境。\n"); return 1; }
int help(object me){if(!KING_D->authorized(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("指令格式：khome\n\n將 KING Owner 移動至天神殿・無極之境。舊指令 kinghome 仍相容。\n");return 1;}
