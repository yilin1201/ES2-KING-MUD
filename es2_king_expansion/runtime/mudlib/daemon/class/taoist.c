// [ES2-KING Reconstruction] Original 道士職業稱謂相容層。
//
// Evidence Boundary／證據邊界：
// - 歷史 ES2 職業／Help 資料直接保存 taoist.fire、taoist.storm、
//   taoist.freeze、taoist.thunder 與 mao-shan.* 道士門派識別。
// - 「道士」中文職業名稱由歷史七職業資料與 Help 交叉支持。
// - 目標 Original 的 taoist class daemon、initialize、advance_level、
//   裝備限制、屬性成長與完整拜師條件尚未回收。
//
// 因此本檔只恢復 score／who 會使用的稱謂介面；未知 callback 維持未定義，
// 不把外部 Help 的技能或數值倒灌為目標 Runtime Canon。

inherit F_DBASE;

static void
create()
{
}

string
query_rank(object obj, string politness)
{
    if (!politness)
        return "道士";

    switch (politness) {
    case "self":
        return "貧道";
    case "respectful":
        return "道長";
    case "rude":
    default:
        return "牛鼻子";
    }
}
