#include <command.h>
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"

private string *omega_files = ({
    "/obj/king/omega_crown",
    "/obj/king/omega_plate",
    "/obj/king/omega_wings",
    "/obj/king/omega_girth",
    "/obj/king/omega_gloves",
    "/obj/king/omega_leggings",
    "/obj/king/omega_boots",
});

private string *omega_ids = ({
    "omega crown", "omega plate", "omega wings", "omega girth",
    "omega gloves", "omega leggings", "omega boots",
});

private void create(){ seteuid(getuid()); }

int main(object me, string arg)
{
    object ring, item;
    int i;

    if (!KING_D->authorized(me))
        return notify_fail("只有 KING 能喚醒神之戒。\n");

    ring = present("god ring", me);
    if (!objectp(ring))
        return notify_fail("神之戒不在你的物品欄中，無法解封超級Ω神聖衣。\n");

    write("\n你小宇宙轟然暴燃，戰意直灌指端，指間的「神之戒」驟然爆發出一道直衝九霄的璀璨星柱！\n\n");
    write("【神物共鳴】：神之戒內部時空矩陣轟然解鎖，封印於神界的至高力量徹底甦醒！\n");
    write("億萬道純金與銀白星輝於頭頂虛空旋轉、坍縮，黃道十二星圖在天地間展開！\n\n");
    write(">>> 聖衣解封！神聖著裝（Equip Omega Cloth）<<<\n\n");

    for (i = 0; i < sizeof(omega_files); i++) {
        item = present(omega_ids[i], me);
        if (!objectp(item)) {
            item = new(omega_files[i]);
            if (!objectp(item) || !item->move(me)) {
                if (objectp(item)) destruct(item);
                return notify_fail("Ω神聖衣解封失敗：" + omega_ids[i] + " 無法顯化。\n");
            }
        }
        if (!item->query("equipped") && !item->wear())
            return notify_fail("Ω神聖衣著裝失敗：" + item->name() + " 無法穿戴。\n");
    }

    me->set_temp("es2_king/omega/god_blessing", 1);
    me->set_temp("es2_king/omega/absolute_body", 1);
    me->set_temp("es2_king/omega/lightspeed_realm", 1);

    write("【頭部】：超級Ω神聖衣。頭盔 凌空合攏，天馬光羽護住雙鬢！\n");
    write("【身體】：超級Ω神聖衣。盔甲 鏗鏘覆體，黃金與青銅神紋封鎖胸腹要害！\n");
    write("【背部】：超級Ω神聖衣。披風光翼 轟然舒展，十二道燦金羽翼光耀全場！\n");
    write("【腰部】：超級Ω神聖衣。腰帶 金鎖扣合，Ω神印鎖定丹田氣海！\n");
    write("【雙手】：超級Ω神聖衣。手套 順臂延伸，拳芒引動億萬星辰低鳴！\n");
    write("【雙腿】：超級Ω神聖衣。腳套 緊密鎖合，流雲神紋護住膝脛！\n");
    write("【雙腳】：超級Ω神聖衣。鞋子 沉沉踏落，足下激盪金色光漣！\n\n");
    write("剎那間，宏大小宇宙（Macro Cosmo）匯聚於你一身，周身金光琉璃神華流轉！\n");
    write("（系統提示：你成功裝備「超級Ω神聖衣」全套七件防具；裝備提供合計 armor +300，並標記「神之庇護」、「絕對霸體」、「光速境界」。）\n");
    return 1;
}

int help(object me)
{
    write("指令格式：kring\nKING 持有神之戒時，解封並自動穿戴超級Ω神聖衣七件套。\n");
    return 1;
}
