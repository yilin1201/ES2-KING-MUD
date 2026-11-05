import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const url = process.env.ES2_E2E_WS_URL;
const password = process.env.ES2_E2E_PASSWORD;
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
      reject(new Error(`等待 Class Runtime 證據逾時：${String(matcher)}\n${tail.slice(-1400)}`));
    }
  }, 25);
});

async function command(text, matcher = "> ", timeout = 20000) {
  const delay = Math.max(0, 450 - (Date.now() - lastSentAt));
  if (delay) await new Promise(resolve => setTimeout(resolve, delay));
  const offset = output.length;
  socket.send(`${text}\r\n`);
  lastSentAt = Date.now();
  return waitForAfter(offset, matcher, timeout);
}

async function login() {
  await connect();
  await waitForAfter(0, "您的使用者代號");
  await command("classprobe", "請輸入密碼");
  await command(password, /客棧大堂|目前權限:/);
  await waitForAfter(0, "> ");
}

await login();

// Original Baseline／原作基線：隔離角色由保存的 commoner 初始狀態開始。
assert.match(await command("score"), /平民/);
console.log("M31_CLASS_PASS:commoner-rank");

// Original World Route／原作世界路徑：不使用 goto 管理指令，沿客棧與雪亭鎮出口進私塾。
await command("open east", /打開|已經是開著/);
await command("east", /廣場/);
await command("south", /廣場/);
await command("west", /西街|街道/);
await command("south", /私塾/);
assert.match(await command("look chen"), /陳維俠|牙山居士/);
console.log("M31_CLASS_PASS:original-world-school-route");

// Apprentice → Class／拜師轉職：完全走 Original NPC 的 accept/init/set_class 呼叫鏈。
const firstOffset = output.length;
socket.send("apprentice chen\r\n");
lastSentAt = Date.now();
await waitForAfter(firstOffset, /多你一個也不妨|門徒不下千人/, 30000);
await new Promise(resolve => setTimeout(resolve, 2600));
const apprentice = await command("apprentice chen", /龍圖丹派弟子|磕了四個響頭|師父在上/, 20000);
assert.doesNotMatch(apprentice, /似乎沒有收你為徒的打算|什麼\?\?/);
const alchemistScore = await command("score");
assert.match(alchemistScore, /方士/);
assert.match(alchemistScore, /龍圖丹派弟子/);
assert.match(await command("who -at"), /方士|龍圖丹派弟子/);
console.log("M31_CLASS_PASS:apprentice-set-class-alchemist-rank");

// Persistence／持久化：由 Original save_object 保存 class/title/relation，再以新連線還原。
assert.match(await command("save"), /檔案儲存完畢/);
const quitOffset = output.length;
socket.send("quit\r\n");
await waitForAfter(quitOffset, "歡迎下次再來");
socket.close();
await new Promise(resolve => setTimeout(resolve, 250));

await login();
const restored = await command("score");
assert.match(restored, /方士/);
assert.match(restored, /龍圖丹派弟子/);
console.log("M31_CLASS_PASS:save-quit-relogin-restore");

socket.close();
console.log("M31_CLASS_RUNTIME_PASS");
