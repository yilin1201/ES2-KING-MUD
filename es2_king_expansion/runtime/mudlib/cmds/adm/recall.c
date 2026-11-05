#include <command.h>
inherit F_CLEAN_UP;

// V2 正式收回指令：沿用 seal omega 的授權、卸裝與狀態清除驗證。
int main(object me, string arg)
{
    if (arg != "omega")
        return notify_fail("收回指令：recall omega\n");
    return call_other("/cmds/adm/seal", "main", me, "omega");
}

int help(object me)
{
    write("指令格式：recall omega\n\n將超級Ω神聖衣七件完整收回神之戒。舊版 seal omega 仍可使用。\n");
    return 1;
}
