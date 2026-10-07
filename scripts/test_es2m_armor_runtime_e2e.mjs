#!/usr/bin/env node
import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const url = process.env.ES2_E2E_WS_URL;
const password = process.env.ES2_E2E_PASSWORD;
assert.ok(url && password, "缺少隔離 Runtime WebSocket 或測試密碼");

let socket, output = "", lastSentAt = 0;
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
async function connect() {
  output = "";
  socket = new WebSocket(url);
  socket.on("message", data => { output += Buffer.from(data).toString("utf8"); });
  await new Promise((resolve, reject) => { socket.once("open", resolve); socket.once("error", reject); });
}
function wait(offset, matcher, timeout = 30000) {
  return new Promise((resolve, reject) => {
    const started = Date.now(), timer = setInterval(() => {
      const tail = output.slice(offset);
      const ok = typeof matcher === "string" ? tail.includes(matcher) : matcher.test(tail);
      if (ok) { clearInterval(timer); resolve(tail); }
      else if (Date.now() - started > timeout) {
        clearInterval(timer);
        reject(new Error(`ES2M armor Runtime timeout: ${String(matcher)}\n${tail.slice(-2400)}`));
      }
    }, 25);
  });
}
async function command(line, matcher = "> ", timeout = 30000) {
  const delay = Math.max(0, 600 - (Date.now() - lastSentAt));
  if (delay) await sleep(delay);
  const offset = output.length;
  socket.send(line + "\r\n");
  lastSentAt = Date.now();
  return wait(offset, matcher, timeout);
}
async function choice(value, matcher, timeout = 30000) {
  const delay = Math.max(0, 600 - (Date.now() - lastSentAt));
  if (delay) await sleep(delay);
  const offset = output.length;
  socket.send(value);
  lastSentAt = Date.now();
  return wait(offset, matcher, timeout);
}
async function createPlayer() {
  await connect();
  await wait(0, "您的使用者代號");
  await command("armorprobe", /將會創造一個新的人物/);
  await choice("Y", "請設定您的密碼");
  await command(password, "請再輸入一次您的密碼");
  await command(password, "您的電子郵件地址");
  await command("none", "請輸入編號 1-12 或種族 ID");
  await choice("ES2RACE:1", "您要扮演的哪種性別");
  await choice("M", "您的顯示名稱");
  await command("防具測試員", "您確定要創造這個角色嗎");
  const entered = await choice("Y", /目前權限: \(player\)/, 45000);
  assert.match(entered, /目前權限: \(player\)/);
  await wait(0, "> ");
  assert.match(await command("kadmin list"), /沒有這個指令|權限|不能|不允許|What\?/);
  console.log("ES2_ARMOR_PLAYER_SECURITY_PASS:ordinary-player");
}
async function relogin() {
  const offset = output.length;
  socket.send("quit\r\n");
  await wait(offset, "歡迎下次再來");
  socket.close();
  await sleep(250);
  await connect();
  await wait(0, "您的使用者代號");
  await command("armorprobe", "請輸入密碼");
  const entered = await command(password, /目前權限: \(player\)/, 45000);
  assert.match(entered, /目前權限: \(player\)/);
  await wait(0, "> ");
}

await createPlayer();

// 普通世界 Equipment Journey／裝備旅程：木劍與藍布長衫都能由既有世界合法取得；
// fixture 只在 mktemp Runtime 交付同一物件，避免用 KING／wizard 權限代替普通玩家驗證。
await command("es2armor give ordinary", /ES2_ORDINARY_EQUIPMENT_GIVE_PASS/);
let ordinaryInventory = await command("inventory");
assert.match(ordinaryInventory, /木劍/);
assert.match(ordinaryInventory, /藍布長衫/);
assert.match(await command("es2armor ordinary-audit"), /count=2 equipped=0/);

assert.match(await command("wield missing equipment"), /身上沒有這樣東西/);
assert.match(await command("wield blue cloth"), /不能當作武器/);
assert.match(await command("wear wooden sword"), /不能當作護具/);
assert.match(await command("unwield wooden sword"), /並沒有裝備/);
assert.match(await command("remove blue cloth"), /並沒有使用/);

assert.match(await command("wield wooden sword"), /裝備.*木劍.*武器/);
assert.match(await command("wear blue cloth"), /穿上.*藍布長衫|裝備.*藍布長衫/);
assert.match(await command("es2armor ordinary-audit"), /count=2 equipped=2/);
ordinaryInventory = await command("inventory");
// KING 目前 Original Runtime 使用「ˇ」，最新 ES2M 顯示為全形「Ｖ」；兩者都代表 equipped。
assert.match(ordinaryInventory, /[Ｖˇ][^\r\n]*木劍/);
assert.match(ordinaryInventory, /[Ｖˇ][^\r\n]*藍布長衫/);
assert.match(await command("unwield wooden sword"), /放下手中的.*木劍/);
assert.match(await command("remove blue cloth"), /脫了下來|卸除/);
assert.match(await command("es2armor ordinary-audit"), /count=2 equipped=0/);

assert.match(await command("wield wooden sword"), /裝備.*木劍.*武器/);
assert.match(await command("wear blue cloth"), /穿上.*藍布長衫|裝備.*藍布長衫/);
assert.match(await command("save"), /檔案儲存完畢/);
await relogin();
ordinaryInventory = await command("inventory");
assert.equal((ordinaryInventory.match(/木劍/g) || []).length, 1);
assert.equal((ordinaryInventory.match(/藍布長衫/g) || []).length, 1);
assert.doesNotMatch(ordinaryInventory, /[Ｖˇ][^\r\n]*(?:木劍|藍布長衫)/);
// SOURCE 邊界：普通裝備只回背包，不保存 equipped 暫態；玩家重登後自行重新裝備。
assert.match(await command("es2armor ordinary-audit"), /count=2 equipped=0/);
assert.match(await command("wield wooden sword"), /裝備.*木劍.*武器/);
assert.match(await command("wear blue cloth"), /穿上.*藍布長衫|裝備.*藍布長衫/);
assert.match(await command("es2armor ordinary-audit"), /count=2 equipped=2/);
assert.match(await command("unwield wooden sword"), /放下手中的.*木劍/);
assert.match(await command("remove blue cloth"), /脫了下來|卸除/);
console.log("ES2_ORDINARY_EQUIPMENT_PERSISTENCE_PASS:inventory-restored-unequipped-no-duplicates");

