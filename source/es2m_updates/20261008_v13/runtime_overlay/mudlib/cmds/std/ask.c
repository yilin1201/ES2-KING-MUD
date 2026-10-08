// ask.c
// Original ES2 / Annihilator lineage：保留 ask <某人> about <關鍵字>
// 與 ask <某人> for <交涉目標> 的原始 NPC callback 架構。
// Source: taedlar/es2_mudlib 7309240af1720b813cef3eb0ba135afc1f19c2ac

inherit F_CLEAN_UP;

int help();

int main(object me, string arg)
{
    string targ, key;
    object target;

    if( !arg || arg=="" ) return notify_fail("問什麼？\n");

    if( sscanf(arg, "%s about %s", targ, key)==2 ) {
        target = present(targ, environment(me));
        if( !target || !target->is_character() )
            return notify_fail("這裡沒有這個人。\n");

        // Original ES2：對 no_fight NPC 不進行 ask 互動。
        if( objectp(target) && target->query("no_fight") )
            return notify_fail("什麼??\n");

        message_vision("$N向$n打聽有關「" + key + "」的消息。\n", me, target);
        target->accept_inquiry(me, key);
        return 1;
    }
    else if( sscanf(arg, "%s for %s", targ, key)==2 )
    {
        target = present(targ, environment(me));
        if( !target || !target->is_character() )
            return notify_fail("這裡沒有這個人。\n");

        // Original ES2：對 no_fight NPC 不進行 ask 交涉。
        if( objectp(target) && target->query("no_fight") )
            return notify_fail("什麼??\n");

        switch(key) {
        case "help":
            message_vision("$N對著$n大叫：" + target->rank("respectful")
                + "救命！\n", me, target);
            break;
        case "peace":
            if( !target->is_fighting(me) ) {
                write(target->name() + "和你並沒有結仇。\n");
                return 1;
            }
            message_vision("$N向$n拱手一揖，說道：這位"
                + target->rank("respectful")
                + "武藝高強，在下佩服得緊，不如化敵為友如何？\n", me, target);
            break;
        case "mercy":
            if( target->is_killing(me) )
                message_vision("$N向$n雙膝跪倒，哀求道：" + target->rank("respectful")
                    + "饒命！小的下次再也不敢了！\n", me, target);
            break;
        default:
        }
        target->accept_negotiation(me, key);
        return 1;
    }
    else
        return notify_fail("請用 help ask 參考說明。\n");
}

int help()
{
    write(@TEXT
指令格式：ask <某人> about <關鍵字>
          ask <某人> for <交涉目標>

這個指令讓你和 npc 進行一些簡單的互動，用第一種格式的時候表示向 npc 打聽
有關某關鍵字的消息，第二種格式則是和 npc 進行交涉，目前大多數 npc 能夠了
解的交涉目標有：

help     向對方求助。
peace    向跟你有仇恨的人要求和解。
mercy    向正在攻擊你的敵人求饒。

TEXT
    );
    return 1;
}
