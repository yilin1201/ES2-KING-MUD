#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"
#define KING_MARTIAL_D "/adm/daemons/kingmartiald"

private void create() { seteuid(getuid()); }

int main(object me, string arg)
{
    SECURED_ADMIN_COMMAND;

    if (!KING_D->authorized(me))
        return notify_fail("只有 ES2-KING Owner 帳號可以進入此境。\n");

    // KING 創世神基礎配置：八項 Original 屬性全部固定 99。
    if (!KING_D->apply_creator_profile(me))
        return notify_fail("KING 創世神屬性配置失敗，未進入天神殿。\n");

    // KING 冷梅莊武學：玩家技能遵守 Original F_SKILL 200 級上限。
    // 梅寒霜 300 僅為 Arena NPC local override，不套用到玩家全域規則。
    if (!KING_MARTIAL_D->set_cold_plum(me, 200))
        return notify_fail("KING 冷梅莊武學配置失敗，未進入天神殿。\n");

    if (!me->move("/d/king/wuji_realm"))
        return notify_fail("無法進入天神殿・無極之境。\n");

    write("你跨越凡塵界限，進入天神殿・無極之境。\n");
    write("KING 八項屬性已配置為 99；寒梅心法、明鏡止水、冷梅劍法與傲梅暗劍訣已就緒。\n");
    return 1;
}

int help(object me)
{
    write("指令格式：kingrealm\n唯一 KING Owner 進入天神殿・無極之境，並套用 KING 99 屬性與冷梅莊武學配置。\n");
    return 1;
}
