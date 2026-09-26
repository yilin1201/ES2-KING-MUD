// /d/arena/yanwujie.c
// ES2-KING Expansion：獨立沙盒戰鬥空間「競技場：演武界」。
// 注意：此房間屬 Expansion，不宣稱為 Original ES2 Canon。

#include <ansi.h>
inherit ROOM;

void create()
{
    set("short", HIW "【競技場：演武界】" NOR);
    set("long", @LONG
此處乃創世天神於虛數維度中開闢的獨立神魔戰鬥空間——【演武界】。
四方被堅不可摧的太初界壁所籠罩，縱有毀天滅地的神魔威能亦無法穿透分毫。
腳下鋪陳著萬劫不移的黑曜神石，泛著冷冽肅穆的幽光。
在此方天地之內，生死因果盡被神則隔絕，交戰雙方可傾盡畢生所學肆意死鬥，
即使身死亦能受法則庇護原地滿血重塑，永無真隕之虞。
LONG
    );

    set("exits", ([
        "up" : "/d/wizard/admin_room",
    ]));

    // Arena metadata／競技場標記：真正死亡攔截仍須由 Original die() hook 明確支援後才宣告 Runtime PASS。
    set("no_die", 1);
    set("arena_zone", 1);
    set("no_flee", 1);

    setup();
}

// Arena recovery hook／競技場復原入口。
// 保留使用者指定的 alternative_die 介面；是否會由 Original death chain 自動呼叫，必須 Runtime 驗證。
int alternative_die(object who)
{
    message_vision(HIR "\n$N周身氣血逆亂，護體罡氣徹底崩潰，轟然倒地！\n" NOR, who);
    message_vision(HIY "【演武界法則引動】——虛空之中太初神光傾瀉，$N肉身與神魂瞬間滿血重組，戰意重歸巔峰！\n\n" NOR, who);

    who->set("kee", who->query("max_kee"));
    who->set("eff_kee", who->query("max_kee"));
    who->set("force", who->query("max_force"));
    who->set("gin", who->query("max_gin"));
    who->set("sen", who->query("max_sen"));
    who->clear_condition();

    return 1;
}
