/* ES2-KING：KING 專屬 k* 管理團隊授權。與 Original wiz_status 分離，不改寫 Original promote/security。 */
#pragma save_binary
inherit F_DBASE;
#define SAVE_FILE "/data/daemon/es2_king_kadmin"
private mapping roles = ([]);
private mapping audit_log = ([]);
private void create() { seteuid(getuid()); if (file_size(SAVE_FILE + ".o") >= 0) restore_object(SAVE_FILE); if (!mapp(audit_log)) audit_log = ([]); }
private int owner(object ob) { return objectp(ob) && interactive(ob) && ob->query("id")=="king" && wiz_level(ob)>=wiz_level("(admin)"); }
int is_owner(object ob) { return owner(ob); }
string role(object ob) { string id; if (owner(ob)) return "king"; if (!objectp(ob)) return "player"; id=ob->query("id"); return stringp(roles[id]) ? roles[id] : "player"; }
int level(object ob) { string r=role(ob); if(r=="king") return 99; if(r=="arch") return 2; if(r=="wizard") return 1; return 0; }
int can_view(object ob) { return level(ob)>=1; }
int can_arch(object ob) { return level(ob)>=2 || owner(ob); }
mapping query_roles(object actor) { if(!owner(actor)) return ([]); return copy(roles); }
int set_role(object actor,string id,string r) {
 if(!owner(actor) || !stringp(id) || id=="" || id=="king") return 0;
 if(r=="remove" || r=="player") map_delete(roles,id);
 else if(r=="wizard" || r=="arch") roles[id]=r;
 else return 0;
 save_object(SAVE_FILE); return 1;
}


/* V0 修改紀錄：只允許 KING Owner 寫入，並保存於獨立 K-admin daemon save。 */
void record(object actor, object target, string action, string field, mixed value, string result)
{
    string id;
    if(!owner(actor) || !objectp(target)) return;
    id=(string)target->query("id");
    if(!stringp(id) || id=="") return;
    if(!arrayp(audit_log[id])) audit_log[id]=({});
    audit_log[id] += ({ ([ "time":time(), "actor":(string)actor->query("id"), "target":id,
        "action":action, "field":field, "value":value, "result":result ]) });
    if(sizeof(audit_log[id])>200) audit_log[id]=audit_log[id][<200..];
    save_object(SAVE_FILE);
}

mixed query_audit(object actor, string id)
{
    if(!owner(actor) || !stringp(id)) return ([]);
    return arrayp(audit_log[id]) ? copy(audit_log[id]) : ([]);
}
