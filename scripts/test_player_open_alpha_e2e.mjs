import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const url = process.env.ES2_E2E_WS_URL;
const password = process.env.ES2_E2E_PASSWORD;
const humanId = process.env.ES2_E2E_HUMAN_ID || "kinglook";
const avatarId = process.env.ES2_E2E_AVATAR_ID || "avataropen";
const thiefId = process.env.ES2_E2E_THIEF_ID || "thiefopen";
const leeId = process.env.ES2_E2E_LEE_ID || "leeopen";
assert.ok(url && password, "缺少隔離 Runtime WebSocket 或測試密碼");

const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

function peer(id) {
  return { id, socket: null, output: "", lastSentAt: 0 };
}

async function connect(p) {
  p.output = "";
  p.socket = new WebSocket(url);
  p.socket.on("message", data => { p.output += Buffer.from(data).toString("utf8"); });
  await new Promise((resolve, reject) => {
    p.socket.once("open", resolve);
    p.socket.once("error", reject);
  });
}

const waitForAfter = (p, offset, matcher, timeout = 30000) => new Promise((resolve, reject) => {
  const started = Date.now();
  const timer = setInterval(() => {
    const tail = p.output.slice(offset);
    const matched = typeof matcher === "string" ? tail.includes(matcher) : matcher.test(tail);
    if (matched) {
      clearInterval(timer);
      resolve(tail);
    } else if (Date.now() - started > timeout) {
      clearInterval(timer);
      reject(new Error(`等待普通玩家 Runtime 證據逾時：${String(matcher)}\n${tail.slice(-2200)}`));
    }
  }, 25);
});

async function throttle(p) {
  const wait = Math.max(0, 600 - (Date.now() - p.lastSentAt));
  if (wait) await delay(wait);
}

async function sendLine(p, value, matcher = "> ", timeout = 30000) {
  await throttle(p);
  const offset = p.output.length;
  p.socket.send(`${value}\r\n`);
  p.lastSentAt = Date.now();
  return waitForAfter(p, offset, matcher, timeout);
}

async function sendChoice(p, value, matcher, timeout = 30000) {
  await throttle(p);
  const offset = p.output.length;
  p.socket.send(value);
  p.lastSentAt = Date.now();
  return waitForAfter(p, offset, matcher, timeout);
}

async function command(p, value, matcher = "> ", timeout = 30000) {
  return sendLine(p, value, matcher, timeout);
}

