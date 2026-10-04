import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const url = process.env.ES2_E2E_WS_URL;
const password = process.env.ES2_E2E_PASSWORD;
assert.ok(url && password);

function createPeer(id) {
  return { id, socket: null, output: "", lastSentAt: 0 };
}

async function connect(peer) {
  peer.output = "";
  peer.socket = new WebSocket(url);
  peer.socket.on("message", data => { peer.output += Buffer.from(data).toString("utf8"); });
  await new Promise((resolve, reject) => {
    peer.socket.once("open", resolve);
    peer.socket.once("error", reject);
  });
}

const waitForAfter = (peer, offset, matcher, timeout = 30000) => new Promise((resolve, reject) => {
  const started = Date.now();
  const timer = setInterval(() => {
    const tail = peer.output.slice(offset);
    const matched = typeof matcher === "string" ? tail.includes(matcher) : matcher.test(tail);
    if (matched) {
      clearInterval(timer);
      resolve(tail);
    } else if (Date.now() - started > timeout) {
      clearInterval(timer);
      reject(new Error(`等待 Playability Runtime 證據逾時：${String(matcher)}\n${tail.slice(-1800)}`));
    }
  }, 25);
});

async function sendLine(peer, text) {
  // Original Command Rate Limit／所有玩家輸入均保持真人可操作節奏。
  const delay = Math.max(0, 550 - (Date.now() - peer.lastSentAt));
  if (delay) await new Promise(resolve => setTimeout(resolve, delay));
  const offset = peer.output.length;
  peer.socket.send(`${text}\r\n`);
  peer.lastSentAt = Date.now();
  return offset;
}

async function command(peer, text, matcher = "> ", timeout = 30000) {
  const offset = await sendLine(peer, text);
  return waitForAfter(peer, offset, matcher, timeout);
}

async function login(peer, admin = false) {
  await connect(peer);
  await waitForAfter(peer, 0, "您的使用者代號");
  await command(peer, peer.id, "請輸入密碼");
  await command(peer, password, admin ? "目前權限: (admin)" : /客棧大堂|目前權限:/);
  await waitForAfter(peer, 0, "> ");
}

async function move(peer, verb, room) {
  const result = await command(peer, verb);
  assert.match(result, room, `${verb} 未到達預期房間`);
  assert.doesNotMatch(result, /沒有這個方向|無法往|你現在無法移動/);
  return result;
}

const play = createPeer("playprobe");
const death = createPeer("deathprobe");
await login(play, true);
assert.match(await command(play, "look"), /客棧大堂/);
assert.match(await command(play, "score"), /可玩性測試playprobe|等級|經驗/);
await command(play, "skills");
await command(play, "inventory");
console.log("PLAYABILITY_PASS:connection-login-character");

// World Navigation／只走 Original 房間出口與 enter/climb/out，不用管理員傳送取代地圖證據。
await move(play, "west", /廚房/);
await move(play, "enter 大灶", /大灶內/);
assert.match(await command(play, "get wooden sword"), /撿起一把木劍/);
assert.match(await command(play, "look wooden sword"), /木劍|硬木/);
await move(play, "out", /廚房/);
await move(play, "east", /客棧大堂/);
await command(play, "open east", /打開|已經是開著/);
await move(play, "east", /雪亭鎮廣場的西邊/);
await move(play, "north", /小廣場/);
await move(play, "south", /雪亭鎮廣場的西邊/);
await move(play, "east", /廣場中央/);
await move(play, "climb 榕樹", /榕樹上/);
await move(play, "down", /廣場中央/);
await move(play, "east", /雪亭鎮廣場東邊/);
await move(play, "east", /僻靜小巷/);
await move(play, "climb 圍牆", /廚房/);
await move(play, "climb 圍牆", /僻靜小巷/);
await move(play, "south", /藥鋪/);
await move(play, "north", /僻靜小巷/);
await move(play, "east", /僻靜小巷/);
await move(play, "east", /破舊大宅/);
await move(play, "east", /兩條河流的匯流處/);
await move(play, "west", /破舊大宅/);
await move(play, "climb 樑柱", /破舊大宅正廳/);
await move(play, "north", /河邊空地/);
await move(play, "south", /破舊大宅正廳/);
await move(play, "climb 樑柱", /破舊大宅/);
await move(play, "west", /僻靜小巷/);
await move(play, "north", /溪邊小路/);
await move(play, "enter 磨坊", /磨坊/);
await move(play, "out", /溪邊小路/);
await move(play, "north", /小徑|溪邊/);
await move(play, "north", /河|溪/);
await move(play, "south", /小徑|溪邊/);
await move(play, "northwest", /溪邊小路/);
await move(play, "west", /小路/);
await move(play, "west", /北街|街道/);
await move(play, "west", /雪亭鎮的驛站/);
await move(play, "east", /北街|街道/);
await move(play, "north", /蜿蜒的山路/);
await move(play, "south", /北街|街道/);
await move(play, "south", /北街|街道/);
await move(play, "east", /土地公廟/);
await move(play, "west", /北街|街道/);
await move(play, "south", /雪亭鎮廣場北邊/);
await move(play, "south", /廣場中央/);
await move(play, "south", /雪亭鎮廣場的南邊/);
await move(play, "east", /打鐵鋪子/);
await move(play, "west", /雪亭鎮廣場的南邊/);
await move(play, "south", /南街|街道/);
await move(play, "east", /小店鋪/);
await move(play, "west", /南街|街道/);
await move(play, "west", /貨棧|倉庫/);
await move(play, "east", /南街|街道/);
await move(play, "south", /雪亭鎮南邊的入口/);
await move(play, "north", /南街|街道/);
await move(play, "north", /雪亭鎮廣場的南邊/);
await move(play, "west", /雪亭鎮廣場的西南邊/);
await move(play, "west", /西街|街道/);
await move(play, "south", /私塾/);
await move(play, "north", /西街|街道/);
await move(play, "west", /西街|街道/);
await move(play, "west", /西街|街道/);
await move(play, "north", /雪亭鎮的鄉校/);
await move(play, "south", /西街|街道/);
await move(play, "west", /雪亭鎮西邊的官道/);
await move(play, "east", /西街|街道/);
await move(play, "east", /西街|街道/);
await move(play, "east", /西街|街道/);
await move(play, "east", /雪亭鎮廣場的西南邊/);
await move(play, "north", /雪亭鎮廣場的西邊/);
await move(play, "west", /客棧大堂/);
console.log("PLAYABILITY_PASS:world-navigation");

