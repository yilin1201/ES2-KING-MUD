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

    write(HIY "\n你小宇宙轟然暴燃，戰意直灌指端，指間的「神之戒」驟然爆發出一道直衝九霄的璀璨星柱！\n\n" NOR);
    write(HIW "【神物共鳴】：神之戒內部時空矩陣轟然解鎖，封印於神界的至高力量徹底甦醒！\n" NOR);
    write("億萬道純金與銀白的灼熱星輝自指尖暴湧而出，於頭頂虛空瘋狂旋轉、坍縮！\n");
    write("轟然間，一尊巍峨聳立、環繞著黃道十二星圖的金色戰神法相赫然顯化於天地之間！\n\n");
    write("戰神法相雙眸如烈陽般熾烈燃燒，雙臂凌空虛合，身軀驟然崩解為漫天呼嘯的神聖流星，\n");
    write("帶著撕裂維度的狂暴音爆，精準地朝你周身各大要害鏗鏘鎖合——\n\n");
    write(HIY ">>> 聖衣解封！神聖著裝（Equip Omega Cloth）<<<\n\n" NOR);
    write("【頭部】：超級Ω神聖衣。頭盔 凌空合攏，天馬光羽護住雙鬢，眉心寶石神華大盛！\n");
    write("          （群星意志護佑靈台，諸邪退避，心智不滅！）\n");
    write("【身體】：超級Ω神聖衣。盔甲 鏗鏘覆體，黃金與青銅神紋交織，將胸腹要害牢牢封鎖！\n");
    write("          （神血淬煉不滅神甲，因果難傷，絕對護體！）\n");
    write("【背部】：超級Ω神聖衣。披風光翼 轟然舒展，十二道燦金羽翼撕裂虛空，光耀全場！\n");
    write("          （十二重黃金光羽激盪，瞬息撕裂次元，身入光速！）\n");
    write("【腰部】：超級Ω神聖衣。腰帶 金鎖扣合，Ω神印鎖定丹田氣海，小宇宙生生不息！\n");
    write("          （星脈核心鎖定氣海，真元循環運轉，穩若泰山！）\n");
    write("【雙手】：超級Ω神聖衣。手套 順臂延伸，拳芒閃爍，引動億萬星辰低鳴！\n");
    write("          （指節星痕流轉弒神煞氣，拳壓爆綻，碎裂虛空！）\n");
    write("【雙腿】：超級Ω神聖衣。腳套 緊密鎖合，神紋如流雲般覆蓋雙足經脈！\n");
    write("          （金紋甲胄護住膝脛，防禦下盤空門，剛勁內蘊！）\n");
    write("【雙腳】：超級Ω神聖衣。鞋子 沉沉踏落，神火不熄，足下大地激盪開圈圈金色光漣！\n");
    write("          （踏星破空足不沾塵，無視凶險地形，神步無疆！）\n\n");
    write(HIY "剎那間，全宇宙聖鬥士的信念與宏大小宇宙（Macro Cosmo）盡數融匯於你一人之身！\n" NOR);
    write(HIY "你傲立於天地之間，周身金光琉璃神華流轉，氣勢睥睨諸神，萬法莫侵！\n\n" NOR);
    write(HIW "（系統提示：你成功裝備了「超級Ω神聖衣」全套防具，合計 armor +300，並獲得狀態「神之庇護」、「絕對霸體」與「光速境界」！）\n" NOR);
    message("vision", HIY + me->name() + "的小宇宙轟然暴燃，十二重燦金光翼照耀天地！\n" NOR,
        environment(me), me);
    return 1;
}

int help(object me)
{
    write("指令格式：kring\n正式解封指令：release omega\n\nKING 持有神之戒時，解封並自動穿戴超級Ω神聖衣七件套。\n");
    return 1;
}
