// /d/arena/npc/mei_hanshuang.c
// ES2-KING Expansion Arena Test NPC／演武界冷梅系測試人物。
// 文學形象參考使用者提供的 Gemini 草稿；能力、Skill 實作依 ES2 原生 API。
// 未有 Original Evidence 的被動、倍率、明鏡止水完整機制不實作。

#include <ansi.h>
#include <npc.h>

inherit F_VILLAGER;

void create()
{
    set_name("梅寒霜", ({ "mei hanshuang", "mei", "hanshuang" }));
    set("title", HIW "天涯折梅" NOR);
    set("nickname", HIC "傲雪凌霜" NOR);

    set_race("human");
    set_class("fighter");
    set_level(99);
    set("age", 68);
    set("gender", "male");

    set("long",
        "他身著一襲洗得泛青的粗麻單衣，身形清逸，墨髮微挽，幾綹霜白垂落耳側。\n"
        "面容清雋如萬古寒潭，眼底無悲無喜，唯有看盡天涯風雪後的曠達與疏離。\n"
        "腰間懸著一隻泛黃的古藤酒葫蘆，手中只扣著一截焦黑枯梅枝。\n"
        "此身為演武界冷梅武學測試化身；文學稱號與形象屬 ES2-KING Expansion。\n");

    // 八項能力／Eight Original ES2 attributes：依使用者指定全部 50。
    set_attr("str", 50);
    set_attr("cor", 50);
    set_attr("int", 50);
    set_attr("spi", 50);
    set_attr("cps", 50);
    set_attr("dex", 50);
    set_attr("con", 50);
    set_attr("wis", 50);

    // 已有 Evidence 的冷梅系 Skill 名稱；本 Arena 測試化身統一 Lv.300。
    set_skill("hainmay force", 300);
    set_skill("advance_lunmay", 300);
    set_skill("lunmay", 300);
    set_skill("mayin", 300);
    set_skill("seven", 300);

    // Original ES2 基本 usage，讓 Combat 可實際讀取 300 級能力。
    set_skill("force", 300);
    set_skill("sword", 300);
    set_skill("parry", 300);
    set_skill("dodge", 300);
    set_skill("unarmed", 300);

    // 不建立 Gemini 草稿的 1900 級、35% 閃避、穿透、元素免疫、自動回血等未證實公式。
    set("arena_test_npc", 1);
    set("es2_king_expansion", 1);

    setup();

    // setup() 會由 Original CHAR_D / race/class 套用角色基礎設定；
    // Arena 測試規格要求八屬性精確固定 50，因此於 setup 後再次鎖定。
    set_attr("str", 50);
    set_attr("cor", 50);
    set_attr("int", 50);
    set_attr("spi", 50);
    set_attr("cps", 50);
    set_attr("dex", 50);
    set_attr("con", 50);
    set_attr("wis", 50);
}
