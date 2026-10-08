/* ES2-KING 人物管理系統 V0 — 完整唯讀人物資訊。 */
#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private int money_value(object who){object o;int n=0;o=present("gold_money",who);if(o)n+=(int)o->value();o=present("silver_money",who);if(o)n+=(int)o->value();o=present("coin_money",who);if(o)n+=(int)o->value();return n;}
private void create(){seteuid(getuid());}
int main(object me,string arg){object who,e,item;string *keys=({"str","cor","int","spi","cps","dex","con","wis"});string *labels=({"膂力","膽識","悟性","靈性","定力","機敏","根骨","慧根"});int i;SECURED_ADMIN_COMMAND;if(!KADMIN_D->is_owner(me))return notify_fail("只有 KING Owner 可使用人物管理查詢。
");if(!arg)return notify_fail("格式：kinfo <玩家帳號>
");who=find_player(arg);if(!objectp(who)||!userp(who)||(string)who->query("id")!=arg)return notify_fail("找不到在線玩家帳號；V0 目前只操作在線人物。
");write("【ES2-KING 人物管理系統 V0】
");write("帳號 (id)："+(string)who->query("id")+"
");write("名稱 (name)："+(string)who->name()+"
");write("【精氣神：當前／上限】
");foreach(string st in ({"gin","kee","sen"}))write(sprintf("%s (%s)：%d / %d
",st=="gin"?"精":st=="kee"?"氣":"神",st,(int)who->query_stat_current(st),(int)who->query_stat_maximum(st)));write("【八大基本屬性】
");for(i=0;i<sizeof(keys);i++)write(sprintf("%s (%s)：%d
",labels[i],keys[i],(int)who->query_attr(keys[i],1)));write(sprintf("職業 (class)：%O
",who->query_class()));write(sprintf("經驗 (combat_exp)：%d
",(int)who->query("combat_exp")));write(sprintf("潛能 (potential)：%d
",(int)who->query("potential")));write("【武功技能】
");write(sprintf("skills：%O
",who->query_skills()));write(sprintf("【金錢】總值：%d
",money_value(who)));write("【裝備道具】
");foreach(item in all_inventory(who))if(!living(item))write(sprintf("- %s id=%O equipped=%O file=%s
",(string)item->name(),item->query("id"),item->query("equipped"),file_name(item)));e=environment(who);write(sprintf("【人物位置】%s
",objectp(e)?file_name(e):"UNKNOWN"));write("【保存】由 ksave 執行 Original save() API。
");return 1;}
int help(object me){if(!KADMIN_D->is_owner(me))return notify_fail("沒有針對這項主題的說明文件。
");write("kinfo <玩家帳號>：查詢在線人物完整管理資訊。
");return 1;}
