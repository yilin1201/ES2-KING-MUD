/* ES2-KING 人物管理系統 V0：人物位置查詢。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object who,e;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 KING Owner 可使用 klocate。\n");if(!arg)return notify_fail("格式：klocate <玩家帳號>\n");who=K->resolve_target(me,arg);if(!who)return notify_fail("找不到在線玩家帳號。\n");e=environment(who);write(sprintf("%s 目前位置：%s\n",arg,objectp(e)?file_name(e):"UNKNOWN"));return 1;}
int help(object me){if(!K->authorized(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("klocate <玩家帳號>：查詢在線人物目前房間。\n");return 1;}
