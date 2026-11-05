#pragma save_binary
inherit F_CLEAN_UP;
#define KING_D "/adm/daemons/kingd"

private string *huntian = ({ "白雲煙", "玫霞蕩", "土崑崙", "碧雪冰", "紫星河", "玄混沌", "靛滄海", "金晨曦", "血穹蒼", "玄宇宙" });
private string *rulai = ({ "佛光初現", "金頂佛燈", "佛動山河", "佛問迦藍", "迎佛西天", "佛光普照", "天佛降世", "佛鎮八荒", "佛法無邊", "九九歸一・萬佛朝宗", "天舞梵輪・萬相歸墟" });
private string *weapons = ({ "萬華金龍奪", "琉璃戒刀", "驚雷禪杖", "雷音尺", "涅槃珠", "菩提淘", "震穹白玉鼎", "金剛降魔杵", "大日如來離火法輪", "萬佛法印", "阿賴耶識・歸墟神輪" });
private string *turns = ({ "斷五感", "絕六識", "滅七識", "破八識" });

private void create() { seteuid(getuid()); }
// Canon 寫入沿用唯一 Owner 帳號授權；不變動任何既定招式或佛兵資料。
int authorized(object actor) { return KING_D->authorized(actor); }
string huntian_name(int rank) { return rank >= 1 && rank <= 10 ? huntian[rank - 1] : "UNKNOWN"; }
string rulai_name(int form) { return form >= 1 && form <= 11 ? rulai[form - 1] : "UNKNOWN"; }
string weapon_name(int form) { return form >= 1 && form <= 11 ? weapons[form - 1] : "UNKNOWN"; }

int set_huntian(object actor, int rank)
{
    if (!authorized(actor) || rank < 1 || rank > 10) return 0;
    actor->set("es2_king/huntian_rank", rank);
    actor->set("es2_king/huntian_name", huntian_name(rank));
    return 1;
}
int set_rulai(object actor, int form)
{
    if (!authorized(actor) || form < 1 || form > 11) return 0;
    actor->set("es2_king/rulai_form", form);
    actor->set("es2_king/rulai_name", rulai_name(form));
    actor->set("es2_king/rulai_weapon", weapon_name(form));
    return 1;
}
int set_turn(object actor, int turn)
{
    if (!authorized(actor) || turn < 1 || turn > 4) return 0;
    actor->set("es2_king/rulai_turn", turns[turn - 1]);
    return 1;
}
