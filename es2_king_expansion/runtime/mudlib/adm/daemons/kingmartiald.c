#pragma save_binary
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"

private mapping yijinjing_stages = ([
    49 : "紅級通脈境", 99 : "黃級鍛骨境", 149 : "青級生生境",
    199 : "藍級冰魄境", 249 : "金級破虛境", 299 : "白級聖光境",
    300 : "黑級無極境",
]);

private void create() { seteuid(getuid()); }

// 唯一 Owner 帳號授權集中交給 KING_D，避免各武學服務產生不同判定。
int authorized(object actor) { return KING_D->authorized(actor); }

string yijinjing_stage(int level)
{
    if (level < 1 || level > 300) return "UNKNOWN";
    foreach (int ceiling, string stage in yijinjing_stages)
        if (level <= ceiling) return stage;
    return "UNKNOWN";
}

int set_yijinjing(object actor, int level)
{
    if (!authorized(actor) || level < 1 || level > 300) return 0;
    actor->set("es2_king/yijinjing_level", level);
    actor->set("es2_king/yijinjing_stage", yijinjing_stage(level));
    // 黑級無極・以氣化招：Lv.300 只解鎖能力資格，不自行生成任何未定稿終極殺招。
    actor->set("es2_king/yijinjing_qi_manifest", level == 300 ? 1 : 0);
    return 1;
}

int set_batian(object actor, string phase)
{
    if (!authorized(actor) || phase != "zhao" && phase != "ji") return 0;
    actor->set("es2_king/batian_lianti_jue", phase);
    return 1;
}

// KING Creator Exception／KING 創世神技能配置：Project Canon 上限 300。
// 只作用於 KING_D 授權的唯一 Owner，不改一般玩家技能邊界。
int set_daxie(object actor, int level)
{
    if (!authorized(actor) || level < 1 || level > 300) return 0;
    actor->set_skill("kuxiao force", level);
    actor->set_skill("daxie qisun blade", level);
    actor->set_skill("blade", level);
    // 大邪七損刀是刀法；不覆蓋 KING 的主內功易筋經與主劍法冷梅劍法。
    // 哭笑門心法只作為大邪金身的已學相依技能；KING 主 force 仍維持易筋經。
    actor->map_skill("blade", "daxie qisun blade");
    actor->set("es2_king/daxie_level", level);
    return 1;
}


// 冷梅莊武學／KING 正式配置。
// KING Owner 依 Project Canon 使用 Lv.300；一般玩家規則不在此修改。
int set_cold_plum(object actor, int level)
{
    if (!authorized(actor) || level < 1 || level > 300) return 0;

    actor->set_skill("hainmay force", level);
    actor->set_skill("advance_lunmay", level);
    actor->set_skill("lunmay", level);
    actor->set_skill("mayin", level);
    actor->set_skill("seven", level);
    // Historical Skill Visibility／驗收顯示：只匯入已由 Original/Historical Evidence 確認的技能 ID 與名稱。
    // advance_lunmay 已是傲梅暗劍訣；chin_staff／seven_blade 先作技能欄位，不在缺乏直接 Source 時猜測 weapon mapping。
    actor->set_skill("chin_staff", level);
    actor->set_skill("seven_blade", level);
    actor->set_skill("force", level);
    actor->set_skill("sword", level);
    actor->set_skill("parry", level);
    actor->set_skill("dodge", level);
    actor->set_skill("unarmed", level);

    // Expansion 冷梅劍法 daemon 先登記，再交回 Original Combat 使用。
    load_object("/d/arena/skill/lunmay");
    actor->map_skill("force", "hainmay force");
    actor->map_skill("sword", "lunmay");

    // 寒梅心法 → 明鏡止水 → 冷梅劍法五式 → 傲梅暗劍訣。
    actor->set("es2_king/lengmei/force", "寒梅心法");
    actor->set("es2_king/lengmei/sword", "冷梅劍法");
    actor->set("es2_king/lengmei/secondhand_sword", "傲梅暗劍訣");
    actor->set("es2_king/lengmei/mingjing_zhishui", 1);
    actor->set_temp("cold_plum/mirror_state", 1);
    actor->set_temp("cold_plum/mirror_index", 0);
    actor->set("es2_king/lengmei_level", level);
    return 1;
}


// 如來神掌／KING 正式 Combat 配置。
// 招式名稱沿用 M29 Project Canon；Original ES2 未發現 Combat Source，故不補造特殊數值效果。
// KING Owner 依 Project Canon 使用 Lv.300。
// KING Creator Profile 正式主內功／拆招配置。
// KING Owner 依 Project Canon 使用 Lv.300；M28 未定義的 Combat 數值不補造。
int set_creator_core_martial(object actor, int level)
{
    if (!authorized(actor) || level < 1 || level > 300) return 0;

    actor->set_skill("yijinjing", level);
    actor->set_skill("batian lianti jue", level);
    actor->set_skill("force", level);
    actor->set_skill("parry", level);

    // KING Basic Skills Lv.300／只建立已確認的基礎技能欄位；四個預留項目暫不綁武學。
    foreach (string basic_skill in ({
        "force", "unarmed", "sword", "secondhand sword", "twohanded sword",
        "blade", "twohanded blade", "staff", "parry", "dodge", "whip"
    }))
        actor->set_skill(basic_skill, level);

    load_object("/d/arena/skill/yijinjing");
    load_object("/d/arena/skill/batian_lianti_jue");

    actor->map_skill("force", "yijinjing");
    actor->map_skill("parry", "batian lianti jue");

    // skills 指令使用 CHINESE_D 字典呈現正式中文武學名。
    CHINESE_D->add_translate("yijinjing", "易筋經");
    CHINESE_D->add_translate("batian lianti jue", "霸天煉體訣");
    CHINESE_D->add_translate("rulai shenzhang", "如來神掌");
    CHINESE_D->add_translate("advance_lunmay", "傲梅暗劍訣");
    CHINESE_D->add_translate("chin_staff", "青邪杖法");
    CHINESE_D->add_translate("seven_blade", "大邪七損刀訣");

    actor->set("es2_king/yijinjing_level", level);
    actor->set("es2_king/yijinjing_stage", yijinjing_stage(level));
    // Creator Profile 同步黑級資格；只標記「以氣化招」能力，不補造具體招式。
    actor->set("es2_king/yijinjing_qi_manifest", level == 300 ? 1 : 0);
    actor->set("es2_king/batian_lianti_jue", "ji");
    actor->set("es2_king/batian_level", level);
    return 1;
}


int set_rulai_shenzhang(object actor, int level)
{
    if (!authorized(actor) || level < 1 || level > 300) return 0;
    actor->set_skill("rulai shenzhang", level);
    actor->set_skill("unarmed", level);
    load_object("/d/arena/skill/rulai_shenzhang");
    actor->map_skill("unarmed", "rulai shenzhang");
    actor->set("es2_king/rulai_level", level);
    actor->set("es2_king/rulai_combat", 1);
    return 1;
}
