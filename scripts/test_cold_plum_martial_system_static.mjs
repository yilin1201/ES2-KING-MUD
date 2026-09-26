import fs from "node:fs";

const skillPath = "es2_king_expansion/runtime/mudlib/d/arena/skill/lunmay.c";
const npcPath = "es2_king_expansion/runtime/mudlib/d/arena/npc/mei_hanshuang.c";
const skill = fs.readFileSync(skillPath, "utf8");
const npc = fs.readFileSync(npcPath, "utf8");

const requiredForms = ["梅二方劍","梅四方劍","梅八方劍","愛霜恨雪","寒霜三千里"];
for (const form of requiredForms) {
  if (!skill.includes(form)) throw new Error("missing Cold Plum form: " + form);
}
const requiredSkillText = [
  "傲梅暗劍訣・傲雪藏鋒・逆折寒梅",
  "明劍欺敵，暗劍藏殺；傲雪藏鋒・逆折寒梅。",
  "咽喉、心口、氣海三處要害",
  '"attack":0, "force":0, "defense":0'
];
for (const token of requiredSkillText) {
  if (!skill.includes(token)) throw new Error("missing skill evidence: " + token);
}
const requiredNpcText = [
  'set_skill("hainmay force", 300)',
  'set_skill("advance_lunmay", 300)',
  'set_skill("lunmay", 300)',
  'load_object("/d/arena/skill/lunmay")',
  'map_skill("sword", "lunmay")',
  'set("chat_chance_combat", 100)',
  "activate_mirror_state",
  'set_temp("cold_plum/mirror_state", 1)'
];
for (const token of requiredNpcText) {
  if (!npc.includes(token)) throw new Error("missing Mei Hanshuang wiring: " + token);
}
console.log("COLD_PLUM_MARTIAL_SYSTEM_STATIC_PASS");


const kingd = fs.readFileSync("es2_king_expansion/runtime/mudlib/adm/daemons/kingd.c", "utf8");
const kingMartial = fs.readFileSync("es2_king_expansion/runtime/mudlib/adm/daemons/kingmartiald.c", "utf8");
const kingHome = fs.readFileSync("es2_king_expansion/runtime/mudlib/cmds/adm/kinghome.c", "utf8");
const attribute = fs.readFileSync("es2_king_expansion/runtime/mudlib/feature/attribute.c", "utf8");
const wujiRealm = fs.readFileSync("es2_king_expansion/runtime/mudlib/d/king/wuji_realm.c", "utf8");
const yanwujie = fs.readFileSync("es2_king_expansion/runtime/mudlib/d/arena/yanwujie.c", "utf8");
const applyExpansion = fs.readFileSync("scripts/apply_es2_king_expansion.sh", "utf8");

// KING Cold Plum wiring：八屬性 99；武學遵守 Original 玩家技能 200 上限。
for (const token of [
  '"str", "cor", "int", "spi", "cps", "dex", "con", "wis"',
  'actor->set_attr(attr, 99)',
  'actor->set("es2_king/creator_attribute", 99)'
]) {
  if (!kingd.includes(token)) throw new Error("missing KING 99 profile: " + token);
}
for (const token of ['query("id") == "king") ? 99 : ATTRVAL_MAX', "value > maximum"]) {
  if (!attribute.includes(token)) throw new Error("missing KING-only attribute boundary: " + token);
}
for (const token of [
  "int set_cold_plum(",
  'actor->set_skill("hainmay force", level)',
  'actor->set_skill("advance_lunmay", level)',
  'actor->set_skill("lunmay", level)',
  'load_object("/d/arena/skill/lunmay")',
  'actor->map_skill("force", "hainmay force")',
  'actor->map_skill("sword", "lunmay")',
  'actor->set("es2_king/lengmei/mingjing_zhishui", 1)',
  'actor->set_temp("cold_plum/mirror_state", 1)',
  'level > 200'
]) {
  if (!kingMartial.includes(token)) throw new Error("missing KING Cold Plum wiring: " + token);
}
for (const token of [
  "KING_D->apply_creator_profile(me)",
  "KING_MARTIAL_D->set_cold_plum(me, 200)",
  'me->move("/d/king/wuji_realm")'
]) {
  if (!kingHome.includes(token)) throw new Error("missing KING home movement: " + token);
}
for (const token of [
  "ES2-KING OWNER LOGIN PROVISIONING",
  'user->query("id") == "king"',
  'call_other("/adm/daemons/kingd", "apply_creator_profile", user)',
  'call_other("/adm/daemons/kingmartiald", "set_cold_plum", user, 200)'
]) {
  if (!applyExpansion.includes(token)) throw new Error("missing formal KING login provisioning: " + token);
}
if (!wujiRealm.includes('"enter" : "/d/arena/yanwujie"'))
  throw new Error("missing Wuji Realm enter -> Yanwujie topology");
if (!yanwujie.includes('"out" : "/d/king/wuji_realm"'))
  throw new Error("missing Yanwujie out -> Wuji Realm topology");
for (const forbidden of ["必中", "必殺", "穿透率", "傷害倍率", '"attack":1', '"force":1', '"defense":1']) {
  if (skill.includes(forbidden)) throw new Error("unsupported Cold Plum numeric/effect invention: " + forbidden);
}
console.log("KING_99_COLD_PLUM_STATIC_PASS");
