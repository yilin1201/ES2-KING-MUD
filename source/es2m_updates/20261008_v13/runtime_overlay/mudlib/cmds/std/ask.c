// ask.c
// ES2M dialogue reconstruction：保留 Original ES2「ask <NPC> about <topic>」
// 與 inquiry mapping 架構；不依賴未保存的跨 MUD 對話協定。

#include <ansi.h>

#define INQUIRY_D "/adm/daemons/inquiryd"

private string *msg_dunno = ({
    "$n搖搖頭，說道：沒聽說過。\n",
    "$n睜大眼睛望著$N，顯然不知道$P在說什麼。\n",
    "$n聳了聳肩，很抱歉地說：無可奉告。\n",
    "$n說道：嗯……這我可不清楚，你最好問問別人吧。\n"
});

int main(object me, string arg)
{
    string dest, topic, msg, *ids;
    object ob, env;
    mapping inquiry;
    int i;

    seteuid(getuid());

    if( !arg || arg=="" )
        return notify_fail("你要問誰什麼事？\n");

    if( sscanf(arg, "%s about %s", dest, topic) != 2 )
        topic = "";

    if( !objectp(ob = present(dest, environment(me))) )
        return notify_fail("這裡沒有這個人。\n");

    if( !ob->is_character() ) {
        message_vision("$N對著$n自言自語……\n", me, ob);
        return 1;
    }

    if( topic == "" ) {
        if( mapp(inquiry = ob->query("inquiry")) ) {
            ids = keys(inquiry);
            msg = "你可以打聽這些事情：\n"
                "※『這裡』\n※『名字』\n※『傳聞』\n";
            for( i=0; i<sizeof(ids); i++ )
                msg += sprintf("※『%s』\n", ids[i]);
            write(msg);
            return 1;
        }
        topic = "詢問";
    }

    if( !ob->query("can_speak") ) {
        message_vision("$N向$n打聽有關『" + topic
            + "』的消息，但是$n顯然聽不懂人話。\n", me, ob);
        return 1;
    }

    if( !INQUIRY_D->parse_inquiry(me, ob, topic) )
        message_vision("$N向$n打聽有關『" + topic + "』的消息。\n", me, ob);

    if( userp(ob) )
        return 1;

    if( !living(ob) ) {
        message_vision("但是很顯然，$n現在的狀況沒有辦法給$N任何答覆。\n",
            me, ob);
        return 1;
    }

    msg = ob->query("inquiry/" + topic);
    if( stringp(msg) ) {
        message_vision(CYN "$N說道：" + msg + "\n" NOR, ob);
        return 1;
    }

    if( arrayp(msg) ) {
        for( i=0; i<sizeof(msg); i++ )
            if( stringp(msg[i]) )
                message_vision(CYN "$N說道：" + msg[i] + "\n" NOR, ob);
        return 1;
    }

    if( ob->query("name") == topic || topic=="name" || topic=="名字" ) {
        message_vision(CYN "$N對$n說道：我叫" + ob->query("name")
            + "。\n" NOR, ob, me);
        return 1;
    }

    env = environment(ob);
    if( (topic=="here" || topic=="這裡") && objectp(env) ) {
        message_vision(CYN "$n對$N說道：這裡是"
            + env->query("short") + "。\n" NOR, me, ob);
        return 1;
    }

    if( topic=="rumors" || topic=="傳聞" ) {
        message_vision(CYN "$n對$N說道：最近倒沒有什麼特別的消息。\n"
            NOR, me, ob);
        return 1;
    }

    message_vision(msg_dunno[random(sizeof(msg_dunno))], me, ob);
    return 1;
}

int help(object me)
{
    write(@HELP
指令格式：ask <someone> about <something>

這個指令用來向房間中的 NPC 打聽資訊。
NPC 可透過 set("inquiry", ([ ... ])) 提供對話主題。
HELP
    );
    return 1;
}
