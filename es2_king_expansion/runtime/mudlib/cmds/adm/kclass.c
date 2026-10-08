/* ES2-KING 人物管理系統 V0：正式 class API 管理。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){string id,cl;object who;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 KING Owner 可使用 kclass。\n");if(!arg||sscanf(arg,"%s %s",id,cl)!=2)return notify_fail("格式：kclass <玩家帳號> <職業ID>\n");who=K->resolve_target(me,id);if(!who)return notify_fail("找不到在線玩家帳號。\n");if(!K->set_class(me,who,cl))return notify_fail("職業修改失敗。\n");write(sprintf("職業修改完成：%s -> %s\n",id,cl));return 1;}
int help(object me){if(!K->authorized(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("kclass <玩家帳號> <職業ID>\n範例：kclass king fighter\n");return 1;}
