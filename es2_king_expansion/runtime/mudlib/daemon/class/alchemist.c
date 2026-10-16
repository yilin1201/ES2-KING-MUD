// [ES2-KING Reconstruction] Original 方士職業稱謂相容層。
//
// Evidence Boundary／證據邊界：
// - `alchemist` ID 由 Original `d/snow/npc/alchemist.c` 與 `who -at` 直接確認。
// - 「方士」中文名稱由封存的 Original ES2 職業／門派資料確認。
// - Original 的 initialize、advance_level、裝備限制與成長公式尚未回收。
//
// 因此本檔只恢復 `score`／`who` 會使用的稱謂介面；其餘 callback（回呼）
// 維持目前 Runtime 的未定義行為，不加入任何數值或能力。

inherit F_DBASE;

static void
create()
{
}

string
query_rank(object obj, string politness)
{
    if (!politness)
        return "方士";

    switch (politness) {
    case "self":
        return "在下";
    case "respectful":
        return "方士";
    case "rude":
    default:
        return "傢伙";
    }
}
