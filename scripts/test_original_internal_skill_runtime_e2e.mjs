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
  socket.on("message", data => { output += Buffer.from(data).toString("utf8"); });
  await new Promise((resolve, reject) => {
    socket.once("open", resolve);
    socket.once("error", reject);
  });
}

const waitForAfter = (offset, matcher, timeout = 20000) => new Promise((resolve, reject) => {
  const started = Date.now();
  const timer = setInterval(() => {
    const tail = output.slice(offset);
    const matched = typeof matcher === "string" ? tail.includes(matcher) : matcher.test(tail);
    if (matched) {
      clearInterval(timer);
      resolve(tail);
    } else if (Date.now() - started > timeout) {
      clearInterval(timer);
      reject(new Error(`等待 Runtime 證據逾時：${String(matcher)}\n${tail.slice(-1200)}`));
    }
  }, 25);
});

async function command(text, matcher = "> ", timeout = 20000) {
  const delay = Math.max(0, 400 - (Date.now() - lastSentAt));
  if (delay) await new Promise(resolve => setTimeout(resolve, delay));
  const offset = output.length;
  socket.send(`${text}\r\n`);
  lastSentAt = Date.now();
  return waitForAfter(offset, matcher, timeout);
}

async function sendLine(text) {
  const delay = Math.max(0, 400 - (Date.now() - lastSentAt));
  if (delay) await new Promise(resolve => setTimeout(resolve, delay));
  socket.send(`${text}\r\n`);
  lastSentAt = Date.now();
}

async function login() {
  await connect();
  await waitForAfter(0, "您的使用者代號");
  await command("king", "請輸入密碼");
  await command(password, "目前權限: (admin)");
  await waitForAfter(0, "> ");
}

async function call(expression) {
  return command(`call me->${expression}`);
}

function callInt(text, method) {
  const match = text.match(new RegExp(`->${method}\\([^)]*\\) = (-?\\d+)`));
  assert.ok(match, `無法解析 ${method} 回傳值：${text.slice(-500)}`);
  return Number(match[1]);
}

await login();

// Fixture preparation／隔離角色準備：只修改 shell 腳本建立的暫存 KING 副本。
// update 載入保存於 Snow 的 Original Skill Daemon，讓它依原始 create() 向 DAEMON_D 登記。
assert.match(await command("update /d/snow/skill/dragon_force"), /更新|載入|重新編譯|成功|Ok/i);
await call('set_skill("force",80)');
await call('set_skill("dragon force",80)');

// Public command chain／玩家指令鏈：mapping 必須由 Original enable 指令完成，不由測試直接寫入。
const enabled = await command("enable force with dragon force");
assert.match(enabled, /龍圖心經.*內功/);
const mapping = await call('skill_mapped("force")');
assert.match(mapping, /= "dragon force"/);
const baseSkill = callInt(await call('query_skill("force",1)'), "query_skill");
const dragonSkill = callInt(await call('query_skill("dragon force",1)'), "query_skill");
assert.equal(baseSkill, 80);
assert.equal(dragonSkill, 80);
assert.match(await command("enable"), /內功.*龍圖心經|龍圖心經.*內功/);
assert.match(await command("skills -a"), /龍圖心經|dragon force/);
console.log("INTERNAL_SKILL_PASS:exists-enable-map");

// Force ratio／出力比例：使用 Original exert 指令寫入玩家狀態，並立即由同一指令讀回。
assert.match(await command("exert 60"), /Ok/);
assert.match(await command("exert"), /六成/);

// Combat integration／戰鬥整合：analyze 必須讀到 Original combat modifier，並實際發動一回合戰鬥。
const analysis = await command("analyze");
assert.match(analysis, /使用內力\s+龍圖心經\(攻擊強度 \+/);
await new Promise(resolve => setTimeout(resolve, 2500));
await command("goto /d/snow/tree", "榕樹上");
const combatOffset = output.length;
await sendLine("kill arbao");
const combat = await waitForAfter(combatOffset, /納命來|不是你死就是我活|忌日|攻擊|招架|閃躲|命中/, 20000);
assert.doesNotMatch(combat, /這裡不准戰鬥|這裡沒有這個人/);
await command("goto /d/snow/inn_hall", "客棧大堂");
console.log("INTERNAL_SKILL_PASS:combat-integration");

// Resource transition／資源變化：固定成 35 只為得到可重複起點；消耗本身完全由
// Original dragon_force.c 每輪 consume_stat(..., 10) 執行，測試不改其成本或公式。
for (const stat of ["gin", "kee", "sen"])
  await call(`set_stat_current("${stat}",35)`);
const before = {};
for (const stat of ["gin", "kee", "sen"])
  before[stat] = callInt(await call(`query_stat("${stat}")`), "query_stat");

const exertOffset = output.length;
await sendLine("exert dragon force");
const exercise = await waitForAfter(exertOffset, "沒有辦法繼續練功了", 45000);
assert.match(exercise, /開始修習龍圖心經的內功/);
const after = {};
for (const stat of ["gin", "kee", "sen"])
  after[stat] = callInt(await call(`query_stat("${stat}")`), "query_stat");
for (const stat of ["gin", "kee", "sen"])
  assert.ok(after[stat] < before[stat], `${stat} 未由 Original exert 消耗`);
console.log(`INTERNAL_SKILL_PASS:exert-resource:${JSON.stringify({before, after})}`);

// Save lifecycle／保存生命週期：保存技能、mapping 與 force_ratio，離線後以新 WebSocket 重登。
assert.match(await command("save"), /檔案儲存完畢/);
const quitOffset = output.length;
await sendLine("quit");
await waitForAfter(quitOffset, "歡迎下次再來");
socket.close();
await new Promise(resolve => setTimeout(resolve, 200));

await login();
assert.equal(callInt(await call('query_skill("force",1)'), "query_skill"), 80);
assert.equal(callInt(await call('query_skill("dragon force",1)'), "query_skill"), 80);
assert.match(await call('skill_mapped("force")'), /= "dragon force"/);
assert.match(await command("exert"), /六成/);
assert.match(await command("analyze"), /使用內力\s+龍圖心經\(攻擊強度 \+/);
console.log("INTERNAL_SKILL_PASS:save-quit-relogin-restore");

// Next gap: Inventory／下一缺口：依 Original autoload 合約驗證合併物品的精確數量。
// 金錢在此只作 query_autoload()/autoload() 的保存樣本，不重跑 vendor 或 Economy Journey。
assert.match(await command("clone 37 /obj/money/coin"), /錢複製成功/);
const inventoryAmountBefore = callInt(await command("call coin->query_amount()"), "query_amount");
assert.ok(inventoryAmountBefore >= 37);
assert.match(await command("inventory"), /文錢/);
assert.match(await command("save"), /檔案儲存完畢/);
const inventoryQuitOffset = output.length;
await sendLine("quit");
await waitForAfter(inventoryQuitOffset, "歡迎下次再來");
socket.close();
await new Promise(resolve => setTimeout(resolve, 200));

await login();
const inventoryAmountAfter = callInt(await command("call coin->query_amount()"), "query_amount");
assert.equal(inventoryAmountAfter, inventoryAmountBefore);
assert.match(await command("inventory"), /文錢/);
console.log(`INVENTORY_PASS:autoload-combined-amount:${inventoryAmountBefore}`);

socket.close();
console.log("ORIGINAL_INTERNAL_SKILL_RUNTIME_PASS");
