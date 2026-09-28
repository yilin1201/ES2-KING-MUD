// ES2-KING Expansion perform compatibility／施展招式相容層。
// 此檔只存在 Expansion Overlay，不修改 Original ES2 保存原始碼。

#include <skill.h>

inherit F_CLEAN_UP;

private string *qishang_forms = ({
    "leiting", "yaotou", "aotianmo", "yanhan", "qingtian", "xiaoku",
    "dingqiankun", "tianku",
});

private string *daxie_forms = ({
    "sunpi", "leiting", "sunrou", "aotianmo", "sunjin", "tougu",
    "sungu", "xiaoku", "sunmai", "wuchang", "sunqi", "juexi",
    "qisun", "destroy", "jinshen", "daxie-jinshen",
});

private object daxie_target(object me, string target_id)
{
    object *enemies;
    object target;

    if (stringp(target_id) && strlen(target_id))
        return present(target_id, environment(me));
    target = me->query_opponent();
    if (objectp(target)) return target;
    enemies = me->query_enemy() - ({ 0 });
    return sizeof(enemies) ? enemies[0] : 0;
}

int main(object me, string arg)
{
    object target, weapon;
    string act, martial_skill, target_id, trg;

    if (me->is_busy()) return notify_fail("你現在沒有空﹗\n");
    if (me->query_temp("es2_king/daxie_qisun/block_perform"))
        return notify_fail("大邪絕息斬封住了你的氣海，暫時無法施展絕招。\n");
    // ES2-KING Random Perform／目前七損刀、七傷杖 perform 先採隨機出招。
    if (!arg) {
        if (environment(me)->query("no_fight")) return notify_fail("這裡不准戰鬥。\n");
        if (!me->is_fighting()) return notify_fail("你必須在戰鬥中才能使用絕招！\n");
        if (objectp(me->query_temp("weapon/blade")) && me->skill_mapped("blade") == "qisun_blade") {
            target = daxie_target(me, 0);
            if (!objectp(target)) return notify_fail("你目前沒有可攻擊的目標。\n");
            return SKILL_D("qisun_blade")->perform_action(me, "random", target);
        }
        if ((objectp(me->query_temp("weapon/staff")) || objectp(me->query_temp("weapon/twohanded staff")))
        && (me->skill_mapped("staff") == "qishang_staff" || me->skill_mapped("twohanded staff") == "qishang_staff")) {
            target = daxie_target(me, 0);
            if (!objectp(target)) return notify_fail("你目前沒有可攻擊的目標。\n");
            return SKILL_D("qishang_staff")->perform_action(me, "random", target);
        }
        return notify_fail("指令格式﹕perform <技能:絕招> [on <目標>]\n");
    }

    // Canon Short Form／正式短指令：perform sunpi 或 perform sunpi on target。
    // 大邪金身不需要戰鬥目標；其餘七損式仍沿用既有戰鬥與武器狀態。
    if (sscanf(arg, "%s on %s", act, target_id) != 2) act = arg;
    // 七傷杖與七損刀共用 leiting／aotianmo／xiaoku 等短 alias；
    // 必須依目前實際裝備與 mapping 分流，否則杖法會被誤送進七損刀 daemon。
    if (member_array(act, qishang_forms) >= 0
    &&  (objectp(me->query_temp("weapon/staff")) || objectp(me->query_temp("weapon/twohanded staff")))
    &&  (me->skill_mapped("staff") == "qishang_staff"
      || me->skill_mapped("twohanded staff") == "qishang_staff")) {
        if (environment(me)->query("no_fight")) return notify_fail("這裡不准戰鬥。\n");
        if (!me->is_fighting()) return notify_fail("你必須在戰鬥中才能使用絕招！\n");
        target = daxie_target(me, target_id);
        if (!objectp(target)) return notify_fail("你目前沒有可攻擊的目標。\n");
        return SKILL_D("qishang_staff")->perform_action(me, act, target);
    }

    if (member_array(act, daxie_forms) >= 0) {
        if (act != "jinshen" && act != "daxie-jinshen") {
            if (environment(me)->query("no_fight")) return notify_fail("這裡不准戰鬥。\n");
            if (!me->is_fighting()) return notify_fail("你必須在戰鬥中才能使用絕招！\n");
            weapon = me->query_temp("weapon/blade");
            if (!objectp(weapon)) return notify_fail("你必須裝備刀類武器來使出大邪七損刀。\n");
            target = daxie_target(me, target_id);
        }
        return SKILL_D("qisun_blade")->perform_action(me, act, target);
    }

    // 以下保持 Original ES2 perform command 的既有行為。
    if (environment(me)->query("no_fight")) return notify_fail("這裡不准戰鬥。\n");
    if (!me->is_fighting()) return notify_fail("你必須在戰鬥中才能使用絕招！\n");
    if (sscanf(arg, "%s:%s on %s", martial_skill, act, trg) != 3
    &&  sscanf(arg, "%s:%s", martial_skill, act) != 2)
        return notify_fail("指令格式﹕perform <技能.絕招> [on <目標>]\n");
    if (trg) {
        target = present(trg, environment(me));
        if (!target) return notify_fail("你要對誰使用招式？\n");
        if (!living(target)) return notify_fail("你可以直接宰了這個昏迷不醒的傢伙，不需要用絕招。\n");
    }
    if (!me->query_temp("weapon/" + martial_skill) && martial_skill != "unarmed")
        return notify_fail("你必須裝備適當的武器來使出絕招。\n");
    notify_fail("你請先用 enable 指令選擇你要使用的技能。\n");
    if (martial_skill != me->skill_mapped(martial_skill)
    &&  me->skill_mapped(martial_skill) != 0)
        return SKILL_D(me->skill_mapped(martial_skill))->perform_action(me, act, target);
    return 0;
}

int help(object me)
{
    write("指令格式：perform <技能:絕招> [on <目標>]\n"
          "大邪七損刀亦支援：perform sunpi [on <目標>]。\n");
    return 1;
}
