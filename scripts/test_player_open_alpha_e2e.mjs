import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const url = process.env.ES2_E2E_WS_URL;
const password = process.env.ES2_E2E_PASSWORD;
const humanId = process.env.ES2_E2E_HUMAN_ID || "kinglook";
const avatarId = process.env.ES2_E2E_AVATAR_ID || "avataropen";
const thiefId = process.env.ES2_E2E_THIEF_ID || "thiefopen";
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

async function createCharacter({ id, raceChoice, raceLabel, genderChoice, name }) {
  const p = peer(id);
  await connect(p);
  await waitForAfter(p, 0, "您的使用者代號");
  await sendLine(p, id, /使用 .* 這個代號將會創造一個新的人物/);
  await sendChoice(p, "Y", "請設定您的密碼");
  await sendLine(p, password, "請再輸入一次您的密碼");
  await sendLine(p, password, "您的電子郵件地址");
  const raceMenu = await sendLine(p, "none", "請輸入編號 1 或 2");
  assert.match(raceMenu, /1\. Human（人類）/);
  assert.match(raceMenu, /2\. Avatar（克隆人）/);
  await sendChoice(p, `ES2RACE:${raceChoice}`, "您要扮演的哪種性別");
  await sendChoice(p, genderChoice, "您的顯示名稱");
  await sendLine(p, name, "您確定要創造這個角色嗎");
  const entered = await sendChoice(p, "Y", /目前權限: \(player\)/, 45000);
  assert.match(entered, /目前權限: \(player\)/);
  await waitForAfter(p, 0, /客棧大堂/);
  await waitForAfter(p, 0, "> ");

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
  assert.match(await command(p, "score"), scoreMatcher);
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
  assert.match(await command(p, "out"), /廚房/);
  assert.match(await command(p, "east"), /客棧大堂/);
  await command(p, "open east", /打開|已經是開著/);
  assert.match(await command(p, "east"), /廣場的西邊/);
  assert.match(await command(p, "east"), /廣場中央/);
  assert.match(await command(p, "north"), /小廣場|廣場北邊/);
  assert.match(await command(p, "look child"), /小孩/);
  const fightOffset = p.output.length;
  p.socket.send("fight child\r\n");
  p.lastSentAt = Date.now();
  const combat = await waitForAfter(p, fightOffset, /好呀.*比武|開始對.*發動攻擊|攻擊|閃躲|招架/, 30000);
  assert.doesNotMatch(combat, /這裡禁止戰鬥|你想攻擊誰/);
  await waitForAfter(p, fightOffset, /哇.*哭|打我/, 90000);
  await delay(2500);
  await command(p, "look");
  console.log(`PLAYER_COMBAT_PASS:${p.id}:source-backed-sparring`);
}

async function joinAlchemist(p) {
  // 小廣場 → 廣場中央 → 西邊 → 西南邊 → 西街 → 私塾，全程 Original exits。
  assert.match(await command(p, "south"), /廣場中央/);
  assert.match(await command(p, "west"), /廣場的西邊/);
  assert.match(await command(p, "south"), /西南邊/);
  assert.match(await command(p, "west"), /西街|街道/);
  assert.match(await command(p, "south"), /私塾/);
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

// Thief First／盜賊優先：gammer 依 Original Source 會 random_move；
// 先在世界剛載入時完成普通玩家食物→梳子→盜賊鏈，不用 admin 固定 NPC。
const thief = await createCharacter({ id: thiefId, raceChoice: "1", raceLabel: "human", genderChoice: "F", name: "盜賊測試員" });
await joinThief(thief);
await saveQuitRelogin(thief, /盜賊/);
assert.match(await command(thief, "skills -a"), /sneak|stealing|潛行|偷竊/);
console.log("PLAYER_THIEF_PERSISTENCE_PASS");
thief.socket.close();

// Human／人類：帳號與顯示名稱都刻意接近 KING，仍必須是普通玩家。
const human = await createCharacter({ id: humanId, raceChoice: "1", raceLabel: "human", genderChoice: "M", name: "KING" });
for (const denied of ["khome", "kgoto /d/snow/square", "call me->query_class()", "clone /obj/money/coin", "kadmin list"]) {
  const result = await command(human, denied);
  assert.match(result, /沒有這個指令|權限|不能|不允許|無法|只有 KING|What\?/);
}
console.log("PLAYER_SECURITY_BOUNDARY_PASS");
await enterInnAsPlayer(human);
await getEquipmentAndFight(human);
await joinAlchemist(human);
await saveQuitRelogin(human, /方士|龍圖丹派弟子/);
console.log("ORIGINAL_PLAYER_CREATION_HUMAN_E2E_PASS");
human.socket.close();

// Avatar／克隆人：同樣從不存在的帳號走完整 Original 創角，不複製 save fixture。
const avatar = await createCharacter({ id: avatarId, raceChoice: "2", raceLabel: "avatar", genderChoice: "F", name: "克隆測試員" });
await saveQuitRelogin(avatar, /平民/);
console.log("ORIGINAL_PLAYER_CREATION_AVATAR_E2E_PASS");
avatar.socket.close();

console.log("PLAYER_FULL_JOURNEY_E2E_PASS");
