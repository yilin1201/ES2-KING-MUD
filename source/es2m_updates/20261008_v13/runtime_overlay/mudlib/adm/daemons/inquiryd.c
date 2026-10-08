// inquiryd.c
// Created by Annihilator@ES2 (01-19-95)
// ES2M dialogue reconstruction：保留預設 inquiry trigger。

#include <ansi.h>

int parse_inquiry(object me, object ob, string topic)
{
    switch( topic ) {
    case "name":
    case "名字":
        message_vision(CYN "$N向$n問道：敢問尊姓大名？\n" NOR, me, ob);
        return 1;

    case "here":
    case "這裡":
        message_vision(CYN "$N向$n問道：不知這裡有些什麼風土人情？\n"
            NOR, me, ob);
        return 1;

    case "rumors":
    case "傳聞":
        message_vision(CYN "$N向$n問道：最近有沒有聽說什麼消息？\n"
            NOR, me, ob);
        return 1;
    }

    return 0;
}
