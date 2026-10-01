#include <command.h>
inherit F_CLEAN_UP;

// mring／KING 神戒 V2 快捷收回，沿用 seal 的原始裝備卸除與權限驗證。
int main(object me, string arg)
{
    return call_other("/cmds/adm/seal", "main", me, "omega");
}

int help(object me)
{
    write("指令格式：mring\n將神聖Ω七件神甲完整收回神之戒。\n");
    return 1;
}
