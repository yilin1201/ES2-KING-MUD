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
      reject(new Error(`等待 Original Thief Runtime 證據逾時：${String(matcher)}\n${tail.slice(-1800)}`));
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

async function login() {
  await connect();
  await waitForAfter(0, "您的使用者代號");
  await command("thiefprobe", "請輸入密碼");
  await command(password, "目前權限: (admin)");
  await waitForAfter(0, "> ");
}

await login();
assert.match(await command("score"), /平民/);

// Food Purchase／先在仍營業的初始客棧完成 Original vendor 交易。
assert.match(await command("buy dumpling from waiter", /包子|馬上來/, 30000), /包子|馬上來/);
await new Promise(resolve => setTimeout(resolve, 2600));
assert.match(await command("inventory"), /包子/);

// Original World Route／全程走 Snow 原作出口，不以 goto 取代內容可達性。
await command("open east", /打開|已經是開著/);
assert.match(await command("east"), /雪亭鎮廣場的西邊/);
assert.match(await command("east"), /廣場中央/);
assert.match(await command('call gammer->delete("chat_chance")'), /delete\("chat_chance"\) =/);
console.log("THIEF_PROGRESSION_PASS:original-world-route");

// Food → Comb／店小二商品與阿寶原作 accept_object 呼叫鏈。
assert.match(await command("climb 榕樹"), /榕樹上/);
const foodOffset = output.length;
socket.send("give dumpling to arbao\r\n");
lastSentAt = Date.now();
await waitForAfter(foodOffset, /不該白吃|這個送給你|梳子/, 30000);
await new Promise(resolve => setTimeout(resolve, 2600));
assert.match(await command("inventory"), /紅木梳|梳子/);
console.log("THIEF_PROGRESSION_PASS:food-comb-exchange");

// Comb → Qualification／瞎眼老太婆只接受 annatto comb，並要求原作口令。
await command("down", /廣場中央/);
const combOffset = output.length;
socket.send("give comb to gammer\r\n");
lastSentAt = Date.now();
await waitForAfter(combOffset, /我的梳子|祖奶奶|成為小偷/, 30000);
await new Promise(resolve => setTimeout(resolve, 1800));
console.log("THIEF_PROGRESSION_PASS:comb-qualification");

const joinOffset = output.length;
socket.send("say 祖奶奶\r\n");
lastSentAt = Date.now();
await waitForAfter(joinOffset, "你正式成為一名盜賊了", 30000);
assert.match(await command("score"), /盜賊/);
assert.match(await command('call me->query_learn("sneak")'), /= 20/);
assert.match(await command('call me->query_learn("stealing")'), /= 20/);
console.log("THIEF_PROGRESSION_PASS:class-and-skills");

// Persistence／class 與 skills 是一般 player state；save 後以新連線 restore。
assert.match(await command("save"), /檔案儲存完畢/);
const quitOffset = output.length;
socket.send("quit\r\n");
await waitForAfter(quitOffset, "歡迎下次再來");
socket.close();
await new Promise(resolve => setTimeout(resolve, 300));

await login();
assert.match(await command("score"), /盜賊/);
assert.match(await command('call me->query_learn("sneak")'), /= 20/);
assert.match(await command('call me->query_learn("stealing")'), /= 20/);
console.log("THIEF_PROGRESSION_PASS:save-quit-relogin-restore");

socket.close();
console.log("ORIGINAL_THIEF_PROGRESSION_RUNTIME_PASS");
