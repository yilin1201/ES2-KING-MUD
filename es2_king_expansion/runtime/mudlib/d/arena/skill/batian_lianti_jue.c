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

// Combat lifecycle guard／戰鬥生命週期旗標：同一場只演出一次；
// Original Combat 結束後清除，讓下一場戰鬥仍能正常顯示開場。
void reset_immortal_intro_after_combat(object me)
{
    if (!objectp(me)) return;
    if (me->is_fighting()) {
        call_out("reset_immortal_intro_after_combat", 1, me);
        return;
    }
    me->delete_temp("es2_king/batian/immortal_intro");
}

private void display_immortal_intro(object me)
{
    if (me->query_temp("es2_king/batian/immortal_intro")) return;

    message_vision(
        HIW "面對漫天殺機，$N神色不起波瀾，只信步前踏半步。\n"
        HIW "體內「" HIY "霸天煉體訣" HIW "」神紋流轉，周身散發著萬法不侵的沉雄氣度。\n"
        HIW "待得金芒驟聚，「" HIY "不滅金身" HIW "」自然流轉，泛起璀璨耀目的暗金琉璃神華。\n" NOR,
        me);
    me->set_temp("es2_king/batian/immortal_intro", 1);
    call_out("reset_immortal_intro_after_combat", 1, me);
}

// Combat attack hook：KING 一進入實際交戰便顯示一次不滅金身開場，不再等待隨機 parry 事件。
void show_immortal_intro(object me)
{
    display_immortal_intro(me);
}

// Original Combat 的 parry_using 正式入口；現階段不虛構額外拆招卸力數值。
int parry_using(object me, int ability, int strength, object from)
{
    // Project Canon：第一次觸發拆招即視為本場戰鬥的不滅金身開場；只演出，不虛構減傷倍率。
    display_immortal_intro(me);
    return 0;
}
