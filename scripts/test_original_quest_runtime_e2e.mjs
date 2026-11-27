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

const waitForAfter = (offset, matcher, timeout = 30000) => new Promise((resolve, reject) => {
  const started = Date.now();
  const timer = setInterval(() => {
    const tail = output.slice(offset);
    const matched = typeof matcher === "string" ? tail.includes(matcher) : matcher.test(tail);
    if (matched) {
      clearInterval(timer);
      resolve(tail);
    } else if (Date.now() - started > timeout) {
      clearInterval(timer);
      reject(new Error(`等待 Original Quest Runtime 證據逾時：${String(matcher)}\n${tail.slice(-1800)}`));
    }
  }, 25);
});

async function command(text, matcher = "> ", timeout = 30000) {
  const delay = Math.max(0, 550 - (Date.now() - lastSentAt));
  if (delay) await new Promise(resolve => setTimeout(resolve, delay));
  const offset = output.length;
  socket.send(`${text}\r\n`);
  lastSentAt = Date.now();
  return waitForAfter(offset, matcher, timeout);
}

async function login(id) {
  await connect();
  await waitForAfter(0, "您的使用者代號");
  await command(id, "請輸入密碼");
  await command(password, "目前權限: (admin)");
  await waitForAfter(0, "> ");
}

async function quit() {
  const offset = output.length;
  socket.send("quit\r\n");
  await waitForAfter(offset, "歡迎下次再來");
  socket.close();
  await new Promise(resolve => setTimeout(resolve, 300));
}

// Wage Journey／客棧→貨棧，全程沿 Original room exits。
await login("wageprobe");
assert.match(await command("score"), /平民/);
await command("open east", /打開|已經是開著/);
assert.match(await command("east"), /廣場的西邊/);
assert.match(await command("east"), /廣場中央/);
assert.match(await command("south"), /廣場的南邊/);
assert.match(await command("south"), /街道 - \/d\/snow\/sstreet1/);
assert.match(await command("west"), /貨棧/);
await command('call foreman->delete("chat_chance")');
assert.match(await command('call me->query_strength("carriage")'), /= 51200/);
assert.match(await command("get crate"), /扛了起來/);
assert.match(await command("load crate into wagon"), /裝上運貨驢車/);
assert.match(await command('call me->query_temp("wage_deserved")'), /= 25/);

const wageOffset = output.length;
socket.send("say 工錢\r\n");
lastSentAt = Date.now();
await waitForAfter(wageOffset, /總共是二十五文錢|給你/, 30000);
await new Promise(resolve => setTimeout(resolve, 2200));
assert.match(await command("inventory"), /二十五文錢/);
assert.match(await command('call me->query_temp("wage_deserved")'), /= 0/);
console.log("ORIGINAL_WAGE_PASS:entry-progress-completion-reward");

assert.match(await command("save"), /檔案儲存完畢/);
await quit();
await login("wageprobe");
assert.match(await command("inventory"), /二十五文錢/);
assert.match(await command('call me->query_temp("wage_deserved")'), /= 0/);
console.log("ORIGINAL_WAGE_PASS:save-quit-relogin-restore");
await quit();
console.log("ORIGINAL_WAGE_RUNTIME_PASS");

// Scholar Journey／5 級 literate 是 Source 明示門檻；fixture 只提供此前置狀態。
await login("scholarprobe");
assert.match(await command("score"), /平民/);
await command("open east", /打開|已經是開著/);
await command("east", /廣場/);
await command("south", /廣場/);
await command("west", /西街|街道/);
assert.match(await command("south"), /私塾/);
assert.match(await command("look wang"), /王懷芝/);
await command('call wang->delete("chat_chance")');
assert.match(await command('call me->query_skill("literate",1)'), /= 5/);
assert.match(await command("sit"), /坐了下來|專心聽講/);
for (let attempts = 0; attempts < 8; attempts += 1) {
  await command("call wang->teach_literate()", /大家跟著我念|王懷芝/);
  const learned = await command('call me->query_learn("literate")');
  if (!/= 0/.test(learned)) break;
}
assert.doesNotMatch(await command('call me->query_learn("literate")'), /= 0/);
console.log("ORIGINAL_SCHOLAR_PASS:entry-requirement-teaching");

// pick_student 的原作進入點包含 random；測試以管理診斷只排除排程／隨機等待，
// 後續 pending flag、玩家 say relay 與 set_class 全走原作 NPC 實作。
assert.match(await command("call wang->pick_student(me)"), /想不想和老師一樣|當一個書生/);
const scholarOffset = output.length;
socket.send("say 想\r\n");
lastSentAt = Date.now();
await waitForAfter(scholarOffset, /你成為一位書生/, 30000);
assert.match(await command('call me->query_class()'), /= "scholar"/);
console.log("ORIGINAL_SCHOLAR_PASS:offer-and-class-state");

assert.match(await command("save"), /檔案儲存完畢/);
await quit();
await login("scholarprobe");
assert.match(await command('call me->query_class()'), /= "scholar"/);
assert.doesNotMatch(await command('call me->query_learn("literate")'), /= 0/);
console.log("ORIGINAL_SCHOLAR_PASS:save-quit-relogin-restore");
socket.close();
console.log("ORIGINAL_SCHOLAR_RUNTIME_PASS");
console.log("ORIGINAL_QUEST_PHASE3_RUNTIME_PASS");
