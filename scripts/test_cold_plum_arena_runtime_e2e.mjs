import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const url = process.env.ES2_E2E_WS_URL;
const password = process.env.ES2_E2E_KING_PASSWORD;
assert.ok(url && password);

let socket;
let output = "";
let lastSentAt = 0;

async function connect() {
  output = "";
  socket = new WebSocket(url);
  socket.on("message", data => output += Buffer.from(data).toString("utf8"));
  await new Promise((resolve, reject) => {
    socket.once("open", resolve);
    socket.once("error", reject);
  });
}

const wait = (offset, match, timeout = 20000) => new Promise((resolve, reject) => {
  const started = Date.now();
  const timer = setInterval(() => {
    const received = output.slice(offset);
    const matched = typeof match === "string" ? received.includes(match) : match.test(received);
    if (matched) {
      clearInterval(timer);
      resolve(received);
    } else if (Date.now() - started > timeout) {
      clearInterval(timer);
      reject(new Error(`timeout ${String(match)}\n${received.slice(-3000)}`));
    }
  }, 25);
});

async function send(line) {
  const delay = Math.max(0, 400 - (Date.now() - lastSentAt));
  if (delay) await new Promise(resolve => setTimeout(resolve, delay));
  const offset = output.length;
  socket.send(line + "\r\n");
  lastSentAt = Date.now();
  return offset;
}

async function command(line, match = "> ", timeout = 20000) {
  const offset = await send(line);
  return wait(offset, match, timeout);
}

async function call(expression) {
  return command("call " + expression);
}

function callInt(text, method) {
  const found = text.match(new RegExp(`->${method}\\([^)]*\\) = (-?\\d+)`));
  assert.ok(found, text.slice(-800));
  return Number(found[1]);
}

async function login() {
  await connect();
  await wait(0, "您的使用者代號");
  await command("king", "請輸入密碼");
  await command(password, "目前權限: (admin)");
  await wait(0, "> ");
}

const attributes = ["str", "cor", "int", "spi", "cps", "dex", "con", "wis"];
const coldSkills = ["hainmay force", "advance_lunmay", "lunmay", "mayin", "seven"];
const baseSkills = ["force", "sword", "parry", "dodge", "unarmed"];

async function verifyKingProfile() {
  for (const attribute of attributes)
    assert.equal(callInt(await call(`me->query_attr("${attribute}")`), "query_attr"), 99, attribute);
  // KING 正式角色狀態：精／氣／神／形體／飲水／食物三層值登入即為 999。
  for (const stat of ["gin", "kee", "sen", "HP", "water", "food"]) {
    assert.equal(callInt(await call(`me->query_stat_maximum("${stat}")`), "query_stat_maximum"), 999, stat + ":maximum");
    assert.equal(callInt(await call(`me->query_stat_effective("${stat}")`), "query_stat_effective"), 999, stat + ":effective");
    assert.equal(callInt(await call(`me->query_stat_current("${stat}")`), "query_stat_current"), 999, stat + ":current");
  }
  for (const skill of [...coldSkills, ...baseSkills])
    assert.equal(callInt(await call(`me->query_skill("${skill}")`), "query_skill"), 200, skill);
  assert.match(await call('me->skill_mapped("force")'), /= "hainmay force"/);
  assert.match(await call('me->skill_mapped("sword")'), /= "lunmay"/);
  assert.equal(callInt(await call('me->query("es2_king/lengmei/mingjing_zhishui")'), "query"), 1);
  assert.equal(callInt(await call('me->query_skill("rulai shenzhang")'), "query_skill"), 200, "rulai shenzhang");
  assert.match(await call('me->skill_mapped("unarmed")'), /= "rulai shenzhang"/);
  assert.equal(callInt(await call('me->query("es2_king/rulai_combat")'), "query"), 1);
}

await login();
// 正式驗收：不得先靠 kinghome 才取得 8×99／冷梅武學；登入完成當下就必須成立。
await verifyKingProfile();
console.log("COLD_PLUM_PASS:formal-login-auto-provision");

for (const path of [
  "/adm/daemons/kingd",
  "/adm/daemons/kingmartiald",
  "/cmds/adm/kinghome",
  "/d/arena/skill/lunmay",
  "/d/arena/skill/rulai_shenzhang",
  "/d/arena/obj/charred_plum_branch",
  "/d/arena/npc/mei_hanshuang",
  "/d/arena/yanwujie",
]) assert.match(await command("update " + path), /更新|載入|重新編譯|成功|Ok/i);

