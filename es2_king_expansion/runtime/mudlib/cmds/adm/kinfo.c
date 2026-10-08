/* ES2-KING 人物管理系統 V0 — owner-only, online read-only inspection.
 * V0 deliberately does not change Original ES2 attributes, save files or permissions.
 */
#include <command.h>
inherit F_CLEAN_UP;
#define KADMIN_D "/adm/daemons/kadmind"
private void create() { seteuid(getuid()); }
int main(object me, string arg)
{
    object who;
    string extra;\n    string *keys = ({ "str", "cor", "int", "spi", "cps", "dex", "con", "wis" });
    string *labels = ({ "膂力", "膽識", "悟性", "靈性", "定力", "機敏", "根骨", "慧根" });
    int i;
    SECURED_ADMIN_COMMAND;
    if (!KADMIN_D->is_owner(me))
        return notify_fail("只有 KING Owner 可使用人物管理查詢。\n");
    if (!stringp(arg) || arg == "" || sscanf(arg, "%s %s", extra, extra) == 2)
        return notify_fail("格式：kinfo <玩家帳號>\n");
    who = find_player(arg);
    if (!objectp(who) || !userp(who) || (string)who->query("id") != arg)
        return notify_fail("找不到在線玩家帳號；V0 不讀取離線存檔。\n");
    write("【ES2-KING 人物管理系統 V0】\n");
    write("帳號 (id)：" + (string)who->query("id") + "\n");
    write("名稱 (name)：" + (string)who->name() + "\n");
    write("【精氣神：當前／上限】\n");
    write(sprintf("精 (gin/max_gin)：%d / %d\n", (int)who->query("gin"), (int)who->query("max_gin")));
    write(sprintf("氣 (kee/max_kee)：%d / %d\n", (int)who->query("kee"), (int)who->query("max_kee")));
    write(sprintf("神 (sen/max_sen)：%d / %d\n", (int)who->query("sen"), (int)who->query("max_sen")));
    write("【八大基本屬性】\n");
    for (i = 0; i < sizeof(keys); i++)
        write(sprintf("%s (%s)：%d\n", labels[i], keys[i], (int)who->query_attr(keys[i], 1)));
    write(sprintf("職業 (class)：%O\n", who->query("class")));
    write(sprintf("經驗 (combat_exp)：%O\n", who->query("combat_exp")));
    write(sprintf("潛能 (potential)：%O\n", who->query("potential")));
    write("【武功技能】\n");
    write(sprintf("技能資料 (skills)：%O\n", who->query_skills()));
    write("【金錢／裝備／位置】尚待 SOURCE 欄位確認，不顯示推測數值。\n");
    return 1;
}
int help(object me)
{
    if (!KADMIN_D->is_owner(me))
        return notify_fail("沒有針對這項主題的說明文件。\n");
    write("ES2-KING 人物管理系統 V0\n用法：kinfo <玩家帳號>\n僅查詢在線人物，不修改資料。\n");
    return 1;
}
