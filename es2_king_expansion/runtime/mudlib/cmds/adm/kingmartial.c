#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
#define KING_MARTIAL_D "/adm/daemons/kingmartiald"
private void create() { seteuid(getuid()); }

int main(object me, string arg)
{
    string name, value;
    int level;
    SECURED_ADMIN_COMMAND;
    if (!KING_D->authorized(me))
        return notify_fail("只有 ES2-KING Owner 帳號可以使用此指令。\n");
    if (!arg || sscanf(arg, "%s %s", name, value) != 2)
        return notify_fail("格式：kingmartial yijinjing <1..300> | batian zhao|ji | daxie <1..200|status>\n");
    if (name == "yijinjing" && sscanf(value, "%d", level) == 1) {
        if (!KING_MARTIAL_D->set_yijinjing(me, level))
            return notify_fail("易筋經等級必須為 1～300。\n");
        write(sprintf("易筋經 Lv.%d／%s\n", level, me->query("es2_king/yijinjing_stage")));
        return 1;
    }
    if (name == "batian" && KING_MARTIAL_D->set_batian(me, value)) {
        write("霸天煉體訣階段：" + value + "（Expansion Canon）\n");
        return 1;
    }
    if (name == "daxie" && value == "status") {
        write(sprintf("哭笑門心法 Lv.%d／大邪七損刀 Lv.%d／大邪金身：%s\n",
            me->query_skill("kuxiao force", 1),
            me->query_skill("daxie qisun blade", 1),
            me->query("es2_king/daxie_jinshen") ? "ON" : "OFF"));
        return 1;
    }
    if (name == "daxie" && sscanf(value, "%d", level) == 1
    && KING_MARTIAL_D->set_daxie(me, level)) {
        write(sprintf("哭笑門心法 Lv.%d／大邪七損刀 Lv.%d（Expansion Canon）\n",
            level, level));
        return 1;
    }
    return notify_fail("未知或未授權的 Expansion 武學設定。\n");
}
