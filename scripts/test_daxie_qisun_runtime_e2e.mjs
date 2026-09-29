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
assert.match(await command("look"), /客棧大堂|私塾|天神殿|無極之境/);
assert.match(await command("score"), /KING|目前權限|等級|經驗/);
await command("inventory");
assert.match(await command("skills"), /技能狀態|目前並沒有學會任何技能/);
console.log("DAXIE_STAGE_PASS:login-look-score-inventory-skills");

// Dependency Gate／相依條件：沒有哭笑心法時，大邪金身必須拒絕施展。
assert.match(await command("perform jinshen"), /必須先學會並啟用哭笑心法/);
console.log("DAXIE_STAGE_PASS:jinshen-negative");
await new Promise(resolve => setTimeout(resolve, 2500));

assert.match(await command("kingmartial daxie 300"), /哭笑心法 Lv\.300／大邪七損刀訣 Lv\.300/);
// Primary Force Regression／配置大邪後，KING 主內功仍必須是易筋經，不得被哭笑心法覆蓋。
assert.match(await command("skills"), /易筋經|yijinjing/);
assert.match(await command("kingmartial daxie status"), /哭笑心法 Lv\.300／大邪七損刀訣 Lv\.300／大邪金身：OFF/);
assert.match(await command("perform jinshen"), /大邪金身已啟動/);
assert.match(await command("perform jinshen"), /結束「大邪金身」狀態/);
await new Promise(resolve => setTimeout(resolve, 1200));
assert.match(await command("kingmartial daxie status"), /大邪金身：OFF/);
assert.match(await command("perform jinshen"), /大邪金身已啟動/);
console.log("DAXIE_STAGE_PASS:kuxiao-force-and-jinshen");

// Weapon Contract／大邪七損刀是 blade；先證明 sword 被拒絕，再用 KING 已配置的靈刀祭血進入正式刀法 Combat。
await command("goto /d/snow/fireplace", "大灶內");
await command("get wooden sword", /撿起一把木劍/);
await command("wield wooden sword", /裝備(?:一把)?木劍作武器/);
assert.match(await command("perform sunpi"), /必須裝備刀類武器來使出大邪七損刀/);
await command("unwield wooden sword");
assert.match(await command("wield 靈刀祭血 as blade"), /裝備|靈刀祭血/);
await command("goto /d/snow/tree", "榕樹上");
const combatOffset = output.length;
socket.send("kill arbao\r\n");
await waitForAfter(combatOffset, /納命來|不是你死就是我活|忌日|攻擊|招架|閃躲|命中/, 20000);
// Original Command Rate Limit／原始指令速率限制：跨過登入、移動與開戰的限速窗口，
// 避免把真人可用招式誤判成 Runtime 失敗。
await new Promise(resolve => setTimeout(resolve, 2500));

const forms = [
  ["sunpi", /雷霆震不還・損皮.*七損累積=1\/6/s],
  ["sunrou", /傲笑傲天魔・損肉.*七損累積=2\/6/s],
  ["sunjin", /寒霜透骨・損筋.*七損累積=3\/6/s],
  ["sungu", /笑哭不得也・損骨.*七損累積=4\/6/s],
  ["sunmai", /哭笑無常刀・損脈.*七損累積=5\/6/s],
  ["sunqi", /大邪絕息斬・損氣.*七損累積=6\/6/s],
];
for (const [form, evidence] of forms) {
  assert.match(await command(`perform ${form} on arbao`, evidence), evidence);
  await new Promise(resolve => setTimeout(resolve, 650));
}
assert.match(await command("perform qisun on arbao"), /七損合一・命魂俱滅.*七重狀態已引爆/s);
console.log("DAXIE_STAGE_PASS:seven-forms-and-combat");

