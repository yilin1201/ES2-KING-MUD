#pragma save_binary

#include <ansi.h>

inherit SKILL;

// ES2-KING Gameplay Balance Parameters／遊戲平衡參數：
// Original 史料未提供各式精確傷害；以下只供 Expansion Runtime 可玩性，
// 不得登錄為 Original Evidence。數值刻意維持低量，讓七損狀態可完整累積。
private mapping balance_damage = ([
    "sunpi" : 2, "sunrou" : 3, "sunjin" : 4,
    "sungu" : 5, "sunmai" : 6, "sunqi" : 7, "qisun" : 12,
]);

private mapping aliases = ([
    "leiting" : "sunpi", "aotianmo" : "sunrou", "tougu" : "sunjin",
    "xiaoku" : "sungu", "wuchang" : "sunmai", "juexi" : "sunqi",
    "destroy" : "qisun",
]);

private mapping form_names = ([
    "sunpi" : "損皮・雷霆震不還",
    "sunrou" : "損肉・傲笑傲天魔",
    "sunjin" : "損筋・寒霜透骨",
    "sungu" : "損骨・笑哭不得也",
    "sunmai" : "損脈・哭笑無常刀",
    "sunqi" : "損氣・大邪絕息斬",
    "qisun" : "七損合一・命魂俱滅",
]);

private mapping form_effects = ([
    "sunpi" : "破皮碎甲／破防流血",
    "sunrou" : "爛肉化膿／體能瓦解",
    "sunjin" : "抽筋錯節／強制定身",
    "sungu" : "碎骨斷樑／重傷骨折",
    "sunmai" : "斷脈逆血／走火入魔",
    "sunqi" : "抽乾精元／破滅氣海",
    "qisun" : "七重負面引爆／自損代價",
]);

void create()
{
    seteuid(getuid());
    DAEMON_D->register_skill_daemon("daxie qisun blade");
    setup();
}

int valid_enable(string usage)
{
    return usage == "sword" || usage == "parry";
}

private string normalize_form(string form)
{
    return stringp(aliases[form]) ? aliases[form] : form;
}

private int daxie_ready(object actor)
{
    return actor->query_skill("daxie qisun blade", 1) > 0
        && actor->skill_mapped("sword") == "daxie qisun blade";
}

private int kuxiao_ready(object actor)
{
    return actor->query_skill("kuxiao force", 1) > 0
        && actor->skill_mapped("force") == "kuxiao force";
}

// 大邪金身只是一個依附哭笑門心法的狀態技，不是獨立內功。
// 反震率、減傷率與持續時間仍為 UNKNOWN，因此 Runtime 不虛構這些效果。
private int activate_jinshen(object actor)
{
    if (!kuxiao_ready(actor))
        return notify_fail("大邪金身必須先學會並啟用哭笑門心法。\n");

    actor->set("es2_king/daxie_jinshen", 1);
    message_vision(HIG "$N運起哭笑門心法，大邪魔元凝聚成「大邪金身」狀態。\n" NOR,
        actor);
    tell_object(actor,
        "大邪金身已啟動；反震、減傷與持續時間仍為 UNKNOWN，未套用推測數值。\n");
    return 1;
}

private void add_qisun_state(object target, string form)
{
    string path;

    path = "es2_king/daxie_qisun/" + form;
    if (!target->query_temp(path)) {
        target->set_temp(path, 1);
        target->add_temp("es2_king/daxie_qisun/stacks", 1);
    }
}

private int explode_qisun(object actor, object target)
{
    int cost, damage, stacks;

    stacks = target->query_temp("es2_king/daxie_qisun/stacks");
    if (stacks < 6)
        return notify_fail("前六損尚未完整累積，無法施展七損合一。\n");

    damage = balance_damage["qisun"] + stacks;
    target->receive_damage(damage, actor, actor);
    target->delete_temp("es2_king/daxie_qisun");

    // 15% 自損出自已定稿 Expansion 設計；只消耗既有 kee，不改寫 Original 公式。
    cost = actor->query_stat("kee") * 15 / 100;
    if (cost < 1) cost = 1;
    actor->consume_stat("kee", cost, actor);
    message_vision(HIR
        "$N將前六損刀煞合一，使出「七損合一・命魂俱滅」直攻$n神魂命元！\n" NOR,
        actor, target);
    tell_object(actor, sprintf("七重狀態已引爆；造成 %d 點 Expansion 傷害，自損 %d 點氣。\n",
        damage, cost));
    return 1;
}

int perform_action(object actor, string form, object target)
{
    int damage, stacks;

    form = normalize_form(form);
    if (form == "jinshen" || form == "daxie-jinshen")
        return activate_jinshen(actor);

    if (!daxie_ready(actor))
        return notify_fail("你尚未學會並啟用大邪七損刀。\n");
    if (!objectp(target) || !living(target))
        return notify_fail("大邪七損刀需要一個仍可戰鬥的目標。\n");
    if (undefinedp(form_names[form]))
        return notify_fail("大邪七損刀沒有這一式。\n");
    if (form == "qisun")
        return explode_qisun(actor, target);

    damage = balance_damage[form];
    target->receive_damage(damage, actor, actor);
    add_qisun_state(target, form);
    stacks = target->query_temp("es2_king/daxie_qisun/stacks");

    // 寒霜透骨的 2 回合 Busy 屬已定稿 Expansion 設計範圍。
    if (form == "sunjin") target->start_busy(2);

    message_vision(HIM "$N使出「" + form_names[form] + "」，大邪刀煞侵入$n命脈！\n" NOR,
        actor, target);
    tell_object(actor, sprintf("效果：%s；傷害=%d；七損累積=%d/6。\n",
        form_effects[form], damage, stacks));
    return 1;
}

