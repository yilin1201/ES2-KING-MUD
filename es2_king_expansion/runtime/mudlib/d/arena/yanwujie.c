// /d/arena/yanwujie.c
// ES2-KING Expansion：獨立沙盒戰鬥空間「競技場：演武界」。
// Original ES2 戰鬥資源使用 Statistic API；未驗證的死亡 Hook 不在此冒充有效機制。

#include <ansi.h>
inherit ROOM;

void create()
{
    set("short", HIW "【競技場：演武界】" NOR);
    set("long", @LONG
此處乃創世天神於虛數維度中開闢的獨立神魔戰鬥空間。

四方被堅不可摧的太初界壁所籠罩，縱有毀天滅地之威，亦無法撼動此界分毫。
腳下鋪陳著萬劫不移的黑曜神石，冷冽幽光沿著古老神紋緩緩流動。
此方天地與現世生死因果隔絕，交戰者可傾盡畢生所學，在此印證武道。

演武界不改寫角色的永久修為、經驗、門派、技能與裝備；戰鬥仍使用 Original ES2
的精、氣、神與 Combat／Statistic 系統。真正的敗北保護由 Runtime 死亡鏈確認後接入，
在此之前不以未被 Original die() 呼叫的 Room Hook 冒充「不死」機制。

一道太初神光懸於上方，可循光返回【天神殿・無極之境】。
LONG
    );

    set("exits", ([
        "up" : "/d/king/wuji_realm",
    ]));

    // Arena Metadata／競技場標記：供後續經 Original Death call chain 驗證的保護層辨識。
    set("arena_zone", 1);
    set("es2_king_expansion", 1);
    set("no_clean_up", 1);
    setup();
}
