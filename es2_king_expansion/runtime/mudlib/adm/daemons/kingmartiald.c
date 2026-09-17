#pragma save_binary

inherit F_CLEAN_UP;

private mapping yijinjing_stages = ([
    49 : "紅級通脈境", 99 : "黃級鍛骨境", 149 : "青級生生境",
    199 : "藍級冰魄境", 249 : "金級破虛境", 299 : "白級聖光境",
    300 : "黑級無極境",
]);

private void create() { seteuid(getuid()); }

int authorized(object actor)
{
    return objectp(actor) && interactive(actor)
        && wiz_level(actor) >= wiz_level("(admin)");
}

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
