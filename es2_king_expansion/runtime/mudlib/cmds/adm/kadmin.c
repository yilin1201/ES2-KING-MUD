/* ES2-KING 人物管理系統 V0：權限與修改紀錄查詢。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){string id,r;mapping m;mixed *a;string *ids;SECURED_ADMIN_COMMAND;if(!K->is_owner(me))return notify_fail("只有 KING Owner 可以管理 k* 權限。\n");if(!arg||arg=="list"){m=K->query_roles(me);ids=sort_array(keys(m),1);write("K 管理團隊：\n");foreach(id in ids)write(sprintf("%-16s %s\n",id,m[id]));if(!sizeof(ids))write("（目前沒有授權成員）\n");return 1;}if(sscanf(arg,"audit %s",id)==1){a=K->query_audit(me,id);if(!sizeof(a))return notify_fail("查無修改紀錄。\n");foreach(mapping e in a)write(sprintf("%s actor=%s target=%s action=%s field=%s value=%O result=%s\n",ctime(e["time"]),e["actor"],e["target"],e["action"],e["field"],e["value"],e["result"]));return 1;}if(sscanf(arg,"%s status",id)==1){object ob=find_player(id);write(id+"："+(objectp(ob)?K->role(ob):(K->query_roles(me)[id]||"player"))+"\n");return 1;}if(sscanf(arg,"%s %s",id,r)!=2)return notify_fail("格式：kadmin list | kadmin audit <ID> | kadmin <ID> wizard|arch|remove|status\n");if(!K->set_role(me,id,r))return notify_fail("權限變更失敗。\n");write("K 權限已更新："+id+" -> "+r+"\n");return 1;}
int help(object me){write("kadmin list\nkadmin audit <玩家帳號>\nkadmin <ID> wizard|arch|remove|status\n");return 1;}
