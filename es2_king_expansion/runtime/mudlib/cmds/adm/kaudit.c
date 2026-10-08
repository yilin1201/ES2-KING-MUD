/* ES2-KING 人物管理系統 V0：修改紀錄。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){mapping *rows;mapping r;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 KING Owner 可使用 kaudit。\n");rows=K->query_audit(me,arg);if(!sizeof(rows)){write("沒有符合的修改紀錄。\n");return 1;}foreach(r in rows)write(sprintf("%s actor=%s target=%s %s: %s -> %s\n",ctime(r["time"]),r["actor"],r["target"],r["action"],r["old"],r["new"]));return 1;}
int help(object me){if(!K->authorized(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("kaudit <玩家帳號>：查詢人物管理修改紀錄。\n");return 1;}
