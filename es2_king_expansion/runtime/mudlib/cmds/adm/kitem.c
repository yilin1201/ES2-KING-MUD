/* ES2-KING 人物管理系統 V0：裝備／道具。只允許 KING Registry 已確認物件。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object t,o;string id,op,item;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 ES2-KING Owner 可以使用 kitem。\n");if(!arg||sscanf(arg,"%s %s %s",id,op,item)!=3||(op!="give"&&op!="remove"))return notify_fail("格式：kitem <玩家帳號> <give|remove> <物品ID>\n");t=K->resolve_target(me,id);if(!objectp(t))return notify_fail("找不到在線玩家帳號。\n");if(op=="give"){if(!K->give_item(me,t,item))return notify_fail("物品 ID 未登錄或建立／移交失敗。\n");write("物品新增完成："+id+" "+item+"\n");return 1;}foreach(o in all_inventory(t))if(o->id(item)){destruct(o);write("物品移除完成："+id+" "+item+"\n");return 1;}return notify_fail("找不到指定物品。\n");}
int help(object me){write("格式：kitem <玩家帳號> <give|remove> <物品ID>\n僅允許 KING Registry 已確認物件。\n");return 1;}
