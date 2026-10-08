/* ES2-KING 人物管理系統 V0：屬性與精氣神管理。 */
#include <command.h>
inherit F_CLEAN_UP;
#define K "/adm/daemons/kcharadmind"
private void create(){seteuid(getuid());}
int main(object me,string arg){string id,key;int v;object who;SECURED_ADMIN_COMMAND;if(!K->authorized(me))return notify_fail("只有 KING Owner 可使用 kset。\n");if(!arg||sscanf(arg,"%s %s %d",id,key,v)!=3)return notify_fail("格式：kset <玩家帳號> <欄位> <數值>\n");if(v<1||v>999)return notify_fail("數值必須為 1～999。\n");who=K->resolve_target(me,id);if(!who)return notify_fail("找不到在線玩家帳號。\n");if(member_array(key,({"str","cor","int","spi","cps","dex","con","wis"}))>=0){if(v>99)return notify_fail("八大屬性上限為 99。\n");if(!K->set_attribute(me,who,key,v))return notify_fail("屬性修改失敗。\n");}else if(key=="max_gin"||key=="max_kee"||key=="max_sen"){if(!K->set_stat(me,who,key[4..],v))return notify_fail("精氣神修改失敗。\n");}else return notify_fail("未知欄位。\n");write(sprintf("修改完成：%s %s = %d\n",id,key,v));return 1;}
int help(object me){if(!K->authorized(me))return notify_fail("沒有針對這項主題的說明文件。\n");write("kset <玩家帳號> <欄位> <數值>\n八大屬性：str/cor/int/spi/cps/dex/con/wis（1～99）\n精氣神：max_gin/max_kee/max_sen（1～999）\n");return 1;}
