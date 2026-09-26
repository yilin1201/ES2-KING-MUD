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
const kingRealm = fs.readFileSync("es2_king_expansion/runtime/mudlib/cmds/adm/kingrealm.c", "utf8");

// KING Cold Plum wiring：八屬性 99；武學遵守 Original 玩家技能 200 上限。
for (const token of [
  'actor->set_attr(attr, 99)',
  'actor->set("es2_king/creator_attribute", 99)'
]) {
  if (!kingd.includes(token)) throw new Error("missing KING 99 profile: " + token);
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
  if (!kingRealm.includes(token)) throw new Error("missing KING realm provisioning: " + token);
}
console.log("KING_99_COLD_PLUM_STATIC_PASS");
