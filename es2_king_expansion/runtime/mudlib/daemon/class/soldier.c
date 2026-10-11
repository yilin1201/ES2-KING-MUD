#include <ansi.h>

inherit F_DBASE;

/* ES2-KDS reference fix／軍人升級 daemon 的有效 UID 與升級目標修正。
 * 只放在 ES2-KING Expansion Runtime overlay，不覆寫 Original ES2 保存來源。
 */
static void create() { seteuid(getuid()); }

string query_rank(object obj, string politeness)
{
    if (!politeness) return "軍人";

    switch (politeness) {
        case "self":
            return "小的";
        case "respectful":
            return "軍爺";
        case "rude":
        default:
            return "大兵";
    }
}

/* 每個種族可用 commoner_score_base 調整升級門檻；預設 100%。 */
private int race_coef(object ob)
{
    int coef;
    coef = RACE_D(ob->query_race())->query("commoner_score_base");
    return coef > 0 ? coef : 100;
}

/* 武器精熟與實戰經驗依目前等級設定下一級門檻；30 級後才需要軍功。 */
void set_next_target(object ob, int cur_lv)
{
    int lv, coef;

    if (cur_lv < 1) cur_lv = 1;
    lv = cur_lv + 1;
    coef = race_coef(ob);

    ob->set_target_score("weapon mastery", (lv-1) * (lv-1) * 2 * 100 * coef / 100);
    ob->set_target_score("combat", (lv-1) * (lv-1) * 2 * 100 * coef / 100);
    ob->set_target_score("military service", lv > 30 ? (lv-30) * (lv-30) * 100 * coef / 100 : 0);
}

void initialize(object ob)
{
    set_next_target(ob, ob->query_level());
}

/* advance_level 在角色 level 遞增前呼叫；先更新精氣神，再設定下一級門檻。 */
void advance_level(object ob)
{
    int gin_gain, kee_gain, sen_gain;

    gin_gain = (int)ob->query_attr("dex") / 3 + random(3) - 1;
    kee_gain = (int)ob->query_attr("con") / 3 + random(3) - 1;
    sen_gain = (int)ob->query_attr("spi") / 8 + random(3) - 1;
    if (gin_gain < 0) gin_gain = 0;
    if (kee_gain < 0) kee_gain = 0;
    if (sen_gain < 0) sen_gain = 0;

    ob->set_stat_maximum("gin", (int)ob->query_stat_maximum("gin") + gin_gain);
    ob->set_stat_maximum("kee", (int)ob->query_stat_maximum("kee") + kee_gain);
    ob->set_stat_maximum("sen", (int)ob->query_stat_maximum("sen") + sen_gain);

    tell_object(ob, HIY "常年的軍旅操練讓你的精氣神更加充沛！\n" NOR);
    set_next_target(ob, ob->query_level() + 1);
}
