import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const url = process.env.ES2_E2E_WS_URL;
const password = process.env.ES2_E2E_KING_PASSWORD;
assert.ok(url && password);

const peers = new Map();
let lastSentAt = 0;

async function connect(name) {
  const peer = { socket: new WebSocket(url), output: "" };
  peer.socket.on("message", data => { peer.output += Buffer.from(data).toString("utf8"); });
  await new Promise((resolve, reject) => {
    peer.socket.once("open", resolve);
    peer.socket.once("error", reject);
  });
  peers.set(name, peer);
  return peer;
}

const waitForAfter = (peer, offset, matcher, timeout = 20000) => new Promise((resolve, reject) => {
  const started = Date.now();
  const timer = setInterval(() => {
    const tail = peer.output.slice(offset);
    const matched = typeof matcher === "string" ? tail.includes(matcher) : matcher.test(tail);
    if (matched) { clearInterval(timer); resolve(tail); }
    else if (Date.now() - started > timeout) {
      clearInterval(timer);
      reject(new Error(`等待 Runtime 證據逾時：${String(matcher)}\n${tail.slice(-1200)}`));
    }
  }, 25);
});

async function send(peer, text) {
  const delay = Math.max(0, 400 - (Date.now() - lastSentAt));
  if (delay) await new Promise(resolve => setTimeout(resolve, delay));
  const offset = peer.output.length;
  peer.socket.send(`${text}\r\n`);
  lastSentAt = Date.now();
  return offset;
}

async function command(peer, text, matcher = "> ", timeout = 20000) {
  const offset = await send(peer, text);
  return waitForAfter(peer, offset, matcher, timeout);
}

async function login(id) {
  const peer = await connect(id);
  await waitForAfter(peer, 0, "您的使用者代號");
  await command(peer, id, "請輸入密碼");
  await command(peer, password, /目前權限:|客棧大堂/);
  await waitForAfter(peer, 0, "> ");
  return peer;
}

const a = await login("sociala");
const b = await login("socialb");

const bSayOffset = b.output.length;
const aSay = await command(a, "say 中文社交測試");
assert.match(aSay, /你說道.*中文社交測試/s);
const bSay = await waitForAfter(b, bSayOffset, /說道.*中文社交測試/s);
assert.match(bSay, /中文社交測試/);
console.log("SOCIAL_PASS:say-room-utf8");

const bTellOffset = b.output.length;
const aTell = await command(a, "tell socialb 私訊中文測試");
assert.match(aTell, /你告訴.*私訊中文測試/s);
const bTell = await waitForAfter(b, bTellOffset, /告訴你.*私訊中文測試/s);
assert.match(bTell, /sociala/i);
console.log("SOCIAL_PASS:tell-private-routing");

await new Promise(resolve => setTimeout(resolve, 3100));
const aReplyOffset = a.output.length;
const bReply = await command(b, "reply 回覆中文測試");
assert.match(bReply, /你回答.*回覆中文測試/s);
const aReply = await waitForAfter(a, aReplyOffset, /回答你.*回覆中文測試/s);
assert.match(aReply, /socialb/i);
console.log("SOCIAL_PASS:reply-routing");

await new Promise(resolve => setTimeout(resolve, 3100));
const missing = await command(a, "tell nobody_es2 不存在玩家");
assert.match(missing, /沒有這個人/);
console.log("SOCIAL_PASS:missing-player-original-error");

const quitOffset = await send(b, "quit");
await waitForAfter(b, quitOffset, "歡迎下次再來");
b.socket.close();
await new Promise(resolve => setTimeout(resolve, 200));

await new Promise(resolve => setTimeout(resolve, 3100));
const offline = await command(a, "tell socialb 離線測試");
assert.match(offline, /沒有這個人|沒辦法聽到你的訊息/);
const b2 = await login("socialb");
await new Promise(resolve => setTimeout(resolve, 3100));
const b2Offset = b2.output.length;
await command(a, "tell socialb 重登後私訊");
assert.match(await waitForAfter(b2, b2Offset, /告訴你.*重登後私訊/s), /重登後私訊/);
console.log("SOCIAL_PASS:disconnect-relogin");

a.socket.close();
b2.socket.close();
console.log("ORIGINAL_SOCIAL_COMMUNICATION_RUNTIME_PASS");
