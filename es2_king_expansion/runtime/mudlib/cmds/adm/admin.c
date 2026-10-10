/*
 * ES2-KING Expansion／管理員 GM 指令整合層。
 * 參考來源：ES2-KDS cmds/adm/admin.c（不是 Original ES2 已確認的原生指令）。
 * 上游來源 Blob SHA：463259b74a897c28c199682caa5af21074bf69b1。
 * 本檔只透過 es2_king_expansion/runtime/mudlib 套用至獨立 Runtime，
 * 不覆寫 Original ES2 保存來源；實際 LPC/Neolith 行為仍須由測試確認。
 */
#include <command.h>
#include <ansi.h>
#include <attribute.h>  /* Original ES2 屬性範圍：ATTRVAL_MIN=1、ATTRVAL_MAX=50。 */

inherit F_CLEAN_UP;

/* Original ES2 source-verified limits／原版原始碼已確認的數值範圍。 */
#define ADMIN_SKILL_MAX 200  /* mudlib/feature/char/skill.c 的 set_skill/query_skill 上限。 */
#define ADMIN_LEVEL_MAX 999 /* mudlib/feature/char/score.c 的 set_level 上限。 */

/*
 * Command objects under /cmds/ get UID "Root" but start with EUID 0.
 * With EUID 0 every write on a user object (set_skill, set_learn, set_attr,
 * set_stat_maximum ...) is rejected by USER_PROTECT() with a runtime error,
 * and error_handler() is disabled in master.c, so the player sees nothing.
 */
private void create()
{
    seteuid(getuid());
}

/*
 * file_size() needs the real file name, so "/custom/weapon/blade/tiger_blade"
 * must be tried as ".../tiger_blade.c". Returns 0 if no such file exists.
 */
private string object_file(string path)
{
    if (!stringp(path) || !sizeof(path))
        return 0;
    if (path[0] != '/')
        path = "/" + path;
    if (file_size(path) >= 0)
        return path;
    if (path[<2..] != ".c" && file_size(path + ".c") >= 0)
        return path + ".c";
    return 0;
}

private object target_player(object me, string name)
{
    object ob;

    if (!stringp(name) || !sizeof(name))
        return me;

    /* 只接受真正在線的玩家，避免 find_living 把 NPC 誤認為可修改目標。 */
    ob = find_player(name);
    if (!objectp(ob) || !interactive(ob))
        return 0;

    return ob;
}

private object mutable_target(object me, string name)
{
    object ob;

    ob = target_player(me, name);
    if (!objectp(ob))
        return 0;

    /* 角色資料修改不得作用於其他最高管理員；自己仍可操作自己的角色。 */
    if (ob != me && wiz_level(ob) >= wiz_level("(admin)"))
        return 0;

    return ob;
}