// 正式技能清理與七傷杖 Runtime／避免舊七損刀 ID 重複出現在 skills，並驗證九曲十彎能驅動亮紫七傷杖。
const skillsNow = await command("skills");
assert.match(skillsNow, /大邪七損刀訣.*qisun_blade/s);
assert.doesNotMatch(skillsNow, /seven_blade|daxie qisun blade/);
await command("unwield 靈刀祭血");
assert.match(await command("wield 九曲十彎 as twohanded staff"), /裝備|九曲十彎/);
const staffOffset = output.length;
socket.send("kill arbao\r\n");
await waitForAfter(staffOffset, /破械反撩|下盤重槌|回身盲刺|陰煞透心|凌空鎮岳|真氣撼地|極境奧義/, 20000);
assert.match(output.slice(staffOffset), /\x1b\[1;35m(?:破械反撩|下盤重槌|回身盲刺|陰煞透心|凌空鎮岳|真氣撼地|極境奧義)/);
assert.match(output.slice(staffOffset), /霸天煉體訣.*不滅金身/s);
const staffPlain = output.slice(staffOffset).replace(/\x1b\[[0-9;]*m/g, "");
assert.match(staffPlain, /神色不起波瀾，只信步前踏半步。/);
assert.match(staffPlain, /體內「霸天煉體訣」神紋流轉，周身散發著萬法不侵的沉雄氣度。/);
assert.match(staffPlain, /待得金芒驟聚，「【霸天煉體訣。不滅金身】」自然流轉，泛起璀璨耀目的金光琉璃神華。/);
// Shared Alias Routing／leiting 同時存在於刀、杖；持九曲十彎時必須由 qishang_staff 接手。
assert.match(await command("perform leiting on arbao"), /破械反撩・雷霆震不還/);
// 第七式有大邪金身前置：先關閉狀態驗證拒絕，再重新啟動後驗證正式奧義。
assert.match(await command("perform jinshen"), /結束「大邪金身」狀態/);
assert.match(await command("perform tianku on arbao"), /必須先啟動大邪金身/);
assert.match(await command("perform jinshen"), /大邪金身已啟動/);
assert.match(await command("perform tianku on arbao"), /哭笑極境奧義・九曲天哭・一杖定乾坤/);
// No-arg Perform Routing／持杖且已 mapping 時，單純 perform 必須直接走七傷杖隨機式，不能掉回 Original 格式提示。
assert.match(
  await command("perform"),
  /破械反撩・雷霆震不還|下盤重槌・搖頭嘲月老|回身盲刺・傲笑傲天魔|陰煞透心・百歡催嚴寒|凌空鎮岳・踏步踏青天|真氣撼地・笑哭不得也|哭笑極境奧義・九曲天哭・一杖定乾坤/
);
// Batian Once-Per-Combat／同一場戰鬥即使連續 Combat + perform，也只能演出一次正式開場。
const batianIntro = "待得金芒驟聚，「【霸天煉體訣。不滅金身】」自然流轉，泛起璀璨耀目的金光琉璃神華。";
assert.equal(
  staffPlain.split(batianIntro).length - 1,
  1,
  "同一場戰鬥的霸天煉體訣／不滅金身開場不得重複演出"
);
console.log("DAXIE_STAGE_PASS:qishang-staff-purple-batian-random-perform-once");

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
assert.match(await command("kingmartial daxie status"), /哭笑心法 Lv\.300／大邪七損刀訣 Lv\.300／大邪金身：ON/);
const skillsAfterRelog = await command("skills");
assert.match(skillsAfterRelog, /大邪七損刀訣.*qisun_blade/s);
assert.match(skillsAfterRelog, /大邪七傷杖訣.*qishang_staff/s);
assert.match(skillsAfterRelog, /霸天煉體訣.*batian lianti jue/s);
console.log("DAXIE_STAGE_PASS:save-quit-relogin-martial-state");
socket.close();

// Normal Player Negative Authorization／普通玩家反向授權：相同 Driver、不同帳號實際登入。
await connect();
await waitForAfter(0, "您的使用者代號");
await command("mortal", "請輸入密碼");
await command(password, "> ");
const rejected = await command("kingmartial daxie 300");
assert.match(rejected, /What\?|只有 ES2-KING Owner 帳號可以使用此指令/);
assert.doesNotMatch(rejected, /哭笑心法 Lv\.300／大邪七損刀訣 Lv\.300/);
console.log("DAXIE_STAGE_PASS:normal-player-negative-authorization");
socket.close();

console.log("DAXIE QISUN RUNTIME E2E PASS");
