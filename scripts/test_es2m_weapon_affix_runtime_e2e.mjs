#!/usr/bin/env node
// 以普通玩家帳號驗證武器詞綴：載入、裝備及私人儲物箱跨登入保存。
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
        reject(new Error(`ES2M weapon affix Runtime timeout: ${String(matcher)}\n${tail.slice(-2400)}`));
      }
    }, 25);
  });
}
async function send(line, matcher = "> ", timeout = 30000, raw = false) {
  const delay = Math.max(0, 600 - (Date.now() - lastSentAt));
  if (delay) await sleep(delay);
  const offset = output.length;
  socket.send(raw ? line : line + "\r\n");
  lastSentAt = Date.now();
  return wait(offset, matcher, timeout);
}
async function createPlayer() {
  await connect();
  await wait(0, "您的使用者代號");
  await send("affixprobe", /將會創造一個新的人物/);
  await send("Y", "請設定您的密碼", 30000, true);
  await send(password, "請再輸入一次您的密碼");
  await send(password, "您的電子郵件地址");
  await send("none", "請輸入編號 1-12 或種族 ID");
  await send("ES2RACE:1", "您要扮演的哪種性別", 30000, true);
  await send("M", "您的顯示名稱", 30000, true);
  await send("詞綴測試員", "您確定要創造這個角色嗎");
  assert.match(await send("Y", /目前權限: \(player\)/, 45000, true), /目前權限: \(player\)/);
  await wait(0, "> ");
  assert.match(await send("kadmin list"), /沒有這個指令|權限|不能|不允許|What\?/);
  console.log("ES2_AFFIX_PLAYER_SECURITY_PASS:ordinary-player");
}
async function relogin() {
  await send("quit", "歡迎下次再來");
  socket.close();
  await sleep(250);
  await connect();
  await wait(0, "您的使用者代號");
  await send("affixprobe", "請輸入密碼");
  assert.match(await send(password, /目前權限: \(player\)/, 45000), /目前權限: \(player\)/);
  await wait(0, "> ");
}

await createPlayer();
assert.match(await send("es2affix loadall", /ES2_AFFIX_LOADALL count=17/, 90000), /count=17/);
console.log("ES2_AFFIX_LOAD_PASS:17");
assert.match(await send("es2affix give"), /deterministic=黑鋼火炎/);
assert.match(await send("es2affix audit"), /prefix=黑鋼 suffix=火炎 attack=10 damage=15 str=3 value=1125 equipped=none/);
assert.match(await send("wield dagger"), /裝備|握在手中|抽出/);
assert.match(await send("es2affix audit"), /equipped=/);
assert.match(await send("unwield dagger"), /卸下|收起|放下|Ok\./);
console.log("ES2_AFFIX_EQUIP_PASS:deterministic-bonuses");
assert.match(await send("es2affix store"), /ES2_AFFIX_STORE_PASS/);
assert.match(await send("save"), /檔案儲存完畢/);
await relogin();
const restored = await send("es2affix retrieve", /ES2_AFFIX_RETRIEVE_PASS/, 45000);
assert.match(restored, /prefix=黑鋼 suffix=火炎 attack=10 damage=15 str=3 value=1125 equipped=none/);
console.log("ES2_AFFIX_STORAGE_PERSISTENCE_PASS:save-quit-relogin-retrieve");
socket.close();
console.log("ES2M_WEAPON_AFFIX_RUNTIME_E2E_PASS");
