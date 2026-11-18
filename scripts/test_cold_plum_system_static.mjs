import fs from "node:fs";

const root = process.cwd();
const read = p => fs.readFileSync(root + "/" + p, "utf8");
const skill = read("es2_king_expansion/runtime/mudlib/d/arena/skill/lunmay.c");
const npc = read("es2_king_expansion/runtime/mudlib/d/arena/npc/mei_hanshuang.c");
const room = read("es2_king_expansion/runtime/mudlib/d/arena/yanwujie.c");

const requiredForms = ["梅二方劍","梅四方劍","梅八方劍","愛霜恨雪","寒霜三千里",
  "傲梅暗劍訣・傲雪藏鋒・逆折寒梅"];
for (const form of requiredForms) {
  if (!skill.includes(form)) throw new Error("missing form: " + form);
}
for (const text of ["明劍欺敵，暗劍藏殺；傲雪藏鋒・逆折寒梅。",
  "咽喉、心口、氣海三處要害","attack\":0","force\":0","defense\":0"]) {
  if (!skill.includes(text)) throw new Error("missing evidence boundary/text: " + text);
}
for (const id of ["hainmay force","advance_lunmay","lunmay","mayin","seven"]) {
  if (!npc.includes('set_skill("' + id + '", 300)')) throw new Error("Mei missing skill: " + id);
}
if (!npc.includes('map_skill("sword", "lunmay")')) throw new Error("Mei sword mapping missing");
if (!npc.includes('set("chat_chance_combat", 100)')) throw new Error("Mirror Mind combat activation missing");
if (!npc.includes('set_temp("cold_plum/mirror_state", 1)')) throw new Error("Mirror Mind state missing");
if (!room.includes('"/d/arena/npc/mei_hanshuang" : 1')) throw new Error("Mei not spawned in Yanwujie");
console.log("COLD_PLUM_STATIC_PASS");
