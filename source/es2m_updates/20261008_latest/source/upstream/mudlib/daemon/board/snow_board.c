/*---
description: ES2M 2026-10-08 最新版雪亭鎮留言板。
來源：wolfer168/es2-webmud @ be98db057a7de64f368037b6bad9504764cdd854
用途：ES2-KING Evidence / Runtime Update Layer。
---*/
inherit BULLETIN_BOARD;

private void
create()
{
    set_name("雪亭鎮留言板", ({ "snow town board", "board" }));
    set("location", "/d/snow/square_w");
    set("board_id", "snow");
    set("capacity", 100);
    setup();
    set("long", "這是雪亭鎮廣場上的留言板，來往的旅人常在這裡留下消息，誰都可以看，也都可以寫。\n");
}

// 留言板英文識別名稱，供舊式板件／Web 顯示使用。
string query_id() { return "Snow Town Board"; }
