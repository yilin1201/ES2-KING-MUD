// [ES2-KING Reconstruction] Historical ES2 Fighter guild entry adapter／歷史武者同盟入口適配層。
//
// Source provenance／來源：
// - mudchina/es2 `std/room/class_guild.c`：join 使玩家 class=fighter。
// - mudchina/es2 `daemon/class/fighter/guildhall.c`：水煙閣正廳與武者同盟 identity。
// - Target Original `daemon/class/fighter.c`：query_rank() 回傳「武者」。
//
// Evidence Boundary／證據邊界：目標 snapshot 沒有保存 Waterfog 完整地圖、NPC、Board、
// 師父、技能或職業公式。本檔只轉譯歷史 join→fighter 規則，並以目標 set_class()
// 寫入既有 class property；不宣稱是回收的 target Original LPC。

inherit ROOM;

void create()
{
    set("short", "水煙閣正廳（歷史重建）");
    set("long", @LONG
這裡是武者同盟的正廳。牆上的木匾寫著：只要加入(join)武者同盟，
便可成為一名武者。
LONG
    );
    set("no_fight", 1);
    set("no_clean_up", 1);
    set("es2_king_reconstruction", "historical-fighter-guild-entry");
    setup();
}

void init()
{
    add_action("do_join", "join");
}

int do_join(string arg)
{
    object me;

    me = this_player();

    // Target characters always begin as commoner／平民；這對應歷史 Source 中
    // 「尚未加入其他公會」的資格，不增加屬性、門派或師父條件。
    if (me->query_class() != "commoner")
        return notify_fail("你已經參加了其他公會。\n");

    me->set_class("fighter");
    write("\n恭喜，從今天起你已經成為一名武者！\n\n");
    return 1;
}
