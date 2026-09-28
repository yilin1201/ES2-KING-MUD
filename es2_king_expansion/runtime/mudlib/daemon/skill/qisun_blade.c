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

// 每層 -1 與額外精／神消耗同屬 Expansion Gameplay Balance Parameter；
// 它們讓 Canon 效果可在既有 Combat Runtime 生效，但不宣稱為 Original 數值。
private int balance_penalty = 1;

private mapping aliases = ([
    "leiting" : "sunpi", "aotianmo" : "sunrou", "tougu" : "sunjin",
    "xiaoku" : "sungu", "wuchang" : "sunmai", "juexi" : "sunqi",
    "destroy" : "qisun",
]);

private mapping form_names = ([
    "sunpi" : "雷霆震不還", "sunrou" : "傲笑傲天魔", "sunjin" : "寒霜透骨",
    "sungu" : "笑哭不得也", "sunmai" : "哭笑無常刀", "sunqi" : "大邪絕息斬",
    "qisun" : "七損合一",
]);

private mapping form_damage_names = ([
    "sunpi" : "損皮", "sunrou" : "損肉", "sunjin" : "損筋",
    "sungu" : "損骨", "sunmai" : "損脈", "sunqi" : "損氣",
    "qisun" : "命魂俱滅",
]);

private mapping form_ordinals = ([
    "sunpi" : "第一損", "sunrou" : "第二損", "sunjin" : "第三損",
    "sungu" : "第四損", "sunmai" : "第五損", "sunqi" : "第六損",
    "qisun" : "第七損",
]);

// 第一張定稿配色：外框與招式名稱亮綠；「損」部位／終式結果亮紅；右框切回亮綠。
private string colored_form_name(string form)
{
    return form_ordinals[form] + "：" + HIG + "【" + form_names[form] + "・"
        + HIR + form_damage_names[form] + HIG + "】" + NOR;
}

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
    DAEMON_D->register_skill_daemon("qisun_blade");
    setup();
}

int valid_enable(string usage)
{
    return usage == "blade" || usage == "parry";
}

// 一般 Combat 也必須能看見已裝備的大邪七損刀，而非只有 perform 才有招式演出。
void attack_using(object me, object opponent, object weapon)
{
    mapping action;
    if (!opponent) return;
    // KING 防禦開場由實際攻擊入口觸發，避免依賴 parry daemon 是否收到 attack hook。
    if (me->skill_mapped("parry") == "batian lianti jue")
        call_other("/d/arena/skill/batian_lianti_jue", "show_immortal_intro", me);
    string *forms = ({ "sunpi", "sunrou", "sunjin", "sungu", "sunmai", "sunqi", "qisun" });
    string form;
    int index = random(sizeof(forms));
    form = forms[index];
    action = ([ "name":form_names[form],
        "action":HIW "$N使出" + colored_form_name(form) + HIW "，手中$w邪勢暴起，森寒刀煞直取$n的$l！" NOR,
        "attack":0, "force":0, "defense":0, "damage_type":"割傷" ]);
    COMBAT_D->fight(me, opponent, "blade", action, weapon);
}

private string normalize_form(string form)
{
    return stringp(aliases[form]) ? aliases[form] : form;
}

private int daxie_ready(object actor)
{
    return actor->query_skill("qisun_blade", 1) > 0
        && actor->skill_mapped("blade") == "qisun_blade";
}

private int kuxiao_ready(object actor)
{
    // KING 主內功依既定 Canon 維持易筋經；哭笑門心法是大邪金身的學習相依，
    // 不強迫覆蓋 force mapping，避免 set_daxie() 與 KING 主內功互相衝突。
    return actor->query_skill("kuxiao force", 1) > 0;
}

// 大邪金身只是一個依附哭笑門心法的狀態技，不是獨立內功。
// 反震率、減傷率與持續時間仍為 UNKNOWN，因此 Runtime 不虛構這些效果。
private int activate_jinshen(object actor)
{
    if (!kuxiao_ready(actor))
        return notify_fail("大邪金身必須先學會並啟用哭笑門心法。\n");

    // Toggle Off／切換關閉：同一個既有 perform 指令即可安全結束狀態，
    // 不需要另建平行狀態管理指令，也不虛構持續時間。
    if (actor->query("es2_king/daxie_jinshen")) {
        actor->delete("es2_king/daxie_jinshen");
        message_vision(HIG "$N收斂大邪魔元，結束「大邪金身」狀態。\n" NOR, actor);
        return 1;
    }

    actor->set("es2_king/daxie_jinshen", 1);
    message_vision(HIG "$N運起哭笑門心法，大邪魔元凝聚成「大邪金身」狀態。\n" NOR,
        actor);
    tell_object(actor,
        "大邪金身已啟動；反震、減傷與持續時間仍為 UNKNOWN，未套用推測數值。\n");
    return 1;
}

private void add_qisun_state(object actor, object target, string form, int damage)
{
    string path;

    path = "es2_king/daxie_qisun/" + form;
    if (!target->query_temp(path)) {
        target->set_temp(path, 1);
        target->add_temp("es2_king/daxie_qisun/stacks", 1);
        switch (form) {
        case "sunpi":
            target->add_temp("apply/armor", -balance_penalty);
            break;
        case "sunrou":
            target->add_temp("apply/move", -balance_penalty);
            break;
        case "sunjin":
            target->start_busy(2);
            break;
        case "sungu":
            target->add_temp("apply/defense", -balance_penalty);
            break;
        case "sunmai":
            target->consume_stat("sen", damage, actor);
            break;
        case "sunqi":
            target->consume_stat("gin", damage, actor);
            target->set_temp("es2_king/daxie_qisun/block_perform", 1);
            break;
        }
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
    // 引爆時解除本套七損施加的暫時 Combat modifier，不碰目標原有加成。
    target->add_temp("apply/armor", balance_penalty);
    target->add_temp("apply/move", balance_penalty);
    target->add_temp("apply/defense", balance_penalty);
    target->delete_temp("es2_king/daxie_qisun");

    // 15% 自損出自已定稿 Expansion 設計；只消耗既有 kee，不改寫 Original 公式。
    cost = actor->query_stat("kee") * 15 / 100;
    if (cost < 1) cost = 1;
    actor->consume_stat("kee", cost, actor);
    message_vision(
        "$N將前六損刀煞合一，使出" + colored_form_name("qisun")
        + "，直攻$n神魂命元！\n",
        actor, target);
    tell_object(actor, sprintf("七重狀態已引爆；造成 %d 點 Expansion 傷害，自損 %d 點氣。\n",
        damage, cost));
    return 1;
}

int perform_action(object actor, string form, object target)
{
    int damage, stacks;

    if (form == "random") {
        string *random_forms = ({ "sunpi", "sunrou", "sunjin", "sungu", "sunmai", "sunqi", "qisun" });
        form = random_forms[random(sizeof(random_forms))];
        // 第七損保留既有六層前置條件；未滿六層時改由前六損隨機，避免 random perform 變成無效攻擊。
        if (form == "qisun" && (!objectp(target) || target->query_temp("es2_king/daxie_qisun/stacks") < 6))
            form = random_forms[random(6)];
    }
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
    add_qisun_state(actor, target, form, damage);
    stacks = target->query_temp("es2_king/daxie_qisun/stacks");

    message_vision(HIW "$N使出" + colored_form_name(form)
        + HIW "，大邪刀煞侵入$n命脈！\n" NOR,
        actor, target);
    tell_object(actor, sprintf("效果：%s；傷害=%d；七損累積=%d/6。\n",
        form_effects[form], damage, stacks));
    return 1;
}
