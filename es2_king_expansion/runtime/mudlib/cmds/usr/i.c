/* ES2-KING：i 固定對應 Original inventory，不依賴玩家是否設定 alias。 */
#include <command.h>
inherit F_CLEAN_UP;

int main(object me, string arg)
{
    // 由 Original inventory 處理權限、攜帶物與 KING Omega 裝備排序。
    // 只委派，不另建物品清單，以免 i 與 inventory 顯示不一致。
    return (int)call_other("/cmds/usr/inventory", "main", me, arg);
}

int help(object me)
{
    return (int)call_other("/cmds/usr/inventory", "help", me);
}
