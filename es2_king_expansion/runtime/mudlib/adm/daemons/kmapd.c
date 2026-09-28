/* ES2-KING：Evidence-bounded 特殊房間 Action Registry。只登錄已由 Original Source 證明的互動。 */
#pragma save_binary
inherit F_CLEAN_UP;
private mapping actions=([
 "/d/snow/square":({
   ([ "verb":"climb","arg":"榕樹","handler":"do_climb","target":"/d/snow/tree","evidence":"Original /d/snow/square.c init()+do_climb()" ])
 })
]);
private void create(){seteuid(getuid());}
mixed query_actions(string room){if(!stringp(room)||!pointerp(actions[room]))return ({});return actions[room]+({});}
