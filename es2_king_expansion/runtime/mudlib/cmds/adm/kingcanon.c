#include <command.h>
inherit F_CLEAN_UP;
#define KING_CANON_D "/adm/daemons/kingcanon_d"
private void create() { seteuid(getuid()); }

int main(object me, string arg)
{
    string name, raw; int rank;
    SECURED_ADMIN_COMMAND;
    if (!arg || sscanf(arg, "%s %s", name, raw) != 2 || sscanf(raw, "%d", rank) != 1)
        return notify_fail("格式：kingcanon huntian 1..10 | rulai 1..11 | turn 1..4\n");
    if (name == "huntian" && KING_CANON_D->set_huntian(me, rank)) {
        write(sprintf("渾天寶鑑 第%d層：%s\n", rank, me->query("es2_king/huntian_name"))); return 1;
    }
    if (name == "rulai" && KING_CANON_D->set_rulai(me, rank)) {
        write(sprintf("如來神掌 第%d式：%s／佛兵：%s\n", rank, me->query("es2_king/rulai_name"), me->query("es2_king/rulai_weapon"))); return 1;
    }
    if (name == "turn" && KING_CANON_D->set_turn(me, rank)) {
        write("神輪四轉：" + me->query("es2_king/rulai_turn") + "（Expansion Canon）\n"); return 1;
    }
    return notify_fail("超出既定 Canon 範圍，設定遭拒。\n");
}
