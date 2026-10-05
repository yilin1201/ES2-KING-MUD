/*---
description: 店小二，負責招呼客人點菜和送菜。
author: Annihilator <taedlar@gmail.com>
---*/

#include <npc.h>

inherit F_VILLAGER;
inherit F_VENDOR;

int on_service = 0;

void create() {
    set_name ("店小二", ({ "waiter", "snow_inn_waiter" }) );
    set_race ("human");
    set_class ("commoner");
    set_level (2);

    set ("age", 21);
    set ("long",
        "一個約二十出頭的年輕小夥計﹐正忙進忙出招呼客人﹐你可以用\n"
        "list 看可以點什麼菜﹐用 buy 跟店小二點菜。\n");
    set ("chat_chance", 1);
    set ("chat_msg", ({
        "店小二閒著無聊﹐哼起小曲兒來。\n",
        "店小二探頭出去望了望天色﹐說道﹕這幾天天氣不錯﹐真想出去走走。\n",
        (: command, "say 那說書的李先生不知道好點了沒﹐少了說書的這裡實在氣悶。" :),
        (: command, "say 客倌今天怎麼有空﹐最近可有新鮮事能說來聽聽嗎﹖" :),
    }));
    set ("merchandise", ([
        "/obj/food/dumpling": 50,
        "/obj/food/manto": 50,
        "/obj/food/pork": 30,
        __DIR__"obj/roast_chicken": 30,
    ]));

    setup();
}

void init() {
    ::init();
    add_action ("do_vendor_list", "list");
}

int accept_fight (object ob) {
    do_chat ("店小二扮了個鬼臉﹐說道﹕客倌要打架的話﹐小的我可不是對手。\n");
    return 0;
}

varargs mixed affirm_merchandise (object customer, string item_name, int amount) {
    if (on_service)
        return notify_fail ("店小二正忙著招呼其他客人﹐請你等一會兒。\n");
    return ::affirm_merchandise (customer, item_name, amount);
}

private void handover (object customer, mixed item, int amount, int price) {
    mixed err;
    int delivered;

    on_service = 0;
    if (!customer || environment(customer)!=environment()) {
        command ("say 咦﹖剛剛那位客倌人呢﹖");
        say ("店小二把準備好的" + item->name() + "又端了回去。\n");
        return;
    }
    if( customer->can_afford(price) != 1 ) {
        tell_object(customer, "店小二說道﹕客倌的錢不夠，這筆交易就算了。\n");
        return;
    }

    // Deferred Settlement／延遲結算：先完整交貨，成功後才扣款；離開房間不扣錢。
    if( err = catch(delivered = ::deliver_merchandise(customer, item, amount, price)) ) {
        tell_object(customer, "店小二說道﹕這批東西出了問題，小店沒有收您的錢。\n");
        return;
    }
    if( !delivered ) {
        tell_object(customer, "店小二說道﹕您身上拿不下這批東西，小店沒有收您的錢。\n");
        return;
    }
    customer->pay_money(price);
    customer->gain_score("survive", random(price/300 + customer->query_attr("wis")/3) );
    command ("say 客倌﹐您的" + item->name() + "來啦﹗");
    message_vision ("$N把剛從廚房端出來的" + item->name()
        + "送到$n面前。\n", this_object(), customer);
}

varargs int deliver_merchandise (object customer, mixed item, int amount, int price) {
    if (amount < 1) amount = 1;
    command ("say " + item->name() + "是吧﹖馬上來﹗");
    say ("店小二對著廚房喊道﹕" + item->name() + chinese_number(amount) + "份﹗\n");
    on_service = 1;
    do_chat ((: handover, customer, item, amount, price :));
    // 2 通知 buy 指令：本 NPC 會在 handover 中完成交貨與扣款。
    return 2;
}
