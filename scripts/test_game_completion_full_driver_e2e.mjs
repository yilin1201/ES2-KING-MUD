import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const url = process.env.ES2_E2E_WS_URL;
const password = process.env.ES2_E2E_KING_PASSWORD;
const startStage = process.env.ES2_E2E_START_STAGE ?? "npc";
assert.ok(url && password);
const stages = ["npc", "economy", "items", "combat", "skills", "school"];
assert.ok(stages.includes(startStage));
const shouldRun = stage => stages.indexOf(stage) >= stages.indexOf(startStage);
const pass = stage => console.log(`E2E_STAGE_PASS:${stage}`);
const fail = (stage, error) => {
  const message = error instanceof Error ? error.message : String(error);
  console.error(`E2E_STAGE_FAIL:${stage}:${message}`);
  throw error;
};
const runStage = async (stage, fn) => {
  if (!shouldRun(stage)) return;
  try {
    await fn();
    pass(stage);
  } catch (error) {
    fail(stage, error);
  }
};

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
      reject(new Error(`等待 Runtime 證據逾時：${String(matcher)}\n${tail.slice(-1000)}`));
    }
  }, 25);
});

async function command(text, matcher = "> ", timeout = 20000) {
  // Original Command Rate Limit／原作指令節流：完整旅程跨多個段落共用同一玩家，
  // 每個玩家輸入都依真人節奏送出，避免把原作防洗機制誤判成 Gameplay FAIL。
  const delay = Math.max(0, 550 - (Date.now() - lastSentAt));
  if (delay) await new Promise(resolve => setTimeout(resolve, delay));
  const offset = output.length;
  socket.send(`${text}\r\n`);
  lastSentAt = Date.now();
  return waitForAfter(offset, matcher, timeout);
}

async function sendLine(text) {
  const delay = Math.max(0, 550 - (Date.now() - lastSentAt));
  if (delay) await new Promise(resolve => setTimeout(resolve, delay));
  const offset = output.length;
  socket.send(`${text}\r\n`);
  lastSentAt = Date.now();
  return offset;
}

await connect();
await waitForAfter(0, "您的使用者代號");
await command("king", "請輸入密碼");
await command(password, "目前權限: (admin)");
await waitForAfter(0, "客棧大堂");
await new Promise(resolve => setTimeout(resolve, 1200));

// Core Player Journey／核心玩家旅程：明確以玩家指令驗證進入世界、場景、狀態、物品與移動，
// 後續五段沿用同一條連線，不以管理員傳送取代這一段 Movement 證據。
assert.match(await command("look"), /客棧大堂/);
assert.match(await command("score"), /KING|目前權限|等級|經驗/);
await command("inventory");
assert.match(await command("west"), /廚房/);

await runStage("npc", async () => {
  // NPC Interaction／NPC 互動：真實載入店小二，查看 NPC 並執行其 Vendor action。
  await command("goto /d/snow/inn_hall", "客棧大堂");
  const npcLook = await command("look waiter");
  assert.match(npcLook, /店小二|list 看可以點什麼菜/);
  const npcList = await command("list");
  assert.match(npcList, /店小二|價錢|包子|饅頭|雞/);
});

// Economy / Shop／經濟與商店：用 Original 巫師指令只在隔離測試角色建立測試貨幣，
// 再由玩家的 buy 指令走過 vendor、can_afford、pay_money 與交貨流程；不修改正式 KING 存檔。
await runStage("economy", async () => {
  await command("goto /d/snow/inn_hall", "客棧大堂");
  const cloned = await command("clone 100 /obj/money/coin");
  assert.match(cloned, /錢複製成功/);
  const before = await command("inventory");
  assert.match(before, /一百文錢/);

  const purchaseOffset = await sendLine("buy dumpling from waiter");
  const purchase = await waitForAfter(purchaseOffset, /買下一個牛肉包子|送到.*面前/, 30000);
  assert.doesNotMatch(purchase, /錢不夠|找不開|不願意跟你交易/);
  const after = await command("inventory");
  assert.match(after, /九十文錢/);
  assert.match(after, /牛肉包子/);
});

// Items / Equipment／物品與裝備：取得 Original 木劍、裝備後由 inventory 確認。
await runStage("items", async () => {
  await command("goto /d/snow/fireplace", "大灶內");
  const getItem = await command("get wooden sword");
  assert.match(getItem, /撿起一把木劍/);
  const wield = await command("wield wooden sword");
  assert.match(wield, /裝備(?:一把)?木劍作武器/);
  const inventory = await command("inventory");
  assert.match(inventory, /木劍/);
});

