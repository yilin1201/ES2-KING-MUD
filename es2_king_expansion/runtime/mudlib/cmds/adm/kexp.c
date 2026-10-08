/* V0：經驗／潛能。SOURCE 尚未確認 combat_exp／potential 正式 API，因此安全閘門保持 BLOCKED。 */
#include <command.h>
inherit F_CLEAN_UP;
private void create(){seteuid(getuid());}
int main(object me,string arg){return notify_fail("kexp 目前 BLOCKED：ES2M SOURCE 尚未確認 combat_exp／potential 正式 API，未寫入人物資料。\n");}
int help(object me){write("格式：kexp <玩家帳號> exp|potential add|set <數值>\n目前 BLOCKED，待 SOURCE API 證據確認後啟用。\n");return 1;}
