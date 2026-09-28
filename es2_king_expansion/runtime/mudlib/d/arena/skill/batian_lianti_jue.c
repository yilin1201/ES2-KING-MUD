// ES2-KING Project Canon：霸天煉體訣正式 parry Skill Daemon。
// M28 的兆／極、不滅金身與 150% Canon 不轉換成未經證實的 Combat 倍率。
#include <ansi.h>
inherit SKILL;

private void create()
{
    seteuid(getuid());
    DAEMON_D->register_skill_daemon("batian lianti jue");
    setup();
}

int valid_enable(string usage) { return usage == "parry"; }

// Original Combat 的 parry_using 正式入口；現階段不虛構額外拆招卸力數值。
int parry_using(object me, int ability, int strength, object from)
{
    // Project Canon：第一次觸發拆招即視為本場戰鬥的不滅金身開場；只演出，不虛構減傷倍率。
    if (!me->query_temp("es2_king/batian/immortal_intro")) {
        message_vision(
            HIW "面對漫天殺機，$N神色不起波瀾，只信步前踏半步。\n"
            HIW "體內「" HIY "霸天煉體訣" HIW "」神紋流轉，周身散發著萬法不侵的沉雄氣度。\n"
            HIW "待得金芒驟聚，「" HIY "不滅金身" HIW "」自然流轉，泛起璀璨耀目的暗金琉璃神華。\n" NOR,
            me);
        me->set_temp("es2_king/batian/immortal_intro", 1);
    }
    return 0;
}