// Combat／戰鬥：在可戰鬥房間向 Original NPC 發動真實 kill，等待攻防輸出後由巫師 halt 安全停止。
await runStage("combat", async () => {
  // Original MAX_COMMAND_PER_SECOND／每秒指令上限：Items 段會連續完成取得、裝備與查看，
  // 進入戰鬥前跨過限速窗口，確保 kill 驗證的是 Combat Runtime 而不是自動測試輸入速度。
  await new Promise(resolve => setTimeout(resolve, 2500));
  await command("goto /d/snow/tree", "榕樹上");
  const combatStartOffset = await sendLine("kill arbao");
  const combat = await waitForAfter(combatStartOffset, /納命來|不是你死就是我活|忌日|攻擊|招架|閃躲|命中/, 20000);
  assert.doesNotMatch(combat, /這裡不准戰鬥|這裡沒有這個人/);
  // KING 的 halt 名稱會解析到管理員關機指令；測試以離開戰鬥房間安全結束隔離戰鬥，
  // 避免關閉 Driver，也不更動 Original command precedence（指令優先順序）。
  await command("goto /d/snow/inn_hall", "客棧大堂");
});

// Skills／技能：既有 KING fixture 的 Expansion 武學進度必須由真正 Runtime 指令讀取，
// 並同時確認 Original skills 指令仍能執行，不以靜態欄位代替。
await runStage("skills", async () => {
  // Original MAX_COMMAND_PER_SECOND／每秒指令上限：Combat 會由 Driver 自動產生多個回合，
  // 即使測試端只送出少量指令，也可能占滿同一秒的命令窗口。依真人操作節奏等待後再驗證武學，
  // 避免把「下指令速度太快」誤判成 Skills Runtime 失敗。
  await new Promise(resolve => setTimeout(resolve, 2500));
  const martial = await command("kingmartial yijinjing 300");
  assert.match(martial, /易筋經 Lv\.300／黑級無極境/);
  const skills = await command("skills");
  assert.match(skills, /技能狀態|目前並沒有學會任何技能/);
});

// School / Apprentice／門派與拜師：進入 Original 私塾，實際觸發陳維俠收徒對話並再次拜師完成關係。
await runStage("school", async () => {
  // Original MAX_COMMAND_PER_SECOND／每秒指令上限：前四段已在同一 Session 連續操作，
  // 進入門派段前跨過限速窗口，避免把真人可用功能誤判成指令不存在。
  await new Promise(resolve => setTimeout(resolve, 2500));
  await command("goto /d/snow/school", "私塾");
  const schoolNpc = await command("look chen");
  assert.match(schoolNpc, /陳維俠|牙山居士/);
  const firstApprenticeOffset = await sendLine("apprentice chen");
  await waitForAfter(firstApprenticeOffset, /多你一個也不妨|門徒不下千人/, 30000);
  // Original do_chat 會在最後一句輸出後的下一個排程才執行 set_flag callback；
  // 等待該既有非同步狀態完成，再送第二次 apprentice。
  await new Promise(resolve => setTimeout(resolve, 2500));
  const apprentice = await command("apprentice chen", /龍圖丹派弟子|磕了四個響頭|師父在上/, 15000);
  assert.doesNotMatch(apprentice, /似乎沒有收你為徒的打算|什麼\?\?/);
  const score = await command("score");
  assert.match(score, /龍圖丹派弟子|方士|alchemist/);
});

// Character Lifecycle／角色生命週期：同一 Full Journey 完成存檔、離線與新連線重登，
// 第二次登入必須重新通過 Original 密碼驗證並回到遊戲世界。
assert.match(await command("save"), /檔案儲存完畢/);
const quitOffset = await sendLine("quit");
await waitForAfter(quitOffset, "歡迎下次再來");
socket.close();
await new Promise(resolve => setTimeout(resolve, 150));

await connect();
await waitForAfter(0, "您的使用者代號");
await command("king", "請輸入密碼");
await command(password, "目前權限: (admin)");
await waitForAfter(0, "> ");
assert.match(await command("look"), /私塾|客棧大堂|天神殿|無極之境/);
await command("score");
await command("inventory");
console.log("E2E_LIFECYCLE_PASS:save-quit-relogin");

socket.close();
