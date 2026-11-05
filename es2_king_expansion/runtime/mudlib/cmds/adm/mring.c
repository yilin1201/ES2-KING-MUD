#include <command.h>
// mring 直接繼承正式 seal 流程，避免透過 call_other 轉呼叫時權限／物件解析差異。
// 沿用 KING 授權、七件卸裝、三狀態驗證及神戒回收。
inherit "/cmds/adm/seal";

int main(object me, string arg)
{
    return ::main(me, "omega");
}

int help(object me)
{
    write("指令格式：mring\n將超級Ω神聖衣七件完整卸下並收回神之戒。\n");
    return 1;
}
