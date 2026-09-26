// /d/arena/npc/mei_hanshuang.c
// ES2-KING Expansion Arena NPC：天涯折梅「傲雪凌霜」梅寒霜。
// 寒梅心法、明鏡止水、冷梅劍法五式與傲梅暗劍訣依既有 Evidence 接入 Original Combat；未知倍率／續航公式維持 UNKNOWN。

#include <ansi.h>
#include <npc.h>

inherit F_FIGHTER;

string *arena_300_skills = ({
    "hainmay force", "advance_lunmay", "lunmay", "mayin", "seven",
    "force", "sword", "parry", "dodge", "unarmed"
});

void activate_mirror_state()
{
    if (!is_fighting() || query_temp("cold_plum/mirror_state")) return;

    set_temp("cold_plum/mirror_state", 1);
    set_temp("cold_plum/mirror_index", 0);
    // Gameplay Evidence 校正：明鏡止水整段（含【】與名稱）維持白色。
    message_vision(HIW
        "\n$N心摒若水，眼明如鏡，竟漸入「【明  鏡  止  水】」之境界！\n"
        "$N架開對手的攻擊，順勢舞出二道寒冷的劍氣直指對手週身要害！\n\n" NOR, this_object());
}

/*
 * Original ES2 F_SKILL 將 set_skill/query_skill 的一般上限鎖在 200。
 * 使用者指定此 Arena 測試化身為 Skills 300；因此只對梅寒霜本人做 Expansion-local
 * effective level override，不修改全域 F_SKILL，也不改玩家、其他 NPC 或 Original 規則。
 */
varargs int query_skill(string skill, int raw)
{
    int value;

    value = ::query_skill(skill, raw);
    if (member_array(skill, arena_300_skills) >= 0 && value >= 200)
        return 300;
    return value;
}

void create()
{
    object weapon;

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

    set_attr("str", 50); set_attr("cor", 50);
    set_attr("int", 50); set_attr("spi", 50);
    set_attr("cps", 50); set_attr("dex", 50);
    set_attr("con", 50); set_attr("wis", 50);

    set_skill("hainmay force", 300);
    set_skill("advance_lunmay", 300);
    set_skill("lunmay", 300);
    set_skill("mayin", 300);
    set_skill("seven", 300);
    set_skill("force", 300);
    set_skill("sword", 300);
    set_skill("parry", 300);
    set_skill("dodge", 300);
    set_skill("unarmed", 300);

    // Expansion skill 不在 /daemon/skill 預設路徑；先載入並向 Original DAEMON_D 登記。
    // 之後 Combat 仍走 Original attack() -> weapon->attack_with() -> SKILL_D("lunmay")。
    load_object("/d/arena/skill/lunmay");
    map_skill("sword", "lunmay");

    // 正式武學鏈：寒梅心法 → 明鏡止水 → 冷梅劍法五式 → 傲梅暗劍訣・傲雪藏鋒・逆折寒梅。
    // 冷梅劍法五式：梅二方劍、梅四方劍、梅八方劍、愛霜恨雪、寒霜三千里。
    // advance_lunmay 為既有 Evidence skill id；進階殺招的 Combat 演出由 lunmay daemon 串接。
    // 明鏡止水為高階寒梅心法進階戰鬥境界；NPC 開戰後自動進入。
    // 續航提升的具體恢復量/週期仍無 Evidence，本輪不補造數值。
    set("chat_chance_combat", 100);
    set("chat_msg_combat", ({ (: activate_mirror_state :) }));

    set("arena_test_npc", 1);
    set("es2_king_expansion", 1);
    set("mirror_mind/sustain_formula", "UNKNOWN");

    /*
     * Playability Boundary／可玩性邊界：
     * 梅寒霜是演武界實戰 NPC，因此允許正常 Original Combat 被擊敗。
     * 不在 NPC 端加入無敵、回血、免疫或未知數值；敗北保護只由演武界既有
     * humanoid HP exhausted boundary 處理「玩家」的死亡路徑。
     */

    setup();

    // setup() 可能套用 Race/Class 初始值；Arena 規格要求八屬性精確 50，故再次鎖定。
    set_attr("str", 50); set_attr("cor", 50);
    set_attr("int", 50); set_attr("spi", 50);
    set_attr("cps", 50); set_attr("dex", 50);
    set_attr("con", 50); set_attr("wis", 50);

    weapon = carry_object("/d/arena/obj/charred_plum_branch");
    if (objectp(weapon)) weapon->wield("sword");
}
