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
    return 1;
}

int set_batian(object actor, string phase)
{
    if (!authorized(actor) || phase != "zhao" && phase != "ji") return 0;
    actor->set("es2_king/batian_lianti_jue", phase);
    return 1;
}

// KING Test Provisioning／KING 測試配置：只授予已定稿 Expansion 武學，
// 等級仍服從 Original set_skill 的 200 級上限，不建立平行技能資料庫。
int set_daxie(object actor, int level)
{
    if (!authorized(actor) || level < 1 || level > 200) return 0;
    actor->set_skill("kuxiao force", level);
    actor->set_skill("daxie qisun blade", level);
    actor->map_skill("force", "kuxiao force");
    actor->map_skill("sword", "daxie qisun blade");
    actor->set("es2_king/daxie_level", level);
    return 1;
}


// 冷梅莊武學／KING 正式配置。
// Original F_SKILL 的一般技能上限為 200；KING 不建立平行 300 級技能規則。
// 梅寒霜的 300 為 Arena NPC local override，KING 則維持 Original 玩家技能邊界。
int set_cold_plum(object actor, int level)
{
    if (!authorized(actor) || level < 1 || level > 200) return 0;

    actor->set_skill("hainmay force", level);
    actor->set_skill("advance_lunmay", level);
    actor->set_skill("lunmay", level);
    actor->set_skill("mayin", level);
    actor->set_skill("seven", level);
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
    actor->set("es2_king/lengmei/mingjing_zhishui", 1);
    actor->set_temp("cold_plum/mirror_state", 1);
    actor->set_temp("cold_plum/mirror_index", 0);
    actor->set("es2_king/lengmei_level", level);
    return 1;
}