assert.match(await command(play, "look waiter"), /店小二/);
assert.match(await command(play, "ask waiter about 客棧"), /向店小二打聽/);
assert.match(await command(play, "list"), /包子|饅頭|雞/);
console.log("PLAYABILITY_PASS:npc-interaction");

assert.match(await command(play, "wield wooden sword"), /裝備.*木劍作武器/);
assert.match(await command(play, "unwield wooden sword"), /放下手中的.*木劍/);
console.log("PLAYABILITY_PASS:item-equipment");

// NPC death/respawn／以 Original NPC、Combat 與 room reset 驗證，不修改其數值或掉落。
await command(play, 'call me->set_skill("sword",200)');
await command(play, 'call me->set_attr("str",50)');
await command(play, "wield wooden sword");
await command(play, "open east", /打開|已經是開著/);
await move(play, "east", /雪亭鎮廣場的西邊/);
await move(play, "east", /廣場中央/);
await move(play, "climb 榕樹", /榕樹上/);
const npcDeathOffset = await sendLine(play, "kill arbao");
  await waitForAfter(play, npcDeathOffset, /不活了|死了|死去|魂魄離開了/, 90000);
assert.match(await command(play, "look corpse"), /阿寶|屍體|死了/);
assert.match(await command(play, "get blue cloth from corpse"), /藍布長衫|拿出|搜出/);
assert.match(await command(play, "wear blue cloth"), /穿上.*藍布長衫/);
assert.match(await command(play, "remove blue cloth"), /脫了下來|卸除/);
assert.match(await command(play, "call here->reset()"), /->reset\(\) =/);
assert.match(await command(play, "look arbao"), /阿寶/);
console.log("PLAYABILITY_PASS:npc-death-respawn");

// Player death/recovery／普通玩家被真實 Combat 擊敗後，以 Original 土地公廟漩渦復活。
await login(death, false);
await command(death, "open east", /打開|已經是開著/);
await move(death, "east", /雪亭鎮廣場的西邊/);
await move(death, "east", /廣場中央/);
await move(death, "climb 榕樹", /榕樹上/);
const playerDeathOffset = death.output.length;
// Deterministic Combat／可重現戰鬥：僅提高隔離診斷角色的木劍傷害，避免亂數低傷害
// 讓 90 秒測試逾時；deathprobe 仍是普通玩家，死亡、鬼魂移動與漩渦復活皆走 Original Runtime。
await command(play, 'call me->set_temp("apply/damage",100)');
await sendLine(play, "kill deathprobe");
await waitForAfter(death, playerDeathOffset, /你死了/, 90000);
await command(play, 'call me->set_temp("apply/damage",0)');
await move(death, "down", /廣場中央/);
await move(death, "north", /雪亭鎮廣場北邊/);
await move(death, "north", /北街|街道/);
await move(death, "east", /土地公廟/);
assert.match(await command(death, "look swirl"), /紅光|漩渦/);
assert.match(await command(death, "enter swirl"), /暈眩/);
await command(death, "score");
console.log("PLAYABILITY_PASS:player-death-recovery");

// Original 土地公廟復活會施加三秒忙碌狀態；依原始行為等待結束後再驗證存檔與離線。
await new Promise(resolve => setTimeout(resolve, 7000));
assert.match(await command(death, "save"), /檔案儲存完畢/);
const quitOffset = await sendLine(death, "quit");
await waitForAfter(death, quitOffset, "歡迎下次再來");
death.socket.close();
await new Promise(resolve => setTimeout(resolve, 250));
await login(death, false);
assert.match(await command(death, "look"), /土地公廟|客棧大堂/);
await command(death, "score");
console.log("PLAYABILITY_PASS:save-quit-reconnect-restore");

play.socket.close();
death.socket.close();
console.log("GAME_PLAYABILITY_COMPLETION_RUNTIME_PASS");
