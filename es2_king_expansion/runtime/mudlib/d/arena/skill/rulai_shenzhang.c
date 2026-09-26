/*---
description: ES2-KING 如來神掌正式 Combat Skill／只實作已定稿招式與黃色演出
---*/
#include <ansi.h>
#pragma save_binary
inherit SKILL;

// Evidence：招式名稱來自 ES2-KING Project Canon M29。
// Original ES2 未發現如來神掌 Combat Source；因此不補造傷害倍率、命中、Busy、消耗或特殊效果。
mapping *rulai_actions = ({
    ([ "name":"佛光初現", "action":HIY "$N使出如來神掌【佛光初現】，掌勢如晨曦初綻，直取$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"金頂佛燈", "action":HIY "$N使出如來神掌【金頂佛燈】，掌影如佛燈長明，直取$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"佛動山河", "action":HIY "$N使出如來神掌【佛動山河】，雙掌平推，掌勢直撼$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"佛問迦藍", "action":HIY "$N使出如來神掌【佛問迦藍】，掌意沉凝，直叩$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"迎佛西天", "action":HIY "$N使出如來神掌【迎佛西天】，掌勢迴轉，向$n的$l拍去！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"佛光普照", "action":HIY "$N使出如來神掌【佛光普照】，掌影展開，直逼$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"天佛降世", "action":HIY "$N使出如來神掌【天佛降世】，一掌自上而下壓向$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"佛鎮八荒", "action":HIY "$N使出如來神掌【佛鎮八荒】，掌勢橫掃八方，直取$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"佛法無邊", "action":HIY "$N使出如來神掌【佛法無邊】，掌勢連綿而出，攻向$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"九九歸一・萬佛朝宗", "action":HIY "$N使出如來神掌【九九歸一・萬佛朝宗】，前九佛意歸一，一掌直取$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
    ([ "name":"天舞梵輪・萬相歸墟", "action":HIY "$N使出如來神掌【天舞梵輪・萬相歸墟】，由佛入空，由空至墟，掌勢直指$n的$l！" NOR, "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]),
});

private void create()
{
    seteuid(getuid());
    // Original ES2 Combat 會透過 SKILL_D("rulai shenzhang") 尋找已登記的 Skill Daemon。
    DAEMON_D->register_skill_daemon("rulai shenzhang");
    setup();
}

int valid_enable(string usage) { return usage == "unarmed"; }

// Original ES2 feature/char/attack.c 的正式徒手 Combat 入口。
// 不自行建立第二套 heartbeat；由 Original attack() 每回合呼叫。
void attack_using(object me, object opponent, string skill)
{
    mapping action;
    int index;

    if (!opponent) return;

    index = me->query_temp("rulai/form_index");
    if (index < 0 || index >= sizeof(rulai_actions)) index = 0;
    action = rulai_actions[index];
    me->set_temp("rulai/form_index", (index + 1) % sizeof(rulai_actions));
    me->set_temp("rulai/last_form", action["name"]);

    // 不傳 weapon：如來神掌是正式 unarmed Combat。
    COMBAT_D->fight(me, opponent, "unarmed", action);
}