assert.match(await command("es2armor loadall", /ES2_ARMOR_LOADALL count=91 total=91/, 90000), /count=91 total=91/);
console.log("ES2_ARMOR_LOAD_PASS:91");

const representatives = [
  ["gloves_of_heroism", "gloves of heroism"], ["battle_helm", "battle helm"],
  ["bamboo_legs", "bamboo legs"], ["bodhi_rosary", "bodhi rosary"],
  ["blessed_jade", "blessed jade"]
];
for (const [key, id] of representatives) {
  await command(`es2armor give ${key}`, /ES2_ARMOR_GIVE/);
  assert.match(await command(`wear ${id}`), /穿上|戴上|繫在腰間|裝備/);
}
assert.match(await command("es2armor audit"), /count=5 equipped=5 hand=1 head=1 leg=1 neck=1 waist=1/);
assert.match(await command("remove all"), /Ok\./);
assert.match(await command("es2armor audit"), /count=5 equipped=0/);
console.log("ES2_ARMOR_FIVE_SLOTS_PASS:equip-remove");

const denied = [
  ["dark_bracers", "dark bracers"], ["dark_necklace", "dark necklace"],
  ["royal_gloves", "royal gloves"], ["royal_helmet", "royal helmet"],
  ["girdle_of_mighty_lord", "girdle of mighty lord"], ["yenhold_gauntlets", "yenhold gauntlets"],
  ["dingling_legs", "dingling legs"], ["malik_necklace", "malik necklace"],
  ["girdle_of_headless", "girdle of headless"]
];
for (const [key, id] of denied) {
  await command(`es2armor give ${key}`, /ES2_ARMOR_GIVE/);
  assert.match(await command(`wear ${id}`), /只有.*才能穿戴/);
}
const allowed = [
  ["thief", "human", [["dark_bracers", "dark bracers"], ["dark_necklace", "dark necklace"]]],
  ["soldier", "human", [["royal_gloves", "royal gloves"], ["royal_helmet", "royal helmet"], ["girdle_of_mighty_lord", "girdle of mighty lord"]]],
  ["commoner", "yenhold", [["yenhold_gauntlets", "yenhold gauntlets"]]],
  ["commoner", "dingling", [["dingling_legs", "dingling legs"]]],
  ["commoner", "malik", [["malik_necklace", "malik necklace"]]],
  ["commoner", "headless", [["girdle_of_headless", "girdle of headless"]]]
];
for (const [klass, race, items] of allowed) {
  assert.match(await command(`es2armor identity ${klass} ${race}`), new RegExp(`class=${klass} race=${race}`));
  for (const [, id] of items) assert.match(await command(`wear ${id}`), /穿上|戴上|繫在腰間|裝備/);
  await command("remove all");
}
for (const [key] of denied) await command(`es2armor purge ${key}`, /ES2_ARMOR_PURGE/);
console.log("ES2_ARMOR_RESTRICTIONS_PASS:negative=9 positive=9");

assert.match(await command("es2armor unique"), /ES2_ARMOR_UNIQUE_CHECK count=3/);
console.log("ES2_ARMOR_UNIQUE_PASS:3");

await command("es2armor identity commoner human");
await command("es2armor give corrosive_hands", /ES2_ARMOR_GIVE/);
assert.match(await command("wear corrosive hands"), /戴上|裝備/);
assert.match(await command("es2armor corpse"), /ES2_ARMOR_CORPSE_READY/);
assert.match(await command("corrupt corpse"), /只剩下一些碎銀|黑煙/);
assert.match(await command("get silver"), /碎銀|撿起/);
await command("remove corrosive hands");
await command("es2armor purge corrosive_hands", /ES2_ARMOR_PURGE/);
console.log("ES2_ARMOR_CORROSIVE_HANDS_PASS:npc-corpse-to-silver");

await command("remove all");
for (let index = 0; index < representatives.length; index++) {
  const [, id] = representatives[index];
  // Persistence 前先確認每件確實重新穿上；不可只等待 prompt 就把失敗命令當成成功。
  const worn = await command(`wear ${id}`);
  assert.match(worn, /穿上|戴上|繫在腰間|裝備/);
  assert.doesNotMatch(worn, /不能|不允許|已經裝備|並沒有/);
  assert.match(await command("es2armor audit"), new RegExp(`count=5 equipped=${index + 1}`));
}
assert.match(await command("es2armor audit"), /count=5 equipped=5 hand=1 head=1 leg=1 neck=1 waist=1/);
assert.match(await command("save"), /檔案儲存完畢/);
await relogin();
// Adapter 明確在登入後一秒恢復穿戴；等待完成後才判定 equipment persistence。
await sleep(1500);
assert.match(await command("es2armor audit", /ES2_ARMOR_AUDIT/, 45000), /count=5 equipped=5 hand=1 head=1 leg=1 neck=1 waist=1/);
console.log("ES2_ARMOR_PERSISTENCE_PASS:five-slots-equipped-relogin");

socket.close();
console.log("ES2M_ARMOR_RUNTIME_E2E_PASS");
