import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

// Fighter Runtime Journey／使用真實 Neolith Driver 驗證歷史 join 適配與 class persistence。
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
      reject(new Error(`等待 Fighter Runtime 證據逾時：${String(matcher)}\n${tail.slice(-1600)}`));
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
  await command("fighterprobe", "請輸入密碼");
  await command(password, /客棧大堂|目前權限:/);
  await waitForAfter(0, "> ");
}

await login();

// Baseline／隔離角色必須由 Original commoner 起點開始。
assert.match(await command('call me->query_class()'), /= "commoner"/);
assert.match(await command("score"), /平民/);

// Entry／僅用隔離 admin fixture 抵達未接入正式地圖的 Historical Reconstruction room；
// 這不建立或宣稱 target Original Waterfog topology。
const entry = await command("goto /d/reconstruction/fighter_guildhall");
assert.match(entry, /水煙閣正廳（歷史重建）/);
assert.match(await command("look"), /加入\(join\)武者同盟/);
console.log("ORIGINAL_FIGHTER_CLASS_PASS:entry");

const joined = await command("join");
assert.match(joined, /成為一名武者/);
console.log("ORIGINAL_FIGHTER_CLASS_PASS:join");

assert.match(await command('call me->query_class()'), /= "fighter"/);
console.log("ORIGINAL_FIGHTER_CLASS_PASS:class-fighter");

// score／who 會經 Target CLASS_D("fighter") 查詢 Original fighter.c 的「武者」rank。
assert.match(await command("score"), /武者/);
assert.match(await command("who -fr"), /武者|fighterprobe|武者流程測試/);
console.log("ORIGINAL_FIGHTER_CLASS_PASS:rank");

// Persistence／由 Original save_object 寫回，斷線後以新 Session restore。
assert.match(await command("save"), /檔案儲存完畢/);
const quitOffset = output.length;
socket.send("quit\r\n");
await waitForAfter(quitOffset, "歡迎下次再來");
socket.close();
await new Promise(resolve => setTimeout(resolve, 250));

await login();
assert.match(await command('call me->query_class()'), /= "fighter"/);
assert.match(await command("score"), /武者/);
console.log("ORIGINAL_FIGHTER_CLASS_PASS:save-quit-relogin");

socket.close();
console.log("ORIGINAL_FIGHTER_CLASS_RUNTIME_PASS");
