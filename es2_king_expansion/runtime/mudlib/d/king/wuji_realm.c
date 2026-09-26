inherit ROOM;

void create()
{
    set("short", "天神殿・無極之境");
    set("long", @LONG
此處乃超脫三界、凌駕諸天維度之上的天朝創世神殿，亦是創世神掌御寰宇、俯察萬界的至高樞紐。

神殿無牆無柱，廣袤無涯，四方混沌星河奔湧迴旋。太虛之中，十色天晶之氣與太初造化交融生滅；每一道晶芒明滅流轉，皆似映照著一方大千世界的誕生與寂滅。

足下九天玉階皆由純淨無相玄晶鋪就，澄澈如鏡，倒映諸天星宿。立於極巔垂眸俯瞰，天朝萬里山河、城郭江湖與芸芸眾生，盡如掌中微塵；億萬生靈之生死興衰、因果流轉，皆繫於至高主宰一念之間。

此境超脫凡塵，不承常理，亦不受三千天地法則所拘。\n\n一道太初神光懸於神殿中央，另一端通往獨立於現世之外的虛數戰鬥維度——【演武界】。
LONG
    );
    set("exits", ([
        "down" : "/d/snow/square",\n        "enter" : "/d/arena/yanwujie",
    ]));
    set("no_fight", 1);
    set("no_clean_up", 1);
    set("es2_king_expansion", 1);
    setup();
}

void init()
{
    object visitor = this_player();

    // Admin boundary／管理邊界：非最高管理員若以非正常方式進入，立即送回凡間廣場。
    if (objectp(visitor)
    &&  wiz_level(visitor) < wiz_level("(admin)")) {
        tell_object(visitor, "無極之境只回應創世權限，你被送回雪亭鎮。\n");
        visitor->move("/d/snow/square");
    }
}