private void show_help()
{
    write(@HELP
============================================================
ES2-KDS ADMIN GM 使用教學
============================================================

【如何開啟】
  help admin
  admin help

【一、玩家管理】
  admin inspect                 查看自己的角色資料
  admin inspect <玩家>          查看在線玩家資料
  admin list                    列出在線玩家
  admin goto <玩家>             傳送到玩家所在房間
  admin save                    保存自己的角色資料
  admin save <玩家>             保存指定在線玩家資料
HELP
    );

    write(@HELP

【二、精／氣／神】
  admin gin <數值> [玩家]       設定精
  admin kee <數值> [玩家]       設定氣
  admin sen <數值> [玩家]       設定神
  admin stats <數值> [玩家]     同時設定精、氣、神

【三、八大屬性】
  admin str <數值> [玩家]       膂力（原版 1～50）
  admin cor <數值> [玩家]       膽識（原版 1～50）
  admin cps <數值> [玩家]       定力（原版 1～50）
  admin int <數值> [玩家]       悟性（原版 1～50）
  admin wis <數值> [玩家]       慧根（原版 1～50）
  admin spi <數值> [玩家]       靈性（原版 1～50）
  admin con <數值> [玩家]       根骨（原版 1～50）
  admin dex <數值> [玩家]       機敏（原版 1～50）
  admin attrs <數值> [玩家]     一次設定八大屬性（原版 1～50）
HELP
    );

    write(@HELP

【四、技能管理】
  admin skill <技能> <等級> [玩家]
                                設定指定技能等級（原版 0～200）
  admin skills <等級> [玩家]    設定核心技能等級（原版 0～200）
  admin learn <技能> [玩家]     設定為已學會
  admin unlearn <技能> [玩家]   取消學習並解除對應

【五、HP 與恢復】
  admin hp <數值> [玩家]        設定目前 HP
  admin maxhp <數值> [玩家]     設定最大 HP，並補滿 HP
  admin heal                    恢復自己的 HP／精／氣／神
  admin heal <玩家>             恢復指定在線玩家
HELP
    );

    write(@HELP

【六、物品與武器】
  admin give <物件路徑>         生成物品並給自己
  admin give <物件路徑> <玩家>  生成物品並給指定在線玩家
  admin wield <武器ID>          裝備自己身上的武器

  虎紋刀物件路徑：
  /custom/weapon/blade/tiger_blade

  生成虎紋刀：
  admin give /custom/weapon/blade/tiger_blade

  裝備虎紋刀：
  admin wield tiger blade
HELP
    );

    write(@HELP

【七、技能啟用】
  admin enable <技能>            啟用自己已學會的技能
  admin enable <技能> <玩家>     啟用指定玩家已學會的技能
  admin enable <用途> with <技能> [玩家]
                                設定技能對應（請以實際遊戲結果確認）

【八、角色等級】
  admin level <等級> [玩家]      設定角色等級（原版 1～999）

【常用操作範例】
  admin setup                    套用管理員標準設定並保存
  admin inspect
  admin stats 999
  admin attrs 50
  admin skill blade 200
  admin learn tiger-blade
  admin skill tiger-blade 200
  admin give /custom/weapon/blade/tiger_blade
  admin wield tiger blade
  admin heal
  admin save
  admin inspect
HELP
    );

    write(@HELP

【使用注意】
  1. 方括號 [玩家] 代表可選填；不填時通常操作自己。
  2. 指定玩家必須在線，離線角色不能由這些指令直接修改。
  3. 技能等級與 learn 狀態是不同設定；需要時兩者都要設定。
  4. 修改後請使用 admin save 保存角色資料。
  5. 原 ES2 指令與一般 help 主題不應被此教學取代。
  6. 此教學只列出目前 admin 指令的使用方式；實際效果仍須在遊戲內驗證。

============================================================
HELP
    );
}

private void show_status(object ob)
{
    string *skills;
    mapping attrs;
    string s;

    if (!objectp(ob))
        return;

    attrs = ob->query_attribute();

    write("\n================ ADMIN INSPECT ================\n");
    printf("ID      : %s\n", (string)ob->query("id"));
    printf("NAME    : %s\n", (string)ob->name(1));
    printf("RACE    : %s\n", (string)ob->query_race());
    printf("CLASS   : %s\n", (string)ob->query_class());
    printf("LEVEL   : %d\n", (int)ob->query_level());

    printf("HP      : %d / %d\n",
        (int)ob->query_stat_current("HP"),
        (int)ob->query_stat_maximum("HP"));

    printf("GIN     : %d / %d\n",
        (int)ob->query_stat_current("gin"),
        (int)ob->query_stat_maximum("gin"));

    printf("KEE     : %d / %d\n",
        (int)ob->query_stat_current("kee"),
        (int)ob->query_stat_maximum("kee"));

    printf("SEN     : %d / %d\n",
        (int)ob->query_stat_current("sen"),
        (int)ob->query_stat_maximum("sen"));

    write("\nATTRIBUTES\n");
    foreach (s in ({ "str", "cor", "int", "spi", "cps", "dex", "con", "wis" }))
        printf("  %-3s : %d\n", s, (int)ob->query_attr(s, 1));

    write("\nKEY SKILLS\n");
    skills = ({ "blade", "force", "parry", "dodge",
                "tiger-blade", "tiger-force", "tiger-steps" });

    foreach (s in skills)
        printf("  %-15s : %d\n", s, (int)ob->query_skill(s));

    write("================================================\n");
}

