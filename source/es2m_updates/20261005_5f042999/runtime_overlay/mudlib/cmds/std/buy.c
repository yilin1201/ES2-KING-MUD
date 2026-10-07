

inherit F_CLEAN_UP;

private void create() { seteuid(getuid()); }

int main(object me, string arg)
{
    string item, targ, rest, err;
    object owner;
    mixed handle, delivered;
    int price, amount;

    if( me->is_busy() ) return notify_fail("你現在沒有空﹗\n");

    if( !arg || sscanf(arg, "%s from %s", item, targ)!=2 )
        return notify_fail("指令格式﹕buy [數量] <某物> from <某人>\n");

    // Quantity Purchase／批量購買：保留單件語法，數量上限沿用 ES2M 5f042999。
    if( sscanf(item, "%d %s", amount, rest) == 2 ) {
        if( amount < 1 ) return notify_fail("購買數量必須至少是一個。\n");
        item = rest;
    } else amount = 1;
    if( amount > 100 ) return notify_fail("一次最多只能買一百個。\n");

    if( !objectp(owner = present(targ, environment(me))) )
        return notify_fail("你要跟誰買東西﹖\n");

    if( userp(owner) ) {
        message_vision("$N想向$n購買「" + item + "」。\n", me, owner);
        return 1;
    }

    if( objectp(owner) && owner->query("no_fight") )
        return notify_fail("什麼??\n");

    if( !living(owner) )
        return notify_fail("看起來"+owner->name()+"已經無法買賣東西了。\n");

    if( owner->is_fighting() )
        return notify_fail("看起來" + owner->name() + "正忙著 ... 打架﹐沒空理你。\n");

    notify_fail("對方好像不願意跟你交易。\n");
    if( !(handle = owner->affirm_merchandise(me, item, amount)) ) return 0;
    price = owner->query_trading_price(handle) * amount;

    switch( me->can_afford(price) ) {
        case 0: return notify_fail("你身上的錢不夠。\n");
        case 1:
            // Transaction Result／交易結果：1 為已完整交貨；2 為店小二延遲交貨並自行結算。
            // 0 或例外都不得扣款，避免玩家付錢後沒有收到商品。
            if( err = catch(delivered = owner->deliver_merchandise(me, handle, amount, price)) ) {
                write("這筆交易出了點問題，" + owner->name() + "沒有收你的錢。\n");
                return 1;
            }
            if( delivered == 2 ) return 1;
            if( !delivered ) {
                write("商品無法完整交付，" + owner->name() + "沒有收你的錢。\n");
                return 1;
            }
            me->pay_money(price);
            me->gain_score("survive", random(price/300 + me->query_attr("wis")/3) );
            return 1;
        case 2:
            return notify_fail("交易暫時無法完成。\n");
    }
}

int help(object me)
{
   write( @HELP
指令格式: buy [數量] <something> from <someone>

這一指令讓你可以從某些人身上買到物品。
加上數量可以一次買多個，例如 buy 10 manto from waiter，一次最多一百個。
只有商品完整交付後才會扣款；交貨失敗不收錢。
HELP
   );
   return 1;
}

