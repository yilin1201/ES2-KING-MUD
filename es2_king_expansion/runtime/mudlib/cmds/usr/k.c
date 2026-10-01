#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create(){seteuid(getuid());}
private int show(object me){int lv=KADMIN_D->level(me);write("==================================================\n              ES2-KING 管理指令\n==================================================\n");if(lv<=0){write("此說明僅供授權管理人員使用。\n一般玩家：k = kill\n請輸入 help 查詢一般遊戲指令。\n");return 1;}if(lv>=99)write("\n【KING 專屬】\n khome       前往天神殿・無極之境\n kcreate     KING 登錄物件建立\n kcanon      KING Canon 設定\n kmartial    KING 武學設定\n kring       神之戒解封超級Ω神聖衣\n kadmin      巫師／大巫師權限管理\n");write("\n【地圖／房間調查】\n kroom       查看目前房間資訊\n kexit       查看出口／失效出口\n kmap        查看目前地圖連結\n kact        特殊 Trigger 調查提示\n\n【NPC／物件調查】\n kwhere      查詢角色／NPC位置\n knpc        查看目前房間 NPC\n kitem       查看目前房間物品\n");if(lv>=2)write("\n【大巫師】\n kgoto       前往指定 Room\n kobj        查看 Runtime Object\n ktrace      追蹤直接 Room 連結\n kbroken     查看失效出口\n kmiss       查看 Missing Room\n");write("\n詳細說明：help <指令>，例如 help kexit\n單獨輸入 k 仍為 Original kill 簡寫。\n");return 1;}
int main(object me,string arg){return show(me);}
int help(object me){return show(me);}

