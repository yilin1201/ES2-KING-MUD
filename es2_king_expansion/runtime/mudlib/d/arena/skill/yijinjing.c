// ES2-KING Project Canon：易筋經正式 force Skill Daemon。
// M28 只證實武學定位與境界；未知傷害、回復、消耗與倍率不在此補造。
#include <ansi.h>
inherit SKILL;

private void create()
{
    seteuid(getuid());
    DAEMON_D->register_skill_daemon("yijinjing");
    setup();
}

int valid_enable(string usage) { return usage == "force"; }

// KING Runtime 修復：原始徒手傷害流程由角色呼叫已映射內功的
// inflict_damage(strength, victim)。易筋經先前缺少此函式；
// Original 固定來源亦沒有 /daemon/skill/force.c 作為預設回退。
// 此處只沿用 Original 無內功時的力道轉傷害公式，不新增武學倍率。
int inflict_damage(int strength, object victim)
{
    object attacker;
    int damage, base;

    attacker = previous_object();
    if (!objectp(attacker) || !attacker->is_character()
        || !living(attacker) || !objectp(victim) || strength <= 0)
        return 0;

    base = strength / 10000;
    damage = 1 + base + (base > 0 ? random(base) : 0);
    damage += attacker->query_temp("apply/damage");
    damage -= victim->resist_damage(damage, attacker);

    if (damage <= 0) return 0;
    return victim->receive_damage(damage, attacker, attacker);
}