private int set_stat(object ob, string stat, int value)
{
    if (!objectp(ob))
        return 0;

    if (value < 0)
        return 0;

    ob->set_stat_maximum(stat, value);
    ob->set_stat_effective(stat, value);
    ob->set_stat_current(stat, value);

    /* Confirm the character object accepted the requested values. */
    if ((int)ob->query_stat_maximum(stat) != value
    ||  (int)ob->query_stat_effective(stat) != value
    ||  (int)ob->query_stat_current(stat) != value)
        return 0;

    return 1;
}

int main(object me, string arg)
{
    string cmd, value_s, target_name, skill;
    int value;
    object ob, gift, weapon;
    object *players;

    /*
     * Keep the GM command restricted to a direct player command and the
     * configured admin wizard level. Use explicit feedback instead of
     * notify_fail here so web clients never appear to silently ignore it.
     */
    if (!objectp(me) || previous_object() != me || this_player(1) != me) {
        if (objectp(me))
            tell_object(me, "ADMIN: 指令呼叫來源驗證失敗。\n");
        return 1;
    }

    if (wiz_level(me) < wiz_level("(admin)")) {
        tell_object(me, "ADMIN: 你沒有管理員權限。\n");
        return 1;
    }

    /* Authorization passed: restore full EUID (the "give" branch lowers it). */
    seteuid(getuid());

    /*
     * WebMUD bridges may forward either only the arguments or the complete
     * command text. Normalize both forms before dispatching subcommands.
     */
    if (stringp(arg) && sscanf(arg, "admin %s", value_s) == 1)
        arg = value_s;

    /* Dispatch probe for verifying command entry and argument forwarding. */
    if (stringp(arg) && (arg == "probe" || arg == "trace")) {
        tell_object(me, "ADMIN PROBE: main() reached; arg=[" + arg +
            "]; id=" + (string)me->query("id") +
            "; wiz=" + wiz_level(me) + "/" + wiz_level("(admin)") + "\n");
        return 1;
    }
    if (!stringp(arg) || !sizeof(arg)) {
        show_help();
        return 1;
    }

    /*
     * Optional target is always the last word.
     * This keeps the common self-editing syntax short:
     *   admin gin 999
     *   admin skill blade 200
     */

    if (sscanf(arg, "learn %s %s", skill, target_name) == 2) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        ob->set_learn(skill, 1);
        printf("ADMIN: %s 已學會 %s。\n", ob->query("id"), skill);
        return 1;
    }

    if (sscanf(arg, "learn %s", skill) == 1) {
        me->set_learn(skill, 1);
        printf("ADMIN: 已學會 %s。\n", skill);
        return 1;
    }

    if (sscanf(arg, "unlearn %s %s", skill, target_name) == 2) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        ob->set_learn(skill, 0);
        ob->map_skill(skill, "none");
        printf("ADMIN: %s 已取消學會 %s。\n", ob->query("id"), skill);
        return 1;
    }

    if (sscanf(arg, "unlearn %s", skill) == 1) {
        me->set_learn(skill, 0);
        me->map_skill(skill, "none");
        printf("ADMIN: 已取消學會 %s。\n", skill);
        return 1;
    }

    if (sscanf(arg, "skill %s %d %s", skill, value, target_name) == 3) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        if (value < 0 || value > ADMIN_SKILL_MAX) return notify_fail("技能等級須介於 0～200（Original ES2 原版上限）。\n");
        ob->set_skill(skill, value);
        printf("ADMIN: %s 的 %s = %d\n", ob->query("id"), skill, value);
        return 1;
    }

    if (sscanf(arg, "skill %s %d", skill, value) == 2) {
        if (value < 0 || value > ADMIN_SKILL_MAX) return notify_fail("技能等級須介於 0～200（Original ES2 原版上限）。\n");
        me->set_skill(skill, value);
        printf("ADMIN: %s = %d\n", skill, value);
        return 1;
    }

    if (sscanf(arg, "skills %d %s", value, target_name) == 2) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        if (value < 0 || value > ADMIN_SKILL_MAX) return notify_fail("技能等級須介於 0～200（Original ES2 原版上限）。\n");
        foreach (skill in ({ "blade", "force", "parry", "dodge",
                             "tiger-blade", "tiger-force", "tiger-steps" }))
            ob->set_skill(skill, value);
        printf("ADMIN: %s 核心技能全部設定為 %d。\n", ob->query("id"), value);
        return 1;
    }

    if (sscanf(arg, "skills %d", value) == 1) {
        if (value < 0 || value > ADMIN_SKILL_MAX) return notify_fail("技能等級須介於 0～200（Original ES2 原版上限）。\n");
        foreach (skill in ({ "blade", "force", "parry", "dodge",
                             "tiger-blade", "tiger-force", "tiger-steps" }))
            me->set_skill(skill, value);
        printf("ADMIN: 核心技能全部設定為 %d。\n", value);
        return 1;
    }

    if (sscanf(arg, "stats %d %s", value, target_name) == 2) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        if (value < 0) return notify_fail("數值不可小於 0。\n");
        foreach (cmd in ({ "gin", "kee", "sen" }))
            if (!set_stat(ob, cmd, value))
                return notify_fail("精氣神設定失敗；請使用 admin inspect 核對。\n");
        printf("ADMIN: %s 精氣神全部設定為 %d。\n", ob->query("id"), value);
        return 1;
    }

    if (sscanf(arg, "stats %d", value) == 1) {
        if (value < 0) return notify_fail("數值不可小於 0。\n");
        foreach (cmd in ({ "gin", "kee", "sen" }))
            if (!set_stat(me, cmd, value))
                return notify_fail("精氣神設定失敗；請使用 admin inspect 核對。\n");
        printf("ADMIN: 精氣神全部設定為 %d。\n", value);
        return 1;
    }

    if (sscanf(arg, "attrs %d %s", value, target_name) == 2) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        if (value < ATTRVAL_MIN || value > ATTRVAL_MAX) return notify_fail("屬性數值須介於 1～50（Original ES2 原版範圍）。\n");
        foreach (cmd in ({ "str", "cor", "int", "spi", "cps", "dex", "con", "wis" }))
            ob->set_attr(cmd, value);
        foreach (cmd in ({ "str", "cor", "int", "spi", "cps", "dex", "con", "wis" }))
            if ((int)ob->query_attr(cmd, 1) != value)
                return notify_fail("屬性設定未完全生效；請使用 admin inspect 核對。\n");
        printf("ADMIN: %s 八大屬性已驗證設定為 %d。\n", ob->query("id"), value);
        return 1;
    }

    if (sscanf(arg, "attrs %d", value) == 1) {
        if (value < ATTRVAL_MIN || value > ATTRVAL_MAX) return notify_fail("屬性數值須介於 1～50（Original ES2 原版範圍）。\n");
        foreach (cmd in ({ "str", "cor", "int", "spi", "cps", "dex", "con", "wis" }))
            me->set_attr(cmd, value);
        foreach (cmd in ({ "str", "cor", "int", "spi", "cps", "dex", "con", "wis" }))
            if ((int)me->query_attr(cmd, 1) != value)
                return notify_fail("屬性設定未完全生效；請使用 admin inspect 核對。\n");
        printf("ADMIN: 八大屬性已驗證設定為 %d。\n", value);
        return 1;
    }

    /*
     * Use fixed sscanf formats for stat commands to avoid dynamic formats.
     */
    if (sscanf(arg, "%s %d %s", cmd, value, target_name) == 3) {
        if (member_array(cmd, ({ "gin", "kee", "sen" })) != -1) {
            ob = target_player(me, target_name);
            if (!ob)
                return notify_fail("找不到玩家。\n");
            if (!set_stat(ob, cmd, value))
                return notify_fail("設定失敗。\n");
            printf("ADMIN: %s %s = %d\n", ob->query("id"), cmd, value);
            return 1;
        }
    }

    if (sscanf(arg, "%s %d", cmd, value) == 2) {
        if (member_array(cmd, ({ "gin", "kee", "sen" })) != -1) {
            if (!set_stat(me, cmd, value))
                return notify_fail("設定失敗。\n");
            printf("ADMIN: %s = %d\n", cmd, value);
            return 1;
        }
    }

    /*
     * Parse attribute commands with fixed sscanf formats for LPC compatibility.
     */
    if (sscanf(arg, "%s %d %s", cmd, value, target_name) == 3) {
        if (member_array(cmd, ({ "str", "cor", "int", "spi", "cps",
                                 "dex", "con", "wis" })) != -1) {
            ob = target_player(me, target_name);
            if (!ob)
                return notify_fail("找不到玩家。\n");
            if (value < ATTRVAL_MIN || value > ATTRVAL_MAX)
                return notify_fail("屬性數值須介於 1～50（Original ES2 原版範圍）。\n");
            ob->set_attr(cmd, value);
            if ((int)ob->query_attr(cmd, 1) != value)
                return notify_fail("屬性設定失敗；請確認數值範圍。\n");
            printf("ADMIN: %s %s = %d\n", ob->query("id"), cmd, value);
            return 1;
        }
    }

    if (sscanf(arg, "%s %d", cmd, value) == 2) {
        if (member_array(cmd, ({ "str", "cor", "int", "spi", "cps",
                                 "dex", "con", "wis" })) != -1) {
            if (value < ATTRVAL_MIN || value > ATTRVAL_MAX)
                return notify_fail("屬性數值須介於 1～50（Original ES2 原版範圍）。\n");
            me->set_attr(cmd, value);
            if ((int)me->query_attr(cmd, 1) != value)
                return notify_fail("屬性設定失敗；請確認數值範圍。\n");
            printf("ADMIN: %s = %d\n", cmd, value);
            return 1;
        }
    }

    if (sscanf(arg, "level %d %s", value, target_name) == 2) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        if (value < 1 || value > ADMIN_LEVEL_MAX) return notify_fail("角色等級須介於 1～999（Original ES2 原版範圍）。\n");
        ob->set_level(value);
        printf("ADMIN: %s 等級 = %d\n", ob->query("id"), value);
        return 1;
    }

    if (sscanf(arg, "level %d", value) == 1) {
        if (value < 1 || value > ADMIN_LEVEL_MAX) return notify_fail("角色等級須介於 1～999（Original ES2 原版範圍）。\n");
        me->set_level(value);
        printf("ADMIN: 等級 = %d\n", value);
        return 1;
    }

    if (sscanf(arg, "inspect %s", target_name) == 1) {
        ob = target_player(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        show_status(ob);
        return 1;
    }

    if (arg == "inspect") {
        show_status(me);
        return 1;
    }

    if (arg == "heal") {
        foreach (cmd in ({ "HP", "gin", "kee", "sen" })) {
            value = (int)me->query_stat_maximum(cmd);
            me->set_stat_effective(cmd, value);
            me->set_stat_current(cmd, value);
        }
        write("ADMIN: HP / 精 / 氣 / 神 已完全恢復。\n");
        return 1;
    }

    if (sscanf(arg, "save %s", target_name) == 1) {
        ob = target_player(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        if (ob->save())
            printf("ADMIN: %s 人物資料已保存。\n", ob->query("id"));
        else
            printf("ADMIN: %s 人物資料保存失敗。\n", ob->query("id"));
        return 1;
    }

    if (arg == "save") {
        if (me->save())
            write("ADMIN: 人物資料已保存。\n");
        else
            write("ADMIN: 人物資料保存失敗。\n");
        return 1;
    }

    if (sscanf(arg, "give %s %s", value_s, target_name) == 2) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        if (!(skill = object_file(value_s)))
            return notify_fail("找不到物件：" + value_s + "\n");
        gift = new(skill);
        /* move() returns 1 on success and 0 on failure. */
        if (!objectp(gift) || !gift->move(ob))
            return notify_fail("物件生成或移動失敗。\n");
        printf("ADMIN: %s 已取得 %s。\n", ob->query("id"), gift->name(1));
        return 1;
    }

    if (sscanf(arg, "give %s", value_s) == 1) {
        if (!(skill = object_file(value_s)))
            return notify_fail("找不到物件：" + value_s + "\n");
        gift = new(skill);
        /* move() returns 1 on success and 0 on failure. */
        if (!objectp(gift) || !gift->move(me))
            return notify_fail("物件生成或移動失敗。\n");
        printf("ADMIN: 已取得 %s。\n", gift->name(1));
        return 1;
    }

    if (sscanf(arg, "enable %s with %s %s", cmd, skill, target_name) == 3) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        if (!ob->query_learn(skill))
            return notify_fail("目標尚未學會此技能；請先使用既有學習系統。\n");
        /* 用途是第一個參數、技能是第二個參數，避免把技能映射到自己。 */
        ob->map_skill(cmd, skill);
        printf("ADMIN: %s 已將用途 %s 對應至技能 %s。\n",
            ob->query("id"), cmd, skill);
        return 1;
    }

    /* 不指定玩家時，直接設定自己的用途與技能對應。 */
    if (sscanf(arg, "enable %s with %s", cmd, skill) == 2) {
        if (!me->query_learn(skill))
            return notify_fail("你尚未學會此技能；請先使用既有學習系統。\n");
        me->map_skill(cmd, skill);
        printf("ADMIN: 已將用途 %s 對應至技能 %s。\n", cmd, skill);
        return 1;
    }

    if (sscanf(arg, "enable %s %s", cmd, target_name) == 2) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        if (!ob->query_learn(cmd))
            return notify_fail("目標尚未學會此技能；請先使用既有學習系統。\n");
        ob->map_skill(cmd);
        printf("ADMIN: %s 已 enable %s。\n", ob->query("id"), cmd);
        return 1;
    }

    if (sscanf(arg, "enable %s", cmd) == 1) {
        if (!me->query_learn(cmd))
            return notify_fail("你尚未學會此技能；請先使用既有學習系統。\n");
        me->map_skill(cmd);
        printf("ADMIN: 已 enable %s。\n", cmd);
        return 1;
    }

    /*
     * Weapon ids may contain a space ("tiger blade"), so first try the whole
     * text as an item on yourself; only otherwise read the last word as the
     * target player.
     */
    if (sscanf(arg, "wield %s", cmd) == 1
    &&  (objectp(present(cmd, me))
         || objectp(present(replace_string(cmd, "_", " "), me)))) {
        weapon = present(cmd, me);
        if (!objectp(weapon))
            weapon = present(replace_string(cmd, "_", " "), me);
        if (!weapon->wield())
            return notify_fail("武器裝備失敗。\n");
        printf("ADMIN: 已裝備 %s。\n", weapon->name(1));
        return 1;
    }

    if (sscanf(arg, "wield %s %s", cmd, target_name) == 2) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        weapon = present(cmd, ob);
        if (!objectp(weapon))
            weapon = present(replace_string(cmd, "_", " "), ob);
        if (!objectp(weapon))
            return notify_fail("目標身上找不到：" + cmd + "\n");
        if (!weapon->wield())
            return notify_fail("武器裝備失敗。\n");
        printf("ADMIN: %s 已裝備 %s。\n", ob->query("id"), weapon->name(1));
        return 1;
    }

    if (sscanf(arg, "wield %s", cmd) == 1) {
        weapon = present(cmd, me);
        if (!objectp(weapon))
            return notify_fail("你身上找不到：" + cmd + "\n");
        if (!weapon->wield())
            return notify_fail("武器裝備失敗。\n");
        printf("ADMIN: 已裝備 %s。\n", weapon->name(1));
        return 1;
    }

    if (sscanf(arg, "hp %d %s", value, target_name) == 2) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        if (value < 0) return notify_fail("HP 不可小於 0。\n");
        /* score's HP bar assumes current <= maximum; larger values break it. */
        if (value > (int)ob->query_stat_maximum("HP"))
            value = (int)ob->query_stat_maximum("HP");
        ob->set_stat_current("HP", value);
        printf("ADMIN: %s HP = %d。\n", ob->query("id"), value);
        return 1;
    }

    if (sscanf(arg, "hp %d", value) == 1) {
        if (value < 0) return notify_fail("HP 不可小於 0。\n");
        /* score's HP bar assumes current <= maximum; larger values break it. */
        if (value > (int)me->query_stat_maximum("HP"))
            value = (int)me->query_stat_maximum("HP");
        me->set_stat_current("HP", value);
        printf("ADMIN: HP = %d（不可超過最大 HP；要提高上限請用 admin maxhp）。\n", value);
        return 1;
    }

    if (sscanf(arg, "maxhp %d %s", value, target_name) == 2) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        if (value < 1) return notify_fail("最大 HP 必須大於 0。\n");
        /* maximum, effective and current must move together (see set_stat). */
        if (!set_stat(ob, "HP", value))
            return notify_fail("最大 HP 設定失敗。\n");
        printf("ADMIN: %s 最大 HP = %d。\n", ob->query("id"), value);
        return 1;
    }

    if (sscanf(arg, "maxhp %d", value) == 1) {
        if (value < 1) return notify_fail("最大 HP 必須大於 0。\n");
        if (!set_stat(me, "HP", value))
            return notify_fail("最大 HP 設定失敗。\n");
        printf("ADMIN: 最大 HP = %d。\n", value);
        return 1;
    }

    if (arg == "heal") {
        ob = me;
        foreach (cmd in ({ "HP", "gin", "kee", "sen" })) {
            value = (int)ob->query_stat_maximum(cmd);
            ob->set_stat_effective(cmd, value);
            ob->set_stat_current(cmd, value);
        }
        write("ADMIN: HP / 精 / 氣 / 神 已完全恢復。\n");
        return 1;
    }

    if (sscanf(arg, "heal %s", target_name) == 1) {
        ob = mutable_target(me, target_name);
        if (!ob) return notify_fail("找不到玩家。\n");
        foreach (cmd in ({ "HP", "gin", "kee", "sen" })) {
            value = (int)ob->query_stat_maximum(cmd);
            ob->set_stat_effective(cmd, value);
            ob->set_stat_current(cmd, value);
        }
        printf("ADMIN: %s 已完全恢復。\n", ob->query("id"));
        return 1;
    }

    if (arg == "list") {
        players = users();
        write("ONLINE PLAYERS:\n");
        foreach (ob in players)
            printf("  %-16s %s\n", ob->query("id"), ob->name(1));
        return 1;
    }

    if (sscanf(arg, "goto %s", target_name) == 1) {
        ob = target_player(me, target_name);
        if (!ob || !environment(ob))
            return notify_fail("找不到玩家或玩家沒有所在房間。\n");
        if (!me->move(environment(ob)))
            return notify_fail("傳送失敗。\n");
        write("ADMIN: 已傳送至目標玩家所在房間。\n");
        return 1;
    }

    /* One-shot standard setup for the dedicated admin character.
     * Uses existing ES2 character APIs and saves after verification.
     */
    if (arg == "setup") {
        foreach (cmd in ({ "gin", "kee", "sen" })) {
            if (!set_stat(me, cmd, 999))
                return notify_fail("ADMIN: 精氣神設定失敗，未完成設定。\n");
        }

        foreach (skill in ({ "blade", "force", "parry", "dodge",
                             "tiger-blade", "tiger-force", "tiger-steps" })) {
            me->set_learn(skill, 1);
            me->set_skill(skill, 200);
        }

        /* Keep the custom tiger blade on the character; create only if absent. */
        weapon = present("tiger blade", me);
        if (!objectp(weapon))
            weapon = present("tiger_blade", me);
        if (!objectp(weapon)) {
            value_s = object_file("/custom/weapon/blade/tiger_blade");
            if (!value_s)
                return notify_fail("ADMIN: 找不到虎紋刀物件，精氣神與技能已設定；武器未建立。\n");
            gift = new(value_s);
            /* move() returns 1 on success and 0 on failure. */
            if (!objectp(gift) || !gift->move(me))
                return notify_fail("ADMIN: 虎紋刀生成／放入背包失敗。\n");
            weapon = gift;
        }

        if (objectp(weapon))
            weapon->wield();

        if (!me->save())
            return notify_fail("ADMIN: 設定已套用，但人物存檔失敗；請使用 admin inspect 核對。\n");

        show_status(me);
        tell_object(me, "ADMIN SETUP OK: 精／氣／神=999；核心技能=200；虎紋刀已確認；人物資料已保存。\n");
        return 1;
    }

    if (arg == "help") {
        show_help();
        return 1;
    }

    tell_object(me, "ADMIN: 未知的子指令 [" + (stringp(arg) ? arg : "<null>") +
        "]。輸入 admin help 查看用法。\n");
    return 1;
}

int help(object me)
{
    show_help();
    return 1;
}
