/* ES2-KING 人物管理系統 V0：所有 k* 人物修改共用的安全 API。 */
#pragma save_binary
inherit F_DBASE;
#define KADMIN_D "/adm/daemons/kadmind"
#define KING_D "/adm/daemons/kingd"
#define SAVE_FILE "/data/daemon/es2_king_kcharadmin"
private mixed *audit_log = ({});
private void create(){seteuid(getuid());if(file_size(SAVE_FILE+".o")>=0)restore_object(SAVE_FILE);}
private int owner(object a){return objectp(a)&&interactive(a)&&a->query("id")=="king"&&wiz_level(a)>=wiz_level("(admin)")&&KADMIN_D->is_owner(a);}
int authorized(object a){return owner(a);}
object resolve_target(object a,string id){object o;if(!owner(a)||!stringp(id)||id=="")return 0;o=find_player(id);if(!objectp(o)||!userp(o)||(string)o->query("id")!=id)return 0;return o;}
private void audit(string a,string t,string action,string oldv,string newv){audit_log+=({(["time":time(),"actor":a,"target":t,"action":action,"old":oldv,"new":newv])});if(sizeof(audit_log)>300)audit_log=audit_log[<300..];save_object(SAVE_FILE);}
mapping *query_audit(object a,string who){mapping *out=({});mapping r;if(!owner(a))return out;foreach(r in audit_log)if(!stringp(who)||who==""||r["target"]==who)out+=({copy(r)});return out;}
int set_attribute(object a,object o,string attr,int v){int old;if(!owner(a)||!objectp(o)||member_array(attr,({"str","cor","int","spi","cps","dex","con","wis"}))<0||v<1||v>99)return 0;old=o->query_attr(attr,1);if(!o->set_attr(attr,v)&&o->query_attr(attr,1)!=v)return 0;audit((string)a->query("id"),(string)o->query("id"),"attribute:"+attr,sprintf("%d",old),sprintf("%d",v));return o->query_attr(attr,1)==v;}
int set_stat(object a,object o,string st,int v){int old;if(!owner(a)||!objectp(o)||member_array(st,({"gin","kee","sen"}))<0||v<1||v>999)return 0;old=o->query_stat_maximum(st);if(!o->set_stat_maximum(st,v)&&o->query_stat_maximum(st)!=v)return 0;o->set_stat_effective(st,v);o->set_stat_current(st,v);audit((string)a->query("id"),(string)o->query("id"),"stat:"+st,sprintf("%d",old),sprintf("%d",v));return o->query_stat_maximum(st)==v;}
int set_skill_level(object a,object o,string sk,int v){int old;if(!owner(a)||!objectp(o)||!stringp(sk)||strsrch(sk,"/")>=0||strsrch(sk,".")>=0||v<0||v>300)return 0;
    if(file_size("/daemon/skill/"+sk+".c")<0 && file_size("/daemon/skill/"+replace_string(sk," ","_")+".c")<0)return 0;old=o->query_skill(sk,1);o->set_skill(sk,v);if(o->query_skill(sk,1)!=v)return 0;audit((string)a->query("id"),(string)o->query("id"),"skill:"+sk,sprintf("%d",old),sprintf("%d",v));return 1;}
int set_class(object a,object o,string cl){string old;if(!owner(a)||!objectp(o)||!stringp(cl)||cl==""||strsrch(cl,"/")>=0||strsrch(cl,".")>=0||file_size("/daemon/class/"+cl+".c")<0)return 0;old=o->query_class();if(!o->set_class(cl)||o->query_class()!=cl)return 0;audit((string)a->query("id"),(string)o->query("id"),"class",old,cl);return 1;}
int change_score_field(object a,object o,string f,string op,int v){int old,n;if(!owner(a)||!objectp(o)||member_array(f,({"combat_exp","potential"}))<0||v<0)return 0;old=(int)o->query(f);if(op=="add")n=old+v;else if(op=="set")n=v;else return 0;if(n<0)return 0;o->set(f,n);audit((string)a->query("id"),(string)o->query("id"),f,sprintf("%d",old),sprintf("%d",n));return (int)o->query(f)==n;}
private int money_value(object o){object x;int n=0;x=present("gold_money",o);if(x)n+=(int)x->value();x=present("silver_money",o);if(x)n+=(int)x->value();x=present("coin_money",o);if(x)n+=(int)x->value();return n;}
private void money_amount(object o,string t,int n){object x=present(t+"_money",o);if(n<=0){if(x)x->set_amount(0);return;}if(!x){x=new("/obj/money/"+t);if(!objectp(x)||!x->move(o)){if(objectp(x))destruct(x);error("kcharadmin: money move failed");}}x->set_amount(n);}
int change_money(object a,object o,string op,int v){int old,n,g,s,c;if(!owner(a)||!objectp(o)||v<0)return 0;old=money_value(o);if(op=="add")n=old+v;else if(op=="set")n=v;else return 0;g=n/10000;n%=10000;s=n/100;c=n%100;money_amount(o,"gold",g);money_amount(o,"silver",s);money_amount(o,"coin",c);n=money_value(o);audit((string)a->query("id"),(string)o->query("id"),"money",sprintf("%d",old),sprintf("%d",n));return n==(op=="set"?v:old+v);}
int give_item(object a,object o,string id){object x;string p;if(!owner(a)||!objectp(o)||!stringp(id)||id==""||strsrch(id,"..")>=0)return 0;p=id[0..0]=="/"?id:"/obj/"+id;if(p[0..4]!="/obj/"||file_size(p)<0&&file_size(p+".c")<0)return 0;if(p[<2..]!=".c")p+=".c";x=new(p);if(!objectp(x)||!x->move(o)){if(objectp(x))destruct(x);return 0;}audit((string)a->query("id"),(string)o->query("id"),"item",id,id);return 1;}
int save_target(object a,object o){if(!owner(a)||!objectp(o)||!o->save())return 0;audit((string)a->query("id"),(string)o->query("id"),"save","dirty","saved");return 1;}
