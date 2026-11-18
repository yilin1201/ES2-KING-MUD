/* ES2-KING 人物管理系統 V0：受控物品發放。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){string id,item;object who;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 KING Owner 可使用 kitemgive。\n");if(!arg||sscanf(arg,"%s %s",id,item)!=2)return notify_fail("格式：kitemgive <玩家帳號> <物品ID>\n");who=K->resolve_target(me,id);if(!who)return notify_fail("找不到在線玩家帳號。\n");if(!K->give_item(me,who,item))return notify_fail("物品發放失敗，請確認 /obj/ 下物品存在。\n");write("物品發放完成。\n");return 1;}
int help(object me){if(!K->authorized(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("kitemgive <玩家帳號> <物品ID>\n範例：kitemgive king weapon/sword\n");return 1;}
