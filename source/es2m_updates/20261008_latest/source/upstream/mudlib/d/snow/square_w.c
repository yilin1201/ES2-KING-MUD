/*---
description: ES2M 2026-10-08 最新版雪亭鎮廣場西側。
來源：wolfer168/es2-webmud @ be98db057a7de64f368037b6bad9504764cdd854
用途：ES2-KING Evidence / Runtime Update Layer。
---*/

#include <room.h>
inherit ROOM;

void create()
{
    set("short", "廣場");
    set("long", @LONG
這裡是雪亭鎮廣場的西邊﹐往東可以看見廣場中央的大榕樹。
一家小客棧座落在西邊不遠處﹐客棧前的一串燈籠上寫著「飲風客棧」四個大字。
廣場上鋪著整齊的石板，在這樣的小鎮通常是因為驛站的緣故才會費事鋪設。
LONG
    );
    set("exits", ([
        "south" : __DIR__"square_sw",
        "west"  : __DIR__"inn_hall",
        "east"  : __DIR__"square",
        "north" : __DIR__"bug_room",
    ]));
    create_door("west", "客棧大門", "east", DOOR_CLOSED);

    set("objects", ([
        __DIR__"obj/stone" : 1,
    ]));

    set("outdoors", "snow");

    // 雪亭鎮留言板所在地禁止戰鬥，避免玩家張貼留言時遭到 PK。
    set("no_fight", 1);

    setup();

    // 載入雪亭鎮留言板物件。
    load_object("/daemon/board/snow_board");

    replace_program(ROOM);
    set("map/area", "雪亭鎮");
}
