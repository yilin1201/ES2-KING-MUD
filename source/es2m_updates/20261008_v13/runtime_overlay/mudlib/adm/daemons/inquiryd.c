// inquiryd.c
// Original ES2 / Annihilator：1995-01-19 建立的 NPC 預設詢問處理 daemon。
// Source: mudchina/es2-utf8 commit 87bba6bd2249beec8424b0d6623486a0dd1f7b30
// V13 僅保存可驗證原始碼；是否進入實際 Runtime 仍由安全套用器與建置結果決定。

#include <ansi.h>

int parse_inquiry(object me, object ob, string topic)
{
    switch( topic ) {
    case "name":
    case "名字":
        message_vision(CYN "$N向$n問道：敢問" + RANK_D->query_respect(ob)
            + "尊姓大名？\n" NOR, me, ob);
        return 1;
    case "here":
    case "這裡":
        message_vision(CYN "$N向$n問道：這位" + RANK_D->query_respect(ob)
            + "，" + RANK_D->query_self(me) + "初到貴寶地，不知這裡有些什麼風土人情？\n" NOR,
            me, ob);
        return 1;
    case "rumors":
    case "傳聞":
        message_vision(CYN "$N向$n問道：這位" + RANK_D->query_respect(ob)
            + "，不知最近有沒有聽說什麼消息？\n" NOR, me, ob);
        return 1;
    default:
        return 0;
    }
}
