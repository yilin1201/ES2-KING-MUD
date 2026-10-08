/* V0：精氣神／八大屬性管理。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){object t;string id,f;int v,ok;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 ES2-KING Owner 可以使用 kset。\n");if(!arg||sscanf(arg,"%s %s %d",id,f,v)!=3)return notify_fail("格式：kset <玩家帳號> <欄位> <數值>\n");t=K->resolve_target(me,id);if(!objectp(t))return notify_fail("找不到在線玩家帳號。\n");if(v<1||v>999)return notify_fail("數值超出 V0 安全範圍。\n");if(sscanf(f,"max_%s",f)==1)ok=K->set_stat(me,t,f,v);else ok=K->set_attribute(me,t,f,v);if(!ok)return notify_fail("kset 修改失敗：欄位不存在或 Original API 拒絕。\n");write("人物修改完成："+id+" "+f+" = "+v+"\n");return 1;}
int help(object me){write("kset <玩家帳號> max_gin|max_kee|max_sen|str|cor|int|spi|cps|dex|con|wis <數值>\n");return 1;}
