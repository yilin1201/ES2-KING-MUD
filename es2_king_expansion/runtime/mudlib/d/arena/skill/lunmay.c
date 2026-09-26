// ES2-KING Expansion：冷梅劍法 Combat daemon。
// 六式名稱來自既有 gameplay evidence；未知 Original 係數不補造，attack/force/defense 全維持 0。
// 明鏡止水啟動後，依序輪轉六式，避免把未知權重偽造成機率設定。

#include <ansi.h>
inherit SKILL;

mapping *mirror_actions = ({
    ([ "name":"梅二方劍", "action":HIC "$N手中$w斜引寒芒，使出「梅二方劍」，兩道梅影一前一後點向$n的$l" NOR,
       "attack":0, "force":0, "defense":0, "damage_type":"刺傷" ]),
    ([ "name":"梅四方劍", "action":HIW "$N腕底一轉，使出「梅四方劍」，$w牽起四方寒意封向$n的$l" NOR,
       "attack":0, "force":0, "defense":0, "damage_type":"刺傷" ]),
    ([ "name":"梅八方劍", "action":HIC "$N身形微晃，使出「梅八方劍」，$w化出八方梅影籠向$n的$l" NOR,
       "attack":0, "force":0, "defense":0, "damage_type":"刺傷" ]),
    ([ "name":"愛霜恨雪", "action":HIW "$N劍意忽柔忽寒，使出「愛霜恨雪」，$w循著漫天霜意掠向$n的$l" NOR,
       "attack":0, "force":0, "defense":0, "damage_type":"割傷" ]),
    ([ "name":"寒霜三千里", "action":HIC "$N氣機一沉，使出「寒霜三千里」，$w帶起漫野霜風直取$n的$l" NOR,
       "attack":0, "force":0, "defense":0, "damage_type":"割傷" ]),
    ([ "name":"傲梅暗劍訣・傲雪藏鋒・逆折寒梅",
       "action":HIW
       "【明劍欺敵，暗劍藏殺；傲雪藏鋒・逆折寒梅。】\n"
       "$N右手$w漫天一振，以冷梅劍法陽面起勢；「梅二方劍」連環激盪，"
       "「梅四方劍」旋即封鎖四野，再接「寒霜三千里」掀起浩瀚雪幕，"
       "劍勢如千軍萬馬呼嘯而過，封住$n的視線、身位與氣機，逼得$n全力招架。\n"
       "就在$n招架用老、五感盡被暴雪遮蔽的一剎，$N右手明劍仍在風雪中牽制，"
       "左袖之下的傲梅暗劍卻已藏盡殺機——不帶風聲、不見反光，無聲無息自袖底鑽出。\n"
       HIR "——【傲梅暗劍訣・傲雪藏鋒・逆折寒梅】！\n" HIW
       "那道暗鋒如雪夜折梅般輕巧寫意，忽自明劍劍勢相逆之處折出；"
       "明劍在前欺敵，暗劍在後藏殺，真正的鋒芒直到最後一瞬才直取$n的$l！" NOR,
       // 雙手聯動與三處要害為招式敘事設定；實際命中部位仍交由 Original Combat 的 $l 決定。
       // 未知 Original 命中、傷害、穿透、Busy、寒毒與內力消耗數值仍不補造。
       "attack":0, "force":0, "defense":0, "damage_type":"刺傷" ]),
});

mapping basic_action = ([
    "name":"冷梅劍法",
    "action":CYN "$N手中$w輕顫，循冷梅劍理刺向$n的$l" NOR,
    "attack":0, "force":0, "defense":0, "damage_type":"刺傷"
]);

private void create()
{
    seteuid(getuid());
    DAEMON_D->register_skill_daemon("lunmay");
    setup();
}

int valid_enable(string usage) { return usage == "sword"; }

void attack_using(object me, object opponent, object weapon)
{
    mapping action;
    int index;

    if (!opponent) return;

    if (me->query_temp("cold_plum/mirror_state")) {
        index = me->query_temp("cold_plum/mirror_index");
        if (index < 0 || index >= sizeof(mirror_actions)) index = 0;
        action = mirror_actions[index];
        me->set_temp("cold_plum/mirror_index", (index + 1) % sizeof(mirror_actions));
        me->set_temp("cold_plum/last_form", action["name"]);
    } else {
        action = basic_action;
    }

    COMBAT_D->fight(me, opponent, "sword", action, weapon);
}
