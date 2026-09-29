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

function countText(text, needle) {
  return text.split(needle).length - 1;
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
const baseSkills = ["force", "unarmed", "sword", "secondhand sword", "twohanded sword", "blade", "twohanded blade", "staff", "parry", "dodge", "whip"];
const meiSkills = [...coldSkills, "force", "unarmed", "sword", "parry", "dodge"];

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
    assert.equal(callInt(await call(`me->query_skill("${skill}")`), "query_skill"), 300, skill);
  assert.match(await call('me->skill_mapped("force")'), /= "yijinjing"/);
  assert.match(await call('me->skill_mapped("sword")'), /= "lunmay"/);
  assert.equal(callInt(await call('me->query("es2_king/lengmei/mingjing_zhishui")'), "query"), 1);
  assert.equal(callInt(await call('me->query_skill("rulai shenzhang")'), "query_skill"), 300, "rulai shenzhang");
  assert.match(await call('me->skill_mapped("unarmed")'), /= "rulai shenzhang"/);
  assert.equal(callInt(await call('me->query_skill("yijinjing")'), "query_skill"), 300, "yijinjing");
  assert.equal(callInt(await call('me->query_skill("batian lianti jue")'), "query_skill"), 300, "batian lianti jue");
  assert.match(await call('me->skill_mapped("parry")'), /= "batian lianti jue"/);
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

for (const skill of meiSkills)
  assert.equal(callInt(await call(`mei->query_skill("${skill}")`), "query_skill"), 300, skill);
for (const attribute of attributes)
  assert.equal(callInt(await call(`mei->query_attr("${attribute}")`), "query_attr"), 50, attribute);
assert.equal(callInt(await call("mei->query_level()"), "query_level"), 99, "梅寒霜 level");
for (const stat of ["gin", "kee", "sen"]) {
  assert.equal(callInt(await call(`mei->query_stat_maximum("${stat}")`), "query_stat_maximum"), 999, `梅寒霜 ${stat}:maximum`);
  assert.equal(callInt(await call(`mei->query_stat_effective("${stat}")`), "query_stat_effective"), 999, `梅寒霜 ${stat}:effective`);
  assert.equal(callInt(await call(`mei->query_stat_current("${stat}")`), "query_stat_current"), 999, `梅寒霜 ${stat}:current`);
}
console.log("COLD_PLUM_PASS:npc-attributes-skills");

// 如來神掌正式 Gameplay Gate：KING 空手時必須由 Original attack() 進入 rulai shenzhang daemon，
// 並實際輸出黃色 ANSI 招式；只看 skills/mapping 不算 PASS。
const rulaiOffset = output.length;
await send("kill mei");
await wait(rulaiOffset, /佛光初現/, 30000);
await wait(rulaiOffset, /面對漫天殺機/, 30000);
await new Promise(resolve => setTimeout(resolve, 1200));
assert.equal(countText(output.slice(rulaiOffset), "面對漫天殺機"), 1,
  "同一場 Combat 的霸天開場不得重複洗版");
assert.ok(output.slice(rulaiOffset).includes("\x1b[1;33m") || output.slice(rulaiOffset).includes("\x1b[33m"), "Rulai combat missing yellow ANSI");
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
await wait(combatOffset, /【\s*明\s*鏡\s*止\s*水\s*】/, 30000);
await wait(combatOffset, /面對漫天殺機/, 30000);
console.log("COLD_PLUM_PASS:mirror-mind-state");
// Phase 1／冷梅：先確認正式 Combat 確實由 lunmay 接管；不再要求 30 招前隨機抽完所有冷梅招式，
 // 因為新 Canon 是第 30 次攻擊後必須立即進入 Phase 2。
assert.match(await call('mei->skill_mapped("sword")'), /= "lunmay"/);
assert.match(await call('mei->skill_mapped("parry")'), /= "lunmay"/);
await wait(combatOffset, /梅二方劍|梅四方劍|梅八方劍|愛霜恨雪|寒霜三千里|傲梅暗劍訣・傲雪藏鋒・逆折寒梅/, 30000);
console.log("COLD_PLUM_PASS:phase1-cold-plum-combat");

// Phase Transition／把計數推到 29，只縮短測試時間；第 30 次仍由 NPC 正常 combat callback 觸發 switch_to_aojian()。
await call('mei->set_temp("aojian/attack_rounds",29)');
const phase2Offset = output.length;
await wait(phase2Offset, /寒霜碎裂，冷梅將折。/, 30000);
await wait(phase2Offset, /三十招了……能逼我棄冷梅、出傲劍，你足以自傲。/, 30000);
await wait(phase2Offset, /冷梅既凋——唯傲劍獨立！/, 30000);
assert.match(await call('mei->skill_mapped("sword")'), /= "au-chan sword"/);
assert.match(await call('mei->skill_mapped("parry")'), /= "au-chan sword"/);
assert.equal(callInt(await call('mei->query_temp("aojian/awakened")'), "query_temp"), 1);
console.log("COLD_PLUM_PASS:aojian-phase-transition-30");

// Phase 2／傲劍：七式皆由同一 Combat daemon 隨機出招；Runtime 至少必須實際出現一式，
// 七式完整 roster／Attack+Parry wiring 另由 Static Gate 鎖定，避免以管理指令假造七式 Runtime。
const aojianForms = [
  "千嬌百媚柔似水", "佳人在殘醉臥君", "了絕紅塵遁山林", "清風送爽墨雲飛",
  "渺盡人世絕惡意", "天始一乾景初開", "不識江山多嬌媚",
];
await wait(phase2Offset, new RegExp(aojianForms.join("|")), 30000);
assert.ok(output.slice(phase2Offset).includes("\x1b[1;31m") || output.slice(phase2Offset).includes("\x1b[31m")
  || output.slice(phase2Offset).includes("\x1b[1;33m") || output.slice(phase2Offset).includes("\x1b[33m"),
  "Ao Jian phase missing red/yellow ANSI");
console.log("COLD_PLUM_PASS:aojian-combat-runtime");

// 劍領風騷必須是 Phase 2 自動 Combat 的隨機持續招，不以 perform/call 直接施放。
// 1/8 機率下等待足夠 attack callbacks；一旦出現，六段「忠武義德狂情」必須同一輪完整展開。
const jianlingOffset = output.length;
const jianlingText = await wait(jianlingOffset, /劍領風騷/, 90000);
await wait(jianlingOffset, /劍領風騷・忠/, 10000);
await wait(jianlingOffset, /劍領風騷・武/, 10000);
await wait(jianlingOffset, /劍領風騷・義/, 10000);
await wait(jianlingOffset, /劍領風騷・德/, 10000);
await wait(jianlingOffset, /劍領風騷・狂/, 10000);
await wait(jianlingOffset, /劍領風騷・情/, 10000);
assert.ok(jianlingText.includes("\x1b[1;37m") || output.slice(jianlingOffset).includes("\x1b[1;37m"),
  "Jianling Fengsao actor narration must return to bright white");
console.log("COLD_PLUM_PASS:jianling-fengsao-random-combat");

// Combat Reset／戰鬥停止後，下一場必須重新從冷梅開始並清空 30 招計數。
await call('me->remove_all_killer()');
await call('mei->remove_all_killer()');
await call('mei->activate_mirror_state()');
assert.match(await call('mei->skill_mapped("sword")'), /= "lunmay"/);
assert.match(await call('mei->skill_mapped("parry")'), /= "lunmay"/);
assert.equal(callInt(await call('mei->query_temp("aojian/awakened")'), "query_temp"), 0);
assert.equal(callInt(await call('mei->query_temp("aojian/attack_rounds")'), "query_temp"), 0);
console.log("COLD_PLUM_PASS:aojian-reset-to-cold-plum");

// 重新開戰完成既有可擊敗驗證。
await send("kill mei");
await new Promise(resolve => setTimeout(resolve, 800));
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
