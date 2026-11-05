inherit ITEM;

void create()
{
    set_name("創世印記", ({ "creation mark", "mark" }));
    set_weight(1);
    set("unit", "枚");
    set("long", "一枚標示 ES2-KING 創世系統已通過權限與登錄表檢查的印記。\n");
    set("value", 0);
    set("no_sell", 1);
    set("no_drop", 1);
    set("es2_king_expansion", 1);
    setup();
}
