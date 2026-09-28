// ES2-KING Project Canon：大邪七損刀訣；正式 Skill ID：qisun_blade。
#include <ansi.h>
inherit SKILL;
private string *forms=({"leiting","aotianmo","tougu","xiaoku","wuchang","juexi","qisun"});
private mapping names=(["leiting":"雷霆震不還・損皮","aotianmo":"傲笑傲天魔・損肉","tougu":"寒霜透骨・損筋","xiaoku":"笑哭不得也・損骨","wuchang":"哭笑無常刀・損脈","juexi":"大邪絕息斬・損氣","qisun":"七損合一・命魂俱滅"]);
private mapping aliases=(["sunpi":"leiting","sunrou":"aotianmo","sunjin":"tougu","sungu":"xiaoku","sunmai":"wuchang","sunqi":"juexi","destroy":"qisun"]);
private void create(){seteuid(getuid());DAEMON_D->register_skill_daemon("qisun_blade");setup();}
int valid_enable(string usage){return usage=="blade";}
private string resolve(string f){if(!undefinedp(aliases[f]))return aliases[f];if(!undefinedp(names[f]))return f;return 0;}
private string action_text(string f){return "$N手中$w運起「"+names[f]+"」，刀勢挾著大邪真氣直取$n！";}
void attack_using(object me,object opponent,object weapon){mapping a;string f;if(!opponent)return;f=forms[random(sizeof(forms))];a=(["name":names[f],"action":HIG+action_text(f)+NOR,"attack":0,"force":0,"defense":0,"damage_type":"割傷"]);COMBAT_D->fight(me,opponent,"blade",a,weapon);}
// perform 未指定有效招式時，先依使用者定稿採七式隨機出招；指定 alias 時仍可精確施展。
int perform(object me,object target,string form){mapping a;object weapon;string f;f=resolve(form);if(!f)f=forms[random(sizeof(forms))];weapon=me->query_temp("weapon/blade");if(!objectp(weapon))return notify_fail("你必須裝備刀類武器才能施展大邪七損刀訣。\n");if(!target)target=me->select_opponent();if(!target)return notify_fail("你目前沒有可攻擊的目標。\n");a=(["name":names[f],"action":HIG+action_text(f)+NOR,"attack":0,"force":0,"defense":0,"damage_type":"割傷"]);COMBAT_D->fight(me,target,"blade",a,weapon);return 1;}
