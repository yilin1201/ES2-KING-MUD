import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const url = process.env.ES2_E2E_WS_URL;
const password = process.env.ES2_E2E_KING_PASSWORD;
const startStage = process.env.ES2_E2E_START_STAGE ?? "npc";
assert.ok(url && password);
const stages = ["npc", "items", "combat", "skills", "school"];
assert.ok(stages.includes(startStage));
const shouldRun = stage => stages.indexOf(stage) >= stages.indexOf(startStage);
const pass = stage => console.log(`E2E_STAGE_PASS:${stage}`);

const socket = new WebSocket(url);
let output = "";
socket.on("message", data => { output += Buffer.from(data).toString("utf8"); });

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
      reject(new Error(`等待 Runtime 證據逾時：${String(matcher)}\n${tail.slice(-1000)}`));
    }
  }, 25);
});

async function command(text, matcher = "> ", timeout = 20000) {
  const offset = output.length;
  socket.send(`${text}\r\n`);
  return waitForAfter(offset, matcher, timeout);
}

await new Promise((resolve, reject) => {
  socket.once("open", resolve);
  socket.once("error", reject);
});
await waitForAfter(0, "您的使用者代號");
await command("king", "請輸入密碼");
await command(password, "目前權限: (admin)");
await waitForAfter(0, "客棧大堂");
await new Promise(resolve => setTimeout(resolve, 1200));

if (shouldRun("npc")) {
  // NPC Interaction／NPC 互動：真實載入店小二，查看 NPC 並執行其 Vendor action。
  await command("goto /d/snow/inn_hall", "客棧大堂");
  const npcLook = await command("look waiter");
  assert.match(npcLook, /店小二|list 看可以點什麼菜/);
  const npcList = await command("list");
  assert.match(npcList, /店小二|價錢|包子|饅頭|雞/);
  pass("npc");
}

// Items / Equipment／物品與裝備：取得 Original 木劍、裝備後由 inventory 確認。
if (shouldRun("items")) {
  await command("goto /d/snow/fireplace", "大灶內");
  const getItem = await command("get wooden sword");
  assert.match(getItem, /撿起一把木劍/);
  const wield = await command("wield wooden sword");
  assert.match(wield, /裝備(?:一把)?木劍作武器/);
  const inventory = await command("inventory");
  assert.match(inventory, /木劍/);
  pass("items");
}

// Combat／戰鬥：在可戰鬥房間向 Original NPC 發動真實 kill，等待攻防輸出後由巫師 halt 安全停止。
if (shouldRun("combat")) {
  await command("goto /d/snow/tree", "榕樹上");
  const combatStartOffset = output.length;
  socket.send("kill arbao\r\n");
  const combat = await waitForAfter(combatStartOffset, /納命來|不是你死就是我活|忌日|攻擊|招架|閃躲|命中/, 20000);
  assert.doesNotMatch(combat, /這裡不准戰鬥|這裡沒有這個人/);
  // KING 的 halt 名稱會解析到管理員關機指令；測試以離開戰鬥房間安全結束隔離戰鬥，
  // 避免關閉 Driver，也不更動 Original command precedence（指令優先順序）。
  await command("goto /d/snow/inn_hall", "客棧大堂");
  pass("combat");
}

// Skills／技能：既有 KING fixture 的 Expansion 武學進度必須由真正 Runtime 指令讀取，
// 並同時確認 Original skills 指令仍能執行，不以靜態欄位代替。
if (shouldRun("skills")) {
  const martial = await command("kingmartial yijinjing 300");
  assert.match(martial, /易筋經 Lv\.300／黑級無極境/);
  const skills = await command("skills");
  assert.match(skills, /技能狀態|目前並沒有學會任何技能/);
  pass("skills");
}

// School / Apprentice／門派與拜師：進入 Original 私塾，實際觸發陳維俠收徒對話並再次拜師完成關係。
if (shouldRun("school")) {
  await command("goto /d/snow/school", "私塾");
  const schoolNpc = await command("look chen");
  assert.match(schoolNpc, /陳維俠|牙山居士/);
  const firstApprenticeOffset = output.length;
  socket.send("apprentice chen\r\n");
  await waitForAfter(firstApprenticeOffset, /多你一個也不妨|門徒不下千人/, 30000);
  // Original do_chat 會在最後一句輸出後的下一個排程才執行 set_flag callback；
  // 等待該既有非同步狀態完成，再送第二次 apprentice。
  await new Promise(resolve => setTimeout(resolve, 2500));
  const apprentice = await command("apprentice chen", /龍圖丹派弟子|磕了四個響頭|師父在上/, 15000);
  assert.doesNotMatch(apprentice, /似乎沒有收你為徒的打算|什麼\?\?/);
  const score = await command("score");
  assert.match(score, /龍圖丹派弟子|方士|alchemist/);
  pass("school");
}

socket.close();
