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
