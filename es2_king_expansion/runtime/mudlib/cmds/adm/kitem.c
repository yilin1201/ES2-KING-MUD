/* V0：裝備／道具；只允許 KING Registry 已確認物件。 */
#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object t,o;string id,op,item,file;mapping r;SECURED_ADMIN_COMMAND;if(!KING_D->authorized(me))return notify_fail("只有 ES2-KING Owner 可以使用 kitem。\n");if(!arg||sscanf(arg,"%s %s %s",id,op,item)!=3||(op!="give"&&op!="remove"))return notify_fail("格式：kitem <玩家帳號> <give|remove> <物品ID>\n");t=find_player(id);if(!objectp(t)||!userp(t)||t->query("id")!=id)return notify_fail("找不到在線玩家帳號。\n");if(op=="give"){r=KING_D->query_creation_registry(me);file=r[item];if(!stringp(file))return notify_fail("物品 ID 未登錄，拒絕任意路徑建立物件。\n");o=new(file);if(!objectp(o)||!o->move(t)){if(o)destruct(o);return notify_fail("物品建立／移交失敗。\n");}KADMIN_D->record(me,t,"kitem","give",item,"PASS");write("物品新增完成："+id+" "+item+"\n");return 1;}foreach(o in all_inventory(t))if(o->id(item)){destruct(o);KADMIN_D->record(me,t,"kitem","remove",item,"PASS");write("物品移除完成："+id+" "+item+"\n");return 1;}return notify_fail("找不到指定物品。\n");}
int help(object me){write("格式：kitem <玩家帳號> <give|remove> <物品ID>\n目前僅允許 KING Registry 已確認物件。\n");return 1;}
