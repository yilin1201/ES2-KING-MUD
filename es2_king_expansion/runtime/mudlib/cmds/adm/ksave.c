/* ES2-KING 人物管理系統 V0：正式玩家 save API。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object who;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 KING Owner 可使用 ksave。\n");if(!arg)return notify_fail("格式：ksave <玩家帳號>\n");who=K->resolve_target(me,arg);if(!who)return notify_fail("找不到在線玩家帳號。\n");if(!K->save_target(me,who))return notify_fail("保存失敗。\n");write("人物保存完成。\n");return 1;}
int help(object me){if(!K->authorized(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("ksave <玩家帳號>：使用 Original save() API 保存。\n");return 1;}
