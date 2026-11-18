

#include <dbase.h>
#include <name.h>

static mapping stock;

private void
reset()
{
    if( !environment() ) return;
    stock = copy(query("merchandise"));
}

varargs mixed
affirm_merchandise(object buyer, string what, int amount)
{
    mapping list;
    string item, name_part;
    int index, count;

    if( amount < 1 )
        return notify_fail("購買數量必須至少是一個。\n");
    // 商品名稱可能含空格；只有尾端確實是索引數字時才拆開。
    if( sscanf(what, "%s %d", name_part, index) == 2 ) what = name_part;
    else index = 1;

    if( !mapp(list = query("merchandise")) )
        return notify_fail(name() + "並沒有賣 " + what + " 這種東西。\n");

    if( !mapp(stock) ) stock = copy(list);
    foreach(item, count in stock) {
        if( (!item->id(what)) || (--index) ) continue;
        if( stock[item] < 1 )
            return notify_fail(item->name() + "已經賣完了﹐待會兒再來吧。\n");
        if( stock[item] < amount )
            return notify_fail(item->name() + "只剩下" + chinese_number(stock[item])
                + (item->query("base_unit") || item->query("unit") || "個") + "了。\n");
        return item;
    }
    return notify_fail(name() + "並沒有賣 " + what + " 這種東西。\n");
}

int
query_trading_price(string handle)
{
    mapping list;

    if( !mapp(list = query("merchandise")) ) return 0;
    if( undefinedp(list[handle]) ) return 0;
    return handle->query("value");
}

// Atomic Delivery／原子交貨：先建立整批商品，再全部移入玩家背包。
// 任一件無法建立或搬入時銷毀整批，庫存不變，讓 buy 指令可以保證不扣款。
varargs int
deliver_merchandise(object me, string what, int amount, int price)
{
    mapping list;
    object ob, container_ob;
    object *goods;
    string container, unit, item_name, err;
    int i;

    if( !living(this_object()) ) return 0;
    list = query("merchandise");
    if( !mapp(list) || undefinedp(list[what]) ) return 0;
    if( amount < 1 ) return 0;
    if( !mapp(stock) ) stock = copy(list);
    // Delivery Recheck／交貨重查：延遲或重複請求不得越過已變動的庫存。
    if( undefinedp(stock[what]) || stock[what] < amount ) return 0;

    goods = ({});
    if( err = catch(ob = new(what)) ) return 0;
    item_name = ob->query("name");

    if( ob->query_volume() ) {
        if( !(container = ob->query("default_container")) ) container = "/obj/bottle";
        for( i = 0; i < amount; i++ ) {
            if( i && (err = catch(ob = new(what))) ) break;
            if( !objectp(ob) ) break;
            if( err = catch(container_ob = new(container)) ) {
                destruct(ob);
                break;
            }
            if( !objectp(container_ob) ) { destruct(ob); break; }
            unit = container_ob->query("container_unit");
            if( !ob->move(container_ob) ) { destruct(ob); destruct(container_ob); break; }
            goods += ({ container_ob });
        }
    } else if( function_exists("set_amount", ob) ) {
        unit = ob->query("base_unit") || ob->query("unit");
        ob->set_amount(amount);
        goods = ({ ob });
    } else {
        unit = ob->query("unit");
        goods = ({ ob });
        for( i = 1; i < amount; i++ ) {
            if( err = catch(ob = new(what)) ) break;
            goods += ({ ob });
        }
    }

    if( err || !sizeof(goods)
    ||  (!function_exists("set_amount", goods[0]) && sizeof(goods) != amount) ) {
        foreach(ob in goods) if( objectp(ob) ) destruct(ob);
        return 0;
    }

    foreach(ob in goods) {
        if( !ob->move(me) ) {
            foreach(container_ob in goods) if( objectp(container_ob) ) destruct(container_ob);
            return 0;
        }
    }

    if( !unit ) unit = "個";
    tell_object(me, "你向" + name() + "買下" + chinese_number(amount) + unit + item_name + "。\n");
    stock[what] -= amount;
    return 1;
}

private string
price_string(int v)
{
    if( v%10000 == 0 ) return chinese_number(v/10000) + "兩黃金";
    if( v%100 == 0 ) return chinese_number(v/100) + "兩銀子";
    return chinese_number(v) + "文錢";
}

int
do_vendor_list(string arg)
{
    mapping goods;
    string list, item;
    int count;

    if( !mapp(goods = query("merchandise")) ) return 0;
    if( arg && !id(arg) ) return 0;
    if( !mapp(stock) ) stock = copy(goods);

    list = "";
    // Stock-consistent List／庫存一致清單：顯示即時剩餘庫存，不把已售罄商品繼續列出。
    foreach(item, count in stock) {
        if( count < 1 ) continue;
        // Compatibility／相容性：KING 基準沒有 ES2M 新增的 cjk_pad，保留 Original 列表格式。
        list += sprintf("  %-30s：%s\n",
            item->short(1), price_string(item->query("value")) );
    }
    if( list=="" ) {
        write( name() + "的貨物已經全部賣光了，下次早一點來吧！\n");
        return 1;
    }

    write("你可以購買下列這些東西：\n-------------------------\n" + list);
    return 1;
}
