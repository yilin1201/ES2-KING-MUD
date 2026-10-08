#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){
 string id,r; mapping m; string *ids;
 SECURED_ADMIN_COMMAND;
 if(!KADMIN_D->is_owner(me)) return notify_fail("只有 KING Owner 可以管理 k* 權限。\n");
 if(!arg || arg=="list"){ m=KADMIN_D->query_roles(me); ids=sort_array(keys(m),1); write("K 管理團隊：\n"); foreach(id in ids) write(sprintf("%-16s %s\n",id,m[id])); if(!sizeof(ids)) write("（目前沒有授權成員）\n"); return 1; }
 if(sscanf(arg,"%s %s",id,r)!=2) return notify_fail("格式：kadmin list | kadmin <ID> wizard|arch|remove|status\n");
 if(r=="status"){ object ob=find_player(id); write(id+"："+(objectp(ob)?KADMIN_D->role(ob):(KADMIN_D->query_roles(me)[id]||"player"))+"\n"); return 1; }
 if(!KADMIN_D->set_role(me,id,r)) return notify_fail("權限變更失敗。\n");
 write("K 權限已更新："+id+" -> "+r+"\n"); return 1;
}
int help(object me){if(!KADMIN_D->is_owner(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("指令格式：kadmin list | kadmin <ID> wizard|arch|remove|status\n\n只有 KING Owner 可管理獨立 K-team 權限；不修改 Original wiz_status／promote。\n");return 1;}