async function waitForStatDeficit(p, label, minimum = 1, timeout = 50000) {
  const started = Date.now();
  while (Date.now() - started <= timeout) {
    const status = (await command(p, "hp")).replace(/\x1b\[[0-9;]*m/g, "");
    const match = status.match(new RegExp(`${label}\\s*(\\d+)\\/(\\d+)`));
    assert.ok(match, `hp 未顯示${label}目前值／上限`);
    if (Number(match[2]) - Number(match[1]) >= minimum) return status;
    await delay(1500);
  }
  throw new Error(`等待普通玩家${label}自然消耗逾時`);
}

async function createCharacter({ id, raceChoice, raceLabel, genderChoice, name }) {
  const p = peer(id);
  await connect(p);
  await waitForAfter(p, 0, "您的使用者代號");
  await sendLine(p, id, /使用 .* 這個代號將會創造一個新的人物/);
  await sendChoice(p, "Y", "請設定您的密碼");
  await sendLine(p, password, "請再輸入一次您的密碼");
  await sendLine(p, password, "您的電子郵件地址");
  const raceMenu = await sendLine(p, "none", "請輸入編號 1-12 或種族 ID");
  assert.match(raceMenu, /1\. Human（人類）/);
  assert.match(raceMenu, /2\. Avatar（人類族）/);
  assert.match(raceMenu, /3\. 黑齒/);
  assert.match(raceMenu, /8\. 刑天/);
  assert.match(raceMenu, /12\. 阿修羅/);
  await sendChoice(p, `ES2RACE:${raceChoice}`, "您要扮演的哪種性別");
  await sendChoice(p, genderChoice, "您的顯示名稱");
  await sendLine(p, name, "您確定要創造這個角色嗎");
  const entered = await sendChoice(p, "Y", /目前權限: \(player\)/, 45000);
  assert.match(entered, /目前權限: \(player\)/);
  await waitForAfter(p, 0, /客棧大堂/);
  await waitForAfter(p, 0, "> ");

  // 首次登入尚未執行 look、拾取或裝備時，兩種背包指令都必須有伺服器實際文字輸出。
  assert.match(await command(p, "i"), /身上|攜帶|沒有|物品|木劍/);
  assert.match(await command(p, "inventory"), /身上|攜帶|沒有|物品|木劍/);
  console.log(`PLAYER_COLD_LOGIN_INVENTORY_PASS:${id}`);
  assert.match(await command(p, "look"), /客棧大堂/);
  const score = await command(p, "score");
  assert.match(score, /平民/);
  assert.match(score, /等級|Level|級/);
  await command(p, "skills");
  await command(p, "inventory");
  console.log(`PLAYER_CREATION_PASS:${id}:${raceLabel}:player-commoner-level1`);
  return p;
}

async function saveQuitRelogin(p, scoreMatcher) {
  assert.match(await command(p, "save"), /檔案儲存完畢/);
  const quitOffset = p.output.length;
  p.socket.send("quit\r\n");
  await waitForAfter(p, quitOffset, "歡迎下次再來");
  p.socket.close();
  await delay(300);

  await connect(p);
  await waitForAfter(p, 0, "您的使用者代號");
  await sendLine(p, p.id, "請輸入密碼");
  const entered = await sendLine(p, password, /目前權限: \(player\)/, 45000);
  assert.match(entered, /目前權限: \(player\)/);
  await waitForAfter(p, 0, "> ");
  // 既有角色重新登入後，先查背包，再執行 look/score，避免被後續動作掩蓋首次指令故障。
  assert.match(await command(p, "i"), /身上|攜帶|沒有|物品|木劍|Inventory/i);
  assert.match(await command(p, "inventory"), /身上|攜帶|沒有|物品|木劍|Inventory/i);
  console.log(`PLAYER_RELOGIN_FIRST_COMMAND_INVENTORY_PASS:${p.id}`);
  assert.match(await command(p, "score"), scoreMatcher);
  // 登入後立即驗證 i 快捷鍵可回應；跨登入物品保存另列獨立證據，不誤報。
  assert.match(await command(p, "i"), /身上|攜帶|沒有|物品|木劍|Inventory/i);
  console.log(`PLAYER_PERSISTENCE_PASS:${p.id}`);
}

async function enterInnAsPlayer(p) {
  await command(p, "open east", /打開|已經是開著/);
  assert.match(await command(p, "east"), /雪亭鎮廣場的西邊/);
  assert.match(await command(p, "west"), /客棧大堂/);
  assert.match(await command(p, "look waiter"), /店小二|小二/);
  console.log(`PLAYER_WORLD_PASS:${p.id}:movement-npc`);
}

async function acquireFreeDumpling(p) {
  await command(p, "open east", /打開|已經是開著/);
  assert.match(await command(p, "east"), /廣場的西邊/);
  assert.match(await command(p, "east"), /廣場中央/);
  assert.match(await command(p, "east"), /廣場(?:的)?東邊/);
  assert.match(await command(p, "east"), /僻靜小巷/);
  assert.match(await command(p, "climb 圍牆"), /廚房/);
  assert.match(await command(p, "get dumpling"), /牛肉包子|包子/);
  assert.match(await command(p, "climb 圍牆"), /僻靜小巷/);
  assert.match(await command(p, "west"), /廣場(?:的)?東邊/);
  assert.match(await command(p, "west"), /廣場中央/);
}

async function getEquipmentAndFight(p) {
  assert.match(await command(p, "west"), /廚房/);
  assert.match(await command(p, "enter 大灶"), /大灶內/);
  assert.match(await command(p, "get wooden sword"), /撿起一把木劍/);
  assert.match(await command(p, "wield wooden sword"), /裝備.*木劍作武器/);
  assert.match(await command(p, "inventory"), /木劍/);
  // i 必須與 inventory 顯示相同裝備，包含剛裝備的木劍；不可只依賴玩家 alias。
  assert.match(await command(p, "i"), /木劍/);
  assert.match(await command(p, "out"), /廚房/);
  assert.match(await command(p, "east"), /客棧大堂/);
  await command(p, "open east", /打開|已經是開著/);
  assert.match(await command(p, "east"), /廣場的西邊/);
  assert.match(await command(p, "east"), /廣場中央/);
  assert.match(await command(p, "north"), /小廣場|廣場北邊/);
  assert.match(await command(p, "look child"), /小孩/);
  const scoreBeforeFight = await command(p, "score");
  const combatBefore = Number((scoreBeforeFight.match(/實戰經驗[^0-9]*([0-9]+)/) || [])[1] || 0);
  const martialBefore = Number((scoreBeforeFight.match(/武術造詣[^0-9]*([0-9]+)/) || [])[1] || 0);
  const fightOffset = p.output.length;
  p.socket.send("fight child\r\n");
  p.lastSentAt = Date.now();
  const combat = await waitForAfter(p, fightOffset, /好呀.*比武|開始對.*發動攻擊|攻擊|閃躲|招架|刺進|氣喘噓噓|呀 ～ 呀 ～|哇.*哭|打我/, 30000);
  assert.doesNotMatch(combat, /這裡禁止戰鬥|你想攻擊誰/);
  await waitForAfter(p, fightOffset, /哇.*哭|打我/, 90000);
  await delay(2500);
  const scoreAfterFight = await command(p, "score");
  const combatAfter = Number((scoreAfterFight.match(/實戰經驗[^0-9]*([0-9]+)/) || [])[1] || 0);
  const martialAfter = Number((scoreAfterFight.match(/武術造詣[^0-9]*([0-9]+)/) || [])[1] || 0);
  assert.ok(combatAfter >= combatBefore + 1, `combat score did not grow during damaging NPC combat: ${combatBefore} -> ${combatAfter}`);
  // 此段普通玩家只使用基本木劍；martial art 必須由已映射特殊武學的有效命中取得，不在此偽造。
  assert.equal(martialAfter, martialBefore, `plain weapon combat unexpectedly changed martial art: ${martialBefore} -> ${martialAfter}`);
  console.log(`PLAYER_COMBAT_SCORE_GROWTH_PASS:${p.id}:combat-${combatBefore}-${combatAfter}:plain-martial-unchanged-${martialAfter}`);
  const recovered = await command(p, "look");
  assert.match(recovered, /小廣場|廣場北邊/);
  // Combat Recovery／戰鬥結束後不能只看到畫面：普通玩家必須恢復可操作狀態並能繼續世界移動。
  assert.match(await command(p, "south"), /廣場中央/);
  assert.match(await command(p, "north"), /小廣場|廣場北邊/);
  assert.match(await command(p, "unwield wooden sword"), /放下.*木劍/);
  assert.match(await command(p, "inventory"), /木劍/);
  assert.match(await command(p, "wield wooden sword"), /裝備.*木劍作武器/);
  console.log(`PLAYER_EQUIPMENT_UNEQUIP_PASS:${p.id}:unwield-inventory-rewield`);
  console.log(`PLAYER_COMBAT_RECOVERY_PASS:${p.id}:command-and-movement-after-sparring`);
  console.log(`PLAYER_COMBAT_PASS:${p.id}:source-backed-sparring`);
}

async function exerciseSnowTownServices(p) {
  // Catalog-assisted discovery, Pinned Original authority:
  // /d/snow/smithy.c + /d/snow/bazar.c + /d/snow/npc/yu.c。
  // 只驗證普通新角能自然抵達並操作既有服務；不 clone、不給錢、不改屬性。
  assert.match(await command(p, "south"), /廣場中央/);
  assert.match(await command(p, "south"), /廣場/);
  assert.match(await command(p, "east"), /打鐵鋪子/);
  assert.match(await command(p, "look"), /火爐|鐵砧|打鐵鋪子/);
  assert.match(await command(p, "west"), /廣場/);
  assert.match(await command(p, "south"), /街道/);
  assert.match(await command(p, "east"), /魚記小鋪/);
  assert.match(await command(p, "look yu"), /魚天|魚家|錢莊/);
  const vendor = await command(p, "list");
  assert.match(vendor, /藍|帽|瓶|jacket|bottle|商品|價/i);
  const bank = await command(p, "look 匾額");
  assert.match(bank, /deposit|withdraw|convert|open account/);
  assert.match(await command(p, "west"), /街道/);
  assert.match(await command(p, "north"), /廣場/);
  assert.match(await command(p, "north"), /廣場中央/);
  assert.match(await command(p, "north"), /小廣場|廣場北邊/);
  console.log(`PLAYER_SNOW_SERVICES_PASS:${p.id}:smithy-vendor-bank-surface`);
}

async function exerciseOriginalLiterateSource(p) {
  // 王懷芝 Original acquire_skill 明示 literate 以 sit 聽三字經學習。
  // Scholar 轉職另有 random/int/literate 條件，本 gate 不偽造觸發結果。
  assert.match(await command(p, "south"), /廣場中央/);
  assert.match(await command(p, "west"), /廣場/);
  assert.match(await command(p, "south"), /廣場/);
  assert.match(await command(p, "west"), /街道/);
  assert.match(await command(p, "south"), /私塾/);
  assert.match(await command(p, "look wang"), /王懷芝|王老師|私塾|讀書/);
  const sit = await command(p, "sit");
  assert.match(sit, /坐|聽講|念書|唸書/);
  console.log(`PLAYER_LITERATE_SOURCE_PASS:${p.id}:wang-whaiz-sit-learning-entry`);
  // 保持在私塾，直接銜接既有陳維俠方士路線。
}

async function exerciseSnowPostOffice(p) {
  // 朋友 catalog 指向 Pinned Original /d/snow/post_office.c；此 Journey 仍以 Original LPC 行為為驗收依據。
  // 小廣場 → 廣場中央 → 北廣場 → 北街 → 雪亭驛，普通玩家 request 信札後再離開。
  assert.match(await command(p, "south"), /廣場中央/);
  assert.match(await command(p, "north"), /廣場/);
  assert.match(await command(p, "north"), /街道/);
  assert.match(await command(p, "north"), /街道/);
  assert.match(await command(p, "west"), /雪亭驛/);
  const request = await command(p, "request");
  assert.match(request, /寫著你名字的信札|已經領有一個信札/);
  assert.match(await command(p, "east"), /街道/);
  assert.match(await command(p, "south"), /街道/);
  assert.match(await command(p, "south"), /廣場/);
  assert.match(await command(p, "south"), /廣場中央/);
  assert.match(await command(p, "north"), /小廣場|廣場北邊/);
  console.log(`PLAYER_SNOW_POST_OFFICE_PASS:${p.id}:source-backed-request-mailbox-retire`);
}

async function joinAlchemist(p) {
  // 前一步 literate Source Gate 已停在同一間私塾；直接銜接陳維俠方士鏈，
  // 避免把「已在私塾」誤當成仍在小廣場而造成假路徑 FAIL。
  assert.match(await command(p, "look"), /私塾|王懷芝|陳維俠/);
  assert.match(await command(p, "look chen"), /陳維俠|牙山居士/);
  const first = p.output.length;
  p.socket.send("apprentice chen\r\n");
  p.lastSentAt = Date.now();
  await waitForAfter(p, first, /多你一個也不妨|門徒不下千人/, 30000);
  await delay(2800);
  const accepted = await command(p, "apprentice chen", /龍圖丹派弟子|磕了四個響頭|師父在上/, 30000);
  assert.doesNotMatch(accepted, /似乎沒有收你為徒的打算|什麼\?\?/);
  const score = await command(p, "score");
  assert.match(score, /方士/);
  assert.match(score, /龍圖丹派弟子/);
  console.log(`PLAYER_CLASS_PASS:${p.id}:alchemist`);
}

async function joinThief(p) {
  await acquireFreeDumpling(p);
  assert.match(await command(p, "climb 榕樹"), /榕樹上/);
  const foodOffset = p.output.length;
  p.socket.send("give dumpling to arbao\r\n");
  p.lastSentAt = Date.now();
  await waitForAfter(p, foodOffset, /不該白吃|這個送給你|梳子/, 30000);
  await delay(2600);
  assert.match(await command(p, "inventory"), /紅木梳|梳子/);
  assert.match(await command(p, "down"), /廣場中央/);
  const combOffset = p.output.length;
  p.socket.send("give comb to gammer\r\n");
  p.lastSentAt = Date.now();
  await waitForAfter(p, combOffset, /我的梳子|祖奶奶|成為小偷/, 30000);
  await delay(1800);
  const joinOffset = p.output.length;
  p.socket.send("say 祖奶奶\r\n");
  p.lastSentAt = Date.now();
  await waitForAfter(p, joinOffset, "你正式成為一名盜賊了", 30000);
  assert.match(await command(p, "score"), /盜賊/);
  // Original skills 會在有學習進度但等級尚為 0 時過濾預設輸出；-a 是原有的完整顯示。
  const skills = await command(p, "skills -a");
  assert.match(skills, /sneak|stealing|潛行|偷竊/);
  console.log(`PLAYER_TRAINING_PASS:${p.id}:npc-improve_skill`);
  console.log(`PLAYER_CLASS_PASS:${p.id}:thief`);
}

async function exerciseThiefTraining(p) {
  // Original sneak 指令本身會在 busy callback 呼叫 improve_skill("sneak", ...)；
  // 這裡只用普通玩家實際操作觸發，不以 call/admin 直接修改技能。
  const offset = p.output.length;
  p.socket.send("sneak west\r\n");
  p.lastSentAt = Date.now();
  await waitForAfter(p, offset, /小心翼翼|看起來，似乎還沒有人發覺|廣場的西邊/, 30000);
  await delay(5000);
  // Original sneak 的訓練 callback 與實際移動不是同一個驗收點；低等級潛行可能訓練成功但留在原地。
  // 先驗證技能進度，再用普通 west 指令確認玩家仍可正常移動，避免把隨機潛行結果誤判成 Runtime FAIL。
  assert.match(await command(p, "skills -a"), /sneak|潛行/);
  const room = await command(p, "look");
  if (/廣場中央/.test(room)) assert.match(await command(p, "west"), /客棧大堂|廣場的西邊|街道/);
  else assert.match(room, /客棧大堂|廣場的西邊|街道/);
  console.log(`PLAYER_ACTIVE_TRAINING_PASS:${p.id}:sneak-improve_skill`);
}

async function findRoamingGammer(p) {
  // Roaming NPC discovery／不以 KING/Admin/goto 固定瞎眼老太婆；普通玩家沿她可達的雪亭區域自行尋找。
  const probes = [
    ["look gammer", /瞎眼老太婆/],
    ["west", /廣場/], ["look gammer", /瞎眼老太婆/],
    ["east", /廣場中央/], ["east", /廣場/], ["look gammer", /瞎眼老太婆/],
    ["west", /廣場中央/], ["north", /廣場/], ["look gammer", /瞎眼老太婆/],
    ["south", /廣場中央/]
  ];
  for (const [cmd, matcher] of probes) {
    const out = await command(p, cmd);
    if (matcher.test(out) && /瞎眼老太婆/.test(out)) return true;
  }
  return false;
}

// Thief Journey／盜賊旅程：保留 Original random_move，不以管理權限搬動 NPC。
// 此 helper 供獨立 roaming-NPC gate 使用；找不到 NPC 時應標示 PENDING，而不是偽造 PASS。

async function exerciseLeeVillageJourney(p) {
  // ES2M Reconstruction／普通玩家只用世界出口進入李家村；禁止 goto/call/admin。
  await command(p, "open east", /打開|已經是開著/);
  assert.match(await command(p, "east"), /廣場的西邊/);
  assert.match(await command(p, "east"), /廣場中央/);
  assert.match(await command(p, "east"), /廣場(?:的)?東邊/);
  // 由雪亭東側道路前往東門；每一步仍由實際房間輸出驗證，不直接搬動角色。
  // Pinned Original：square -> square_e -> epath -> lane1 -> ruin1 -> egate。
  const route = ["east", "east", "east", "east"];
  for (const step of route) await command(p, step);
  const egate = await command(p, "look");
  assert.match(egate, /河邊|李家村|northeast/);
  const entrance = await command(p, "northeast");
  assert.match(entrance, /李家村|村口/);
  assert.match(await command(p, "look traveller"), /旅客|旅人/);
  assert.match(await command(p, "north"), /村口大門/);
  assert.match(await command(p, "look guard"), /守衛|衛兵/);

  // Waterskin Journey／牛皮水袋：沿正常地圖前往雜貨鋪購買，驗證容器單位、價值與飲水。
  assert.match(await command(p, "north"), /街道/);
  assert.match(await command(p, "north"), /街道/);
  assert.match(await command(p, "north"), /廣場/);
  assert.match(await command(p, "west"), /廣場/);
  assert.match(await command(p, "north"), /廣場/);
  assert.match(await command(p, "north"), /道路|街道|石子路/);
  assert.match(await command(p, "north"), /道路|街道|石子路/);
  assert.match(await command(p, "west"), /雜貨鋪/);
  assert.match(await command(p, "look zhong"), /李忠|雜貨/);
  const grocery = await command(p, "list zhong");
  assert.match(grocery, /牛皮水袋/);
  assert.match(grocery, /五十文錢/);
  assert.match(await command(p, "buy 1 waterskin from zhong"), /買下一個牛皮水袋/);
  let inventory = await command(p, "inventory");
  assert.match(inventory, /一百五十文錢/);
  assert.match(inventory, /牛皮水袋/);
  // 不以管理指令改數值：等待 living heart beat 的既有 TYPE_WASTING 自然消耗後再飲用。
  await waitForStatDeficit(p, "飲水");
  assert.match(await command(p, "drink from waterskin"), /從牛皮水袋喝了幾口清水/);
  console.log(`PLAYER_ES2M_WATERSKIN_DRINK_PASS:${p.id}:source-route-value-unit-liquid`);

  assert.match(await command(p, "east"), /道路|街道|石子路/);
  assert.match(await command(p, "south"), /道路|街道|石子路/);
  assert.match(await command(p, "south"), /廣場/);
  assert.match(await command(p, "south"), /廣場/);
  assert.match(await command(p, "east"), /廣場/);
  assert.match(await command(p, "south"), /街道/);
  assert.match(await command(p, "south"), /街道/);
  assert.match(await command(p, "south"), /村口大門/);
  assert.match(await command(p, "south"), /村口/);
  assert.match(await command(p, "southwest"), /河邊|李家村|northeast/);
  console.log(`PLAYER_ES2M_LEE_MAP_NPC_PASS:${p.id}:snow-egate-lee-roundtrip`);
}

async function exerciseShopQuantityJourney(p) {
  // Source-backed Money／來源支持的金錢：普通玩家自行拾取木刀並到李記當鋪賣出，
  // 不使用 clone、call、KING 或直接修改存檔來提供測試貨幣。
  assert.match(await command(p, "west"), /廚房/);
  assert.match(await command(p, "enter 大灶"), /大灶內/);
  assert.match(await command(p, "get wooden blade"), /撿起一把木刀/);
  assert.match(await command(p, "out"), /廚房/);
  assert.match(await command(p, "east"), /客棧大堂/);
  await command(p, "open east", /打開|已經是開著/);
  for (let i = 0; i < 7; i++) await command(p, "east");
  assert.match(await command(p, "northeast"), /李家村|村口/);
  assert.match(await command(p, "north"), /村口大門/);
  assert.match(await command(p, "north"), /街道/);
  assert.match(await command(p, "north"), /街道/);
  assert.match(await command(p, "west"), /李記當鋪/);
  assert.match(await command(p, "pawn wooden blade"), /典當|二兩又四十文錢/);
  let inventory = await command(p, "inventory");
  assert.match(inventory, /四十文錢/);
  assert.match(inventory, /二兩碎銀/);

  assert.match(await command(p, "east"), /街道/);
  assert.match(await command(p, "south"), /街道/);
  assert.match(await command(p, "south"), /村口大門/);
  assert.match(await command(p, "south"), /村口/);
  assert.match(await command(p, "southwest"), /河邊|李家村/);
  let snowRoom = "";
  for (let i = 0; i < 7; i++) snowRoom = await command(p, "west");
  assert.match(snowRoom, /客棧大堂/);

  // Money Exchange／普通玩家到既有錢莊換零錢，避免以管理指令製造測試貨幣。
  await command(p, "open east", /打開|已經是開著/);
  assert.match(await command(p, "east"), /廣場的西邊/);
  assert.match(await command(p, "east"), /廣場中央/);
  assert.match(await command(p, "south"), /廣場/);
  assert.match(await command(p, "south"), /街道/);
  assert.match(await command(p, "east"), /魚記小鋪/);
  assert.match(await command(p, "convert 2 silver to coin"), /換成二百文錢/);
  assert.match(await command(p, "inventory"), /二百四十文錢/);
  assert.match(await command(p, "west"), /街道/);
  assert.match(await command(p, "north"), /廣場/);
  assert.match(await command(p, "north"), /廣場中央/);
  assert.match(await command(p, "west"), /廣場的西邊/);
  assert.match(await command(p, "west"), /客棧大堂/);

  const list = await command(p, "list waiter");
  assert.match(list, /牛肉包子/);
  assert.match(list, /饅頭/);
  assert.match(await command(p, "buy mystery from waiter"), /並沒有賣/);
  assert.match(await command(p, "buy 31 chicken from waiter"), /只剩下三十隻/);
  assert.match(await command(p, "buy 1 chicken from waiter"), /錢不夠/);
  inventory = await command(p, "inventory");
  assert.match(inventory, /二百四十文錢/);

  // Delivery Failure／交貨失敗：點餐後立刻離房，店小二取消交貨且不得扣款。
  const leaveBuyOffset = p.output.length;
  p.socket.send("buy 1 dumpling from waiter\r\n");
  p.lastSentAt = Date.now();
  await waitForAfter(p, leaveBuyOffset, /馬上來/);
  const leaveOffset = p.output.length;
  p.socket.send("east\r\n");
  p.lastSentAt = Date.now();
  await waitForAfter(p, leaveOffset, /廣場的西邊/);
  await delay(3500);
  const unchanged = await command(p, "inventory");
  assert.match(unchanged, /二百四十文錢/);
  assert.doesNotMatch(unchanged, /牛肉包子/);
  assert.match(await command(p, "west"), /客棧大堂/);

  // Single + Quantity／單件與批量：同一普通玩家交易並核對扣款、庫存與物品數量。
  const singleOffset = p.output.length;
  p.socket.send("buy 1 dumpling from waiter\r\n");
  p.lastSentAt = Date.now();
  await waitForAfter(p, singleOffset, /馬上來/);
  await waitForAfter(p, singleOffset, /買下一個牛肉包子/, 30000);
  inventory = await command(p, "inventory");
  assert.match(inventory, /二百三十文錢/);
  assert.match(inventory, /牛肉包子/);
  assert.match(await command(p, "buy 50 dumpling from waiter"), /只剩下四十九個/);

  const quantityOffset = p.output.length;
  p.socket.send("buy 3 manto from waiter\r\n");
  p.lastSentAt = Date.now();
  await waitForAfter(p, quantityOffset, /馬上來/);
  await waitForAfter(p, quantityOffset, /買下三個饅頭/, 30000);
  inventory = await command(p, "inventory");
  assert.match(inventory, /二百文錢/);
  assert.match(inventory, /三個饅頭|饅頭.*三個/);
  // 新角色出生時飽食已滿；先驗證正式容量限制，且失敗不得吞掉已購商品。
  assert.match(await command(p, "eat dumpling"), /肚子已經裝不下/);
  inventory = await command(p, "inventory");
  assert.match(inventory, /牛肉包子/);
  assert.match(inventory, /三個饅頭|饅頭.*三個/);
  console.log(`PLAYER_FOOD_CAPACITY_PASS:${p.id}:full-stat-rejection-item-retained`);
  console.log(`PLAYER_ES2M_SHOP_QUANTITY_PASS:${p.id}:ordinary-source-money-atomic-delivery-persistence-ready`);
}

// Human／人類：帳號與顯示名稱都刻意接近 KING，仍必須是普通玩家。
const human = await createCharacter({ id: humanId, raceChoice: "1", raceLabel: "human", genderChoice: "M", name: "KING" });
for (const denied of ["khome", "kgoto /d/snow/square", "call me->query_class()", "clone /obj/money/coin", "kadmin list"]) {
  const result = await command(human, denied);
  assert.match(result, /沒有這個指令|權限|不能|不允許|無法|只有 KING|What\?/);
}
console.log("PLAYER_SECURITY_BOUNDARY_PASS");
await enterInnAsPlayer(human);
// 登入後尚未拾取任何物品時，i 必須清楚回應空背包，而非沒有畫面。
assert.match(await command(human, "i"), /目前.*身上沒有任何東西|身上帶著下列這些東西/);
console.log("PLAYER_LOGIN_INITIAL_INVENTORY_PASS");
await getEquipmentAndFight(human);
await exerciseSnowPostOffice(human);
await exerciseSnowTownServices(human);
await exerciseOriginalLiterateSource(human);
await joinAlchemist(human);
await saveQuitRelogin(human, /方士|龍圖丹派弟子/);
// P0：木劍在存檔、quit、重新登入後必須仍存在；不把指令有回應誤當物品持久化。
assert.match(await command(human, "i"), /木劍/);
console.log("PLAYER_WOODSWORD_AUTOLOAD_RELOGIN_PASS");
console.log("ORIGINAL_PLAYER_CREATION_HUMAN_E2E_PASS");
human.socket.close();

// Avatar／人類族：同樣從不存在的帳號走完整 Original 創角，不複製 save fixture。
const avatar = await createCharacter({ id: avatarId, raceChoice: "2", raceLabel: "avatar", genderChoice: "F", name: "人類族測試員" });
// Avatar Basic World Journey／人類族不能只停在創角畫面：必須以普通玩家身份真正進入世界、移動、看 NPC、操作背包。
await enterInnAsPlayer(avatar);
assert.match(await command(avatar, "inventory"), /你身上|攜帶|沒有|物品|Inventory/i);
console.log("PLAYER_AVATAR_WORLD_PASS:movement-npc-inventory");
await saveQuitRelogin(avatar, /平民/);
console.log("ORIGINAL_PLAYER_CREATION_AVATAR_E2E_PASS");
avatar.socket.close();

// Lee Village／李家村 ES2M Reconstruction：獨立普通玩家 Journey，驗證世界連線與 NPC clone。
const lee = await createCharacter({ id: leeId, raceChoice: "1", raceLabel: "human", genderChoice: "M", name: "李村旅人" });
await exerciseShopQuantityJourney(lee);
await exerciseLeeVillageJourney(lee);
await saveQuitRelogin(lee, /平民/);
const leeInventory = await command(lee, "inventory");
assert.match(leeInventory, /一百五十文錢/);
// Original 食物沒有 autoload 契約；本 Gate 只宣告交易餘額跨登入保存，
// 不為測試補造包子／饅頭的永久物品行為。
console.log("PLAYER_ES2M_SHOP_BALANCE_PERSISTENCE_PASS:ordinary-save-quit-relogin");
lee.socket.close();

console.log("PLAYER_FULL_JOURNEY_E2E_PASS");
