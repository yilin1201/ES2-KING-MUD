import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const url = process.env.ES2_E2E_WS_URL;
const password = process.env.ES2_E2E_KING_PASSWORD;
assert.ok(url && password);

let socket;
let output = "";

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
      reject(new Error(`等待大邪七損刀 Runtime 證據逾時：${String(matcher)}\n${tail.slice(-700)}`));
    }
  }, 25);
});

async function command(text, matcher = "> ", timeout = 20000) {
  const offset = output.length;
  socket.send(`${text}\r\n`);
  return waitForAfter(offset, matcher, timeout);
}

await connect();
await waitForAfter(0, "您的使用者代號");
await command("king", "請輸入密碼");
await command(password, "目前權限: (admin)");
await waitForAfter(0, "> ");

// Dependency Gate／相依條件：沒有哭笑門心法時，大邪金身必須拒絕施展。
assert.match(await command("perform jinshen"), /必須先學會並啟用哭笑門心法/);
console.log("DAXIE_STAGE_PASS:jinshen-negative");

assert.match(await command("kingmartial daxie 200"), /哭笑門心法 Lv\.200／大邪七損刀 Lv\.200/);
assert.match(await command("kingmartial daxie status"), /哭笑門心法 Lv\.200／大邪七損刀 Lv\.200／大邪金身：OFF/);
assert.match(await command("perform jinshen"), /大邪金身已啟動/);
console.log("DAXIE_STAGE_PASS:kuxiao-force-and-jinshen");

await command("goto /d/snow/fireplace", "大灶內");
await command("get wooden sword", /撿起一把木劍/);
await command("wield wooden sword", /裝備(?:一把)?木劍作武器/);
await command("goto /d/snow/tree", "榕樹上");
const combatOffset = output.length;
socket.send("kill arbao\r\n");
await waitForAfter(combatOffset, /納命來|不是你死就是我活|忌日|攻擊|招架|閃躲|命中/, 20000);
// Original Command Rate Limit／原始指令速率限制：跨過登入、移動與開戰的限速窗口，
// 避免把真人可用招式誤判成 Runtime 失敗。
await new Promise(resolve => setTimeout(resolve, 2500));

const forms = [
  ["sunpi", /損皮・雷霆震不還.*七損累積=1\/6/s],
  ["sunrou", /損肉・傲笑傲天魔.*七損累積=2\/6/s],
  ["sunjin", /損筋・寒霜透骨.*七損累積=3\/6/s],
  ["sungu", /損骨・笑哭不得也.*七損累積=4\/6/s],
  ["sunmai", /損脈・哭笑無常刀.*七損累積=5\/6/s],
  ["sunqi", /損氣・大邪絕息斬.*七損累積=6\/6/s],
];
for (const [form, evidence] of forms) {
  assert.match(await command(`perform ${form} on arbao`, evidence), evidence);
  await new Promise(resolve => setTimeout(resolve, 650));
}
assert.match(await command("perform qisun on arbao"), /七損合一・命魂俱滅.*七重狀態已引爆/s);
console.log("DAXIE_STAGE_PASS:seven-forms-and-combat");

await command("goto /d/snow/inn_hall", "客棧大堂");
assert.match(await command("save"), /檔案儲存完畢/);
const quitOffset = output.length;
socket.send("quit\r\n");
await waitForAfter(quitOffset, "歡迎下次再來");
socket.close();
await new Promise(resolve => setTimeout(resolve, 150));

await connect();
await waitForAfter(0, "您的使用者代號");
await command("king", "請輸入密碼");
await command(password, "目前權限: (admin)");
await waitForAfter(0, "> ");
assert.match(await command("kingmartial daxie status"), /哭笑門心法 Lv\.200／大邪七損刀 Lv\.200／大邪金身：ON/);
console.log("DAXIE_STAGE_PASS:save-quit-relogin");
socket.close();

// Normal Player Negative Authorization／普通玩家反向授權：相同 Driver、不同帳號實際登入。
await connect();
await waitForAfter(0, "您的使用者代號");
await command("mortal", "請輸入密碼");
await command(password, "> ");
const rejected = await command("kingmartial daxie 200");
assert.match(rejected, /What\?|只有 ES2-KING Owner 帳號可以使用此指令/);
assert.doesNotMatch(rejected, /哭笑門心法 Lv\.200／大邪七損刀 Lv\.200/);
console.log("DAXIE_STAGE_PASS:normal-player-negative-authorization");
socket.close();

console.log("DAXIE QISUN RUNTIME E2E PASS");
