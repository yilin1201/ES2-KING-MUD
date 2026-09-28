// ES2-KING Project Canon：大邪七傷杖訣（獨立 Expansion skill id，避免覆蓋 Original chin_staff／青邪杖法）。
#include <ansi.h>
inherit SKILL;

private string *form_ids = ({ "leiting", "yaotou", "aotianmo", "yanhan", "qingtian", "xiaoku", "dingqiankun" });
private mapping form_names = ([
    "leiting":"破械反撩・雷霆震不還",
    "yaotou":"下盤重槌・搖頭嘲月老",
    "aotianmo":"回身盲刺・傲笑傲天魔",
    "yanhan":"陰煞透心・百歡催嚴寒",
    "qingtian":"凌空鎮岳・踏步踏青天",
    "xiaoku":"真氣撼地・笑哭不得也",
    "dingqiankun":"哭笑極境奧義・九曲天哭・一杖定乾坤",
]);
private mapping aliases = ([ "tianku":"dingqiankun" ]);

private void create(){ seteuid(getuid()); DAEMON_D->register_skill_daemon("daxie seveninjury staff"); setup(); }
int valid_enable(string usage){ return usage == "staff"; }

private string resolve_form(string form)
{
    if (undefinedp(form)) return 0;
    if (!undefinedp(aliases[form])) return aliases[form];
    if (!undefinedp(form_names[form])) return form;
    return 0;
}

private string form_action(string form)
{
    switch(form) {
    case "leiting": return "$N手中$w被格偏的剎那借力旋轉，杖尖如靈蛇出洞，爆出一抹淒厲寒芒，雷霆直衝$n持械手腕與小腹反撩而上！";
    case "yaotou": return "$N搖頭晃腦、怪聲尖笑，身法忽低，$w以橫掃千軍之勢化作沉重黑芒，重重槌向$n左腿膝蓋與脛骨！";
    case "aotianmo": return "$N長髮狂舞、仰天怪笑，看似背向$n，$w卻於背後劃出不可思議的弧線，九曲連環，杖尾如蠍尾毒針暴刺$n後心死穴！";
    case "yanhan": return "$N杖端大邪魔煞狂湧，剛猛重杖驟然陰寒刺骨，滿天杖影中凝成一團幽黑冰煞，直印$n胸口膻中大穴！";
    case "qingtian": return "$N平地暴起，如魔皇臨凡，居高臨下！$w帶起萬鈞黑煞罡風，化作漫天重山杖影劈頭蓋臉砸向$n！";
    case "xiaoku": return "$N忽哭忽笑、似狂似癲，雙手緊握$w，將周身大邪魔元灌注杖底狠狠砸地！轟然巨響中，大邪衝擊波席捲$n！";
    default: return "$N長嘯化作鬼哭神嚎，體內大邪魔元催至極限！滿天九曲杖影在虛空合一，化作遮天巨魔杖，自太虛之巔向$n沉重砸落！";
    }
}

void attack_using(object me, object opponent, object weapon)
{
    mapping action;
    int index;
    string form;
    if (!opponent) return;
    index = me->query_temp("es2_king/chin_staff/index");
    if (index < 0 || index >= 6) index = 0;
    form = form_ids[index];
    action = ([ "name":form_names[form], "action":HIG + form_action(form) + NOR,
        "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]);
    me->set_temp("es2_king/chin_staff/index", (index + 1) % 6);
    COMBAT_D->fight(me, opponent, "staff", action, weapon);
}

// 指定招式入口；具體 Busy、破械、真傷、斬殺等數值效果待 Runtime 平衡驗證後逐項實作，避免一次引入不可逆失衡。
int perform(object me, object target, string form)
{
    mapping action;
    object weapon;
    form = resolve_form(form);
    if (!form) return notify_fail("大邪七傷杖訣沒有這一式。\n");
    weapon = me->query_temp("weapon/staff");
    if (!objectp(weapon)) return notify_fail("你必須裝備杖類武器才能施展大邪七傷杖訣。\n");
    if (!target) target = me->select_opponent();
    if (!target) return notify_fail("你目前沒有可攻擊的目標。\n");
    action = ([ "name":form_names[form], "action":HIG + form_action(form) + NOR,
        "attack":0, "force":0, "defense":0, "damage_type":"瘀傷" ]);
    COMBAT_D->fight(me, target, "staff", action, weapon);
    return 1;
}
