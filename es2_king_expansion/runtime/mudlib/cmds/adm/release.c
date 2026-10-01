#include <command.h>
inherit F_CLEAN_UP;

// release omega／正式解封指令；與 kring 共用唯一實作，避免兩套著裝規則分歧。
int main(object me, string arg)
{
    if (arg != "omega")
        return notify_fail("解封指令：release omega\n");
    return call_other("/cmds/adm/kring", "main", me, 0);
}

int help(object me)
{
    write("指令格式：release omega\n\n持有神之戒時，解封並自動穿戴超級Ω神聖衣七件套。快捷指令：kring。\n");
    return 1;
}