assert.match(await command("kinghome"), /天神殿・無極之境/);
await verifyKingProfile();
console.log("COLD_PLUM_PASS:king-99-skills-admin");

assert.match(await command("enter"), /競技場：演武界/);
assert.match(await command("look mei"), /梅寒霜/);
console.log("COLD_PLUM_PASS:wuji-enter-yanwujie");

for (const skill of [...coldSkills, ...baseSkills])
  assert.equal(callInt(await call(`mei->query_skill("${skill}")`), "query_skill"), 300, skill);
for (const attribute of attributes)
  assert.equal(callInt(await call(`mei->query_attr("${attribute}")`), "query_attr"), 50, attribute);
console.log("COLD_PLUM_PASS:npc-attributes-skills");

// 如來神掌正式 Gameplay Gate：KING 空手時必須由 Original attack() 進入 rulai shenzhang daemon，
// 並實際輸出黃色 ANSI 招式；只看 skills/mapping 不算 PASS。
const rulaiOffset = output.length;
await send("kill mei");
await wait(rulaiOffset, /佛光初現/, 30000);
assert.ok(output.slice(rulaiOffset).includes("\\x1b[1;33m") || output.slice(rulaiOffset).includes("\\x1b[33m"), "Rulai combat missing yellow ANSI");
console.log("RULAI_PASS:formal-yellow-combat");
await call('me->remove_all_killer()');
await call('mei->remove_all_killer()');


const levelBefore = callInt(await call("me->query_level()"), "query_level");
const forceBefore = callInt(await call('me->query_skill("force",1)'), "query_skill");
const hpMaximum = callInt(await call('me->query_stat_maximum("HP")'), "query_stat_maximum");
assert.ok(hpMaximum > 0);
const defeatOffset = await send(`call me->consume_stat("HP",${hpMaximum + 1},me)`);
await wait(defeatOffset, "演武界法則引動");
assert.equal(callInt(await call('me->query_stat_current("HP")'), "query_stat_current"), hpMaximum);
assert.equal(callInt(await call('me->query_stat_effective("HP")'), "query_stat_effective"), hpMaximum);
assert.equal(callInt(await call("me->query_level()"), "query_level"), levelBefore);
assert.equal(callInt(await call('me->query_skill("force",1)'), "query_skill"), forceBefore);
assert.match(await call('me->query("life_form")'), /= "living"/);
console.log("COLD_PLUM_PASS:arena-defeat-protection");

assert.match(await command("clone /d/arena/obj/charred_plum_branch"), /複製成功|焦黑枯梅枝/);
assert.doesNotMatch(await command("wield branch"), /你身上沒有|無法|不能/);
for (const stat of ["gin", "kee", "sen", "HP"])
  await call(`me->set_stat_current("${stat}",100000)`);

const combatOffset = output.length;
await send("kill mei");
await wait(combatOffset, /【明鏡止水】/, 30000);
console.log("COLD_PLUM_PASS:mirror-mind-state");
const forms = [
  "梅二方劍", "梅四方劍", "梅八方劍", "愛霜恨雪", "寒霜三千里",
  "傲梅暗劍訣・傲雪藏鋒・逆折寒梅",
];
await wait(combatOffset, new RegExp(forms.join(".*"), "s"), 60000);
for (const form of forms) assert.ok(output.slice(combatOffset).includes(form), form);
assert.ok(output.slice(combatOffset).includes("明劍欺敵，暗劍藏殺；傲雪藏鋒・逆折寒梅。"));
console.log("COLD_PLUM_PASS:six-forms-runtime");

await call('mei->set_stat_current("kee",1)');
await call('mei->set_stat_current("HP",1)');
await wait(combatOffset, /死了|倒在地上|死亡|屍體|corpse|殺死/, 45000);
console.log("COLD_PLUM_PASS:king-combat-mei");

assert.match(await command("out"), /天神殿・無極之境/);
console.log("COLD_PLUM_PASS:yanwujie-out-wuji");
assert.match(await command("save"), /檔案儲存完畢/);
const quitOffset = await send("quit");
await wait(quitOffset, "歡迎下次再來");
socket.close();
await new Promise(resolve => setTimeout(resolve, 200));

await login();
assert.match(await command("look"), /天神殿・無極之境|客棧大堂/);
await verifyKingProfile();
console.log("COLD_PLUM_PASS:save-quit-relogin-restore");

socket.close();
console.log("COLD_PLUM_RUNTIME_PASS");
