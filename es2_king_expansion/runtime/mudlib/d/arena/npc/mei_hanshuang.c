// /d/arena/npc/mei_hanshuang.c
// ES2-KING Expansion Arena NPC：天涯折梅「傲雪凌霜」梅寒霜。
// 寒梅心法、明鏡止水、冷梅劍法五式與傲梅暗劍訣依既有 Evidence 接入 Original Combat；未知倍率／續航公式維持 UNKNOWN。

#include <ansi.h>
#include <npc.h>

inherit F_FIGHTER;

string *arena_300_skills = ({
    "hainmay force", "advance_lunmay", "lunmay", "au-chan sword", "mayin", "seven",
    "force", "sword", "parry", "dodge", "unarmed"
});

void switch_to_aojian()
{
    if (query_temp("aojian/awakened")) return;

    set_temp("aojian/awakened", 1);
    set_temp("aojian/jianling_rounds", 0);
    set_temp("aojian/jianling_target", 4 + random(4));
    delete_temp("cold_plum/mirror_state");
    map_skill("sword", "au-chan sword");
    map_skill("parry", "au-chan sword");

    // Phase 2／30 次實際攻擊後：寒梅白青退場，台詞轉亮黃，傲劍以亮紅／金色接管戰鬥氣氛。
    message_vision(HIW
        "\n寒霜碎裂，冷梅將折。\n\n"
        "連番激鬥之下，$N的劍勢已被徹底壓制，空門大露。\n\n"
        "然就在對手殺招臨身的一瞬，$N的氣質驟然變了。\n"
        "不再是冰封天地的清冷隱忍，而是凌駕眾生的極致張狂！\n\n"
        HIC "$N周身原本清冷的寒梅氣息轟然崩碎，沉寂多年的傲岸煞氣如地火破冰般自百骸狂湧而出，衣袍無風自鼓，獵獵作響。\n\n"
        HIW "$N忽然冷笑一聲：\n"
        HIY "「三十招了……能逼我棄冷梅、出傲劍，你足以自傲。」\n\n"
        HIW "話音方落，$N撤步引劍。手中長劍陡然爆出一記宛若龍吟般的清越錚鳴！\n"
        "劍勢由柔轉極剛，原本森白的霜華，瞬間被" HIR "熾烈狂放" HIW "的" HIY "燦爛劍罡" HIW "吞噬殆盡！\n\n"
        "$N身形微側，不退反進，劍尖斜指蒼穹，一股" HIR "睥睨天下、獨領風騷" HIW "的凌厲氣魄轟然充塞全場！\n\n"
        HIY "氣浪倒捲，天地變色。\n\n"
        HIR "冷梅既凋——唯傲劍獨立！\n\n" NOR,
        this_object());
}

void activate_mirror_state()
{
    object opponent;

    if (!is_fighting()) {
        // 每場戰鬥結束後回復冷梅起手，下一場重新計算 30 次實際攻擊。
        if (query_temp("aojian/awakened")) {
            map_skill("sword", "lunmay");
            map_skill("parry", "lunmay");
        }
        delete_temp("aojian");
        delete_temp("cold_plum/mirror_state");
        delete_temp("cold_plum/mirror_index");
        return;
    }

    // 久戰第二階段：傲劍覺醒後維持主動攻擊節奏。
    // 劍領風騷不可再依賴純 1/8 運氣：每輪 Phase 2 heartbeat 累計，
    // 於 4～7 輪間隨機選定一次自動劍舞，出招後重新抽下一個間隔。
    if (query_temp("aojian/awakened")) {
        object weapon;

        opponent = query_opponent();
        if (!objectp(opponent) || environment(opponent) != environment()) return;

        add_temp("aojian/jianling_rounds", 1);
        if (!query_temp("aojian/jianling_target"))
            set_temp("aojian/jianling_target", 4 + random(4));

        if (query_temp("aojian/jianling_rounds") >= query_temp("aojian/jianling_target")) {
            weapon = query_temp("weapon/sword");
            if (!objectp(weapon)) weapon = query_temp("weapon/twohanded sword");
            if (objectp(weapon))
                "/daemon/skill/au-chan_sword"->jianling_combat_attack(this_object(), opponent, weapon);
            set_temp("aojian/jianling_rounds", 0);
            set_temp("aojian/jianling_target", 4 + random(4));
            return;
        }

        // 非劍舞輪仍由 Original attack() → mapped au-chan sword → COMBAT_D 正常出七式。
        attack(opponent);
        return;
    }

    add_temp("aojian/attack_rounds", 1);
    if (query_temp("aojian/attack_rounds") >= 30) {
        switch_to_aojian();
        return;
    }

    /*
     * 明鏡止水啟動後，沿用 Original NPC combat-chat heartbeat 加速冷梅出招：
     * 不建立新傷害倍率，只額外呼叫一次 Original attack(opponent)，
     * 命中／防禦／吸收／傷害仍全部交由 COMBAT_D。
     */
    if (query_temp("cold_plum/mirror_state")) {
        opponent = query_opponent();
        if (objectp(opponent) && environment(opponent) == environment())
            attack(opponent);
        return;
    }

    set_temp("cold_plum/mirror_state", 1);
    set_temp("cold_plum/mirror_index", 0);
    // Gameplay Evidence 校正：明鏡止水整段（含【】與名稱）維持白色。
    message_vision(HIW
        "\n$N心摒若水，眼明如鏡，竟漸入「【 明  鏡  止  水 】」之境界！\n"
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
    set_skill("au-chan sword", 300);
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
    load_object("/daemon/skill/au-chan_sword");
    map_skill("force", "hainmay force");
    map_skill("sword", "lunmay");
    map_skill("parry", "lunmay");

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

    // Arena NPC Vital Stats／依 Original F_STATISTIC 正式 API 分別同步 Maximum／Effective／Current。
    // 必須放在 setup() 後，避免 Race/Class setup 覆蓋；梅寒霜精、氣、神固定 999/999。
    set_stat_maximum("gin", 999);
    set_stat_effective("gin", 999);
    set_stat_current("gin", 999);
    set_stat_maximum("kee", 999);
    set_stat_effective("kee", 999);
    set_stat_current("kee", 999);
    set_stat_maximum("sen", 999);
    set_stat_effective("sen", 999);
    set_stat_current("sen", 999);

    // setup() 可能套用 Race/Class 初始值；Arena 規格要求八屬性精確 50，故再次鎖定。
    set_attr("str", 50); set_attr("cor", 50);
    set_attr("int", 50); set_attr("spi", 50);
    set_attr("cps", 50); set_attr("dex", 50);
    set_attr("con", 50); set_attr("wis", 50);

    weapon = carry_object("/d/arena/obj/charred_plum_branch");
    if (objectp(weapon)) weapon->wield("sword");
}
