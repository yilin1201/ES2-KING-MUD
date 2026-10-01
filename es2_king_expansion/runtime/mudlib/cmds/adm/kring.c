#include <ansi.h>
#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"

private string *omega_files = ({
    "/obj/king/omega_crown", "/obj/king/omega_plate",
    "/obj/king/omega_wings", "/obj/king/omega_girth",
    "/obj/king/omega_gloves", "/obj/king/omega_leggings",
    "/obj/king/omega_boots",
});
private string *omega_ids = ({
    "omega crown", "omega plate", "omega wings", "omega girth",
    "omega gloves", "omega leggings", "omega boots",
});
private string *omega_slots = ({
    "head_eq", "armor", "neck_eq", "waist_eq",
    "hand_eq", "leg_eq", "feet_eq",
});

// Runtime Verification／實際著裝驗證：七件必須真的佔用 Original armor slot，
// 且三個既定 Ω 狀態必須由裝備 apply 機制實際掛上；不以文字訊息當成 PASS。
private int omega_equipped(object me)
{
    object item;
    int i;

    for (i = 0; i < sizeof(omega_ids); i++) {
        item = present(omega_ids[i], me);
        if (!objectp(item)
        || item->query("es2_king/omega_cloth") != 1
        || item->query("equipped") != "armor/" + omega_slots[i]
        || me->query_temp("armor/" + omega_slots[i]) != item)
            return 0;
    }

    return me->query_temp("apply/omega_god_protection") >= 1
        && me->query_temp("apply/omega_absolute_body") >= 1
        && me->query_temp("apply/omega_lightspeed_realm") >= 1;
}

private void create(){ seteuid(getuid()); }

