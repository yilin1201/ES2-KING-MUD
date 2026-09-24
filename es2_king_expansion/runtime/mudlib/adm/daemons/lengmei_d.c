#pragma save_binary
inherit F_CLEAN_UP;

// 冷梅武學 Runtime／ES2-KING 正式設定。
// 玩家只需啟動「明鏡止水」；進入狀態後，每個戰鬥回合由 Combat Engine
// 自動從六式招式池隨機選擇攻擊。此檔不改寫 Original ES2 保存來源。

private string *mingjing_moves = ({
    "梅二方劍",
    "梅四方劍",
    "梅八方劍",
    "愛霜恨雪",
    "寒霜三千里",
    "傲梅暗劍訣",
});

private void create() { seteuid(getuid()); }

string force_name() { return "冷梅心法"; }
string sword_name() { return "冷梅劍法"; }
string state_name() { return "明鏡止水"; }

string *mingjing_move_pool()
{
    return mingjing_moves + ({});
}

int activate_mingjing_zhishui(object actor)
{
    if (!objectp(actor)) return 0;
    actor->set("es2_king/lengmei/force", force_name());
    actor->set("es2_king/lengmei/sword", sword_name());
    actor->set("es2_king/lengmei/mingjing_zhishui", 1);
    return 1;
}

int deactivate_mingjing_zhishui(object actor)
{
    if (!objectp(actor)) return 0;
    actor->delete("es2_king/lengmei/mingjing_zhishui");
    return 1;
}

int mingjing_zhishui_active(object actor)
{
    return objectp(actor) && actor->query("es2_king/lengmei/mingjing_zhishui");
}

// Random Move／隨機招式：每次 Combat Round 呼叫一次；允許連續抽到相同招式。
// 傷害、Buff、精消耗與各招權重尚無足夠 Original Evidence，因此此處不自行虛構數值。
string random_mingjing_move(object actor)
{
    if (!mingjing_zhishui_active(actor)) return 0;
    return mingjing_moves[random(sizeof(mingjing_moves))];
}