int main(object me, string arg)
{
    object ring, item;
    int i;

    if (!KING_D->authorized(me))
        return notify_fail("只有 KING 能喚醒神之戒。\n");
    ring = present("god ring", me);
    if (!objectp(ring) || ring->query("es2_king/owner_relic") != 1)
        return notify_fail("神之戒不在你的物品欄中，無法解封超級Ω神聖衣。\n");

    // Duplicate Protection／防重複：重用物品欄中的既有聖衣，只建立缺少的部件。
    for (i = 0; i < sizeof(omega_files); i++) {
        item = present(omega_ids[i], me);
        if (!objectp(item)) {
            item = new(omega_files[i]);
            if (!objectp(item) || !item->move(me)) {
                if (objectp(item)) destruct(item);
                return notify_fail("Ω神聖衣解封失敗：" + omega_ids[i] + " 無法顯化。\n");
            }
        }
        if (item->query("es2_king/omega_cloth") != 1)
            return notify_fail("Ω神聖衣驗證失敗：發現同名但不屬於神聖衣的物件。\n");
        if (!item->query("equipped") && !item->wear())
            return notify_fail("Ω神聖衣著裝失敗：" + item->name() + " 無法穿戴。\n");
    }

    if (!omega_equipped(me))
        return notify_fail("Ω神聖衣解封失敗：七件裝備或神聖狀態未完整套用。\n");

    ring->set("es2_king/omega_sealed", 0);

    // V2 神戒演出：既有戒指若未標記版本，也採 V2；明確標記 1 保留原版。
    if (ring->query("es2_king/omega_narrative_version") != 1) {
        write(HIY "\n體內億萬細胞轟然共振，奔騰熱血燃燒至極限！\n" NOR);
        write(HIR "靈魂深處，沉眠的神級大爆炸轟然引爆！\n" NOR);
        write(HIY "你仰天長嘯，高舉「神之戒」！創世神光貫穿蒼穹！\n" NOR);
        write("八十八星座齊聲共鳴，十二黃金神宮依序點亮！\n");
        write(HIY "黃金戰神法相破空降臨，萬千星辰匯聚於你身前！\n\n" NOR);
        write(HIY "「燃燒吧！我的小宇宙！」\n" NOR);
        write(HIY "「以八十八星座之名，喚醒超越諸神的奇蹟！」\n" NOR);
        write(HIR "「神聖Ω——終極覺醒！！！」\n\n" NOR);
        write("億萬流星撕裂虛空，七道創世神光化為戰甲，鏗鏘覆體！\n\n");
        write(HIY ">>> 神聖Ω・終極解封 <<<\n" NOR);
        write(HIY "━━━━━━━━ 神聖衣・完全著裝 ━━━━━━━━\n" NOR);
        write("  ◈ 頭部 ◈  神聖Ω神盔破空扣合，額前神核綻放！\n");
        write("  ◈ 身體 ◈  神聖Ω神甲萬光交織，不滅神血護體！\n");
        write("  ◈ 背部 ◈  神聖Ω光翼轟然怒展，十二神羽裂空！\n");
        write("  ◈ 腰部 ◈  神聖Ω金鎖瞬間封合，神脈生生不息！\n");
        write("  ◈ 雙手 ◈  神聖Ω拳套緊扣雙腕，神威粉碎次元！\n");
        write("  ◈ 雙腿 ◈  神聖Ω腿甲轟然覆合，雙腿屹立如山！\n");
        write("  ◈ 雙腳 ◈  神聖Ω戰靴神焰踏落，震撼山河！\n\n");
        write(HIY ">>> 神聖Ω・完全著裝 <<<\n" NOR);
        write("八十八星座神光匯聚，十二黃金神環浮現！\n");
        write(HIY "神聖小宇宙吞沒星河，神威降世，萬界震顫！\n\n" NOR);
        write(HIW "（系統提示：你成功裝備了「超級Ω神聖衣」全套防具！）\n" NOR);
        message("vision", HIY + me->name() + "高舉神之戒，神聖Ω七大神甲化光覆體，十二黃金神環照耀天地！\n" NOR, environment(me), me);
        return 1;
    }

    // Ω 著裝演出：採用專案擁有者定稿的精簡七部位敘述；裝備及狀態驗證維持原樣。
    write(HIY "\n你小宇宙轟然暴燃，戰意直灌指端！\n" NOR);
    write(HIY "指間「神之戒」爆發出一道直衝九霄的璀璨星柱！\n\n" NOR);
    write("虛空中，黃道十二星圖環繞的金色戰神法相赫然顯化！\n");
    write("戰神雙臂虛合，身軀化作漫天流星雨鏗鏘覆體——\n\n");
    write(HIY ">>> 聖衣解封！神聖著裝 <<<\n\n" NOR);
    write("  ◈ 頭部 ◈  黃道神盔凌空合攏，眉心星核大盛！\n");
    write("  ◈ 身體 ◈  黃道盔甲鏗鏘覆體，締造絕對護體！\n");
    write("  ◈ 背部 ◈  披風光翼轟然舒展，十二金羽裂空！\n");
    write("  ◈ 腰部 ◈  神印Ω金鎖扣合，氣海生生不息！\n");
    write("  ◈ 雙手 ◈  黃道拳套順臂扣鎖，拳壓碎裂虛空！\n");
    write("  ◈ 雙腿 ◈  流雲腳套緊密咬合，下盤穩若泰山！\n");
    write("  ◈ 雙腳 ◈  踏星戰靴沉沉落地，足下金炎漫開！\n\n");
    write(HIY "宏大小宇宙（Macro Cosmo）盡數融匯於你一人之身！\n" NOR);
    write(HIY "周身金光琉璃神華流轉，氣勢睥睨諸神，萬法莫侵！\n\n" NOR);
    write(HIW "（系統提示：你成功裝備了「超級Ω神聖衣」全套防具！）\n" NOR);
    message("vision", HIY + me->name() + "的小宇宙轟然暴燃，十二重燦金光翼照耀天地！\n" NOR,
        environment(me), me);
    return 1;
}

int help(object me)
{
    write("指令格式：kring\n正式解封指令：release omega\n封印指令：seal omega\n\nKING 持有神之戒時，解封並自動穿戴超級Ω神聖衣七件套；seal omega 可將七件卸下並收回神之戒。\n");
    return 1;
}
