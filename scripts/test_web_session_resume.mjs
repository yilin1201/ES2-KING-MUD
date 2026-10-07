import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { randomBytes } from "node:crypto";
import { createServer } from "node:net";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const bridgePath = resolve(repo, "webtelnet/server.mjs");
const resumePrefix = "\x1eES2RESUME:";
const testPassword = randomBytes(18).toString("base64url");
const clients = new Set();
const mudSessions = new Map();
let mudSequence = 0;

const delay = ms => new Promise(resolvePromise => setTimeout(resolvePromise, ms));

async function freePort() {
  const server = createServer();
  await new Promise((resolvePromise, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", resolvePromise);
  });
  const {port} = server.address();
  await new Promise(resolvePromise => server.close(resolvePromise));
  return port;
}

const mudServer = createServer(socket => {
  const id = ++mudSequence;
  const state = {id, socket, account: null, stage: "account", closed: false};
  mudSessions.set(id, state);
  let pending = "";
  socket.setEncoding("utf8");
  socket.write("您的使用者代號：");
  // Bridge／Container restart 測試會刻意中斷 TCP；假 MUD 只需記錄關閉，不應把預期的 ECONNRESET 當成測試程式崩潰。
  socket.on("error", () => {});
  socket.on("data", chunk => {
    pending += chunk;
    while (/\r\n|\n|\r/.test(pending)) {
      const split = pending.search(/\r\n|\n|\r/);
      const separator = pending.slice(split).match(/^(?:\r\n|\n|\r)/)[0];
      const line = pending.slice(0, split);
      pending = pending.slice(split + separator.length);
      if (state.stage === "account") {
        state.account = line;
        state.stage = "password";
        socket.write("請輸入密碼：");
      } else if (state.stage === "password") {
        state.stage = "world";
        const role = state.account === "king" ? "admin" : "player";
        socket.write(`目前權限: (${role})\nSESSION=${id};ACCOUNT=${state.account}\n> `);
      } else if (line.trim().toLowerCase() === "quit") {
        socket.end("歡迎下次再來\n");
      } else {
        socket.write(`SESSION=${id};ACCOUNT=${state.account};CMD=${line}\n> `);
      }
    }
  });
  socket.on("close", () => { state.closed = true; });
});

await new Promise((resolvePromise, reject) => {
  mudServer.once("error", reject);
  mudServer.listen(0, "127.0.0.1", resolvePromise);
});
const mudPort = mudServer.address().port;
const webPort = await freePort();
let bridge;
let bridgeLog = "";

async function startBridge() {
  bridge = spawn(process.execPath, [bridgePath], {
    cwd: repo,
    env: {
      ...process.env,
      ES2_HOST: "127.0.0.1",
      ES2_PORT: String(mudPort),
      PORT: String(webPort),
      ES2_WEB_RESUME_GRACE_MS: "250"
    },
    stdio: ["ignore", "pipe", "pipe"]
  });
  bridge.stdout.on("data", data => { bridgeLog += data.toString("utf8"); });
  bridge.stderr.on("data", data => { bridgeLog += data.toString("utf8"); });
  const deadline = Date.now() + 5000;
  while (Date.now() < deadline) {
    try {
      const response = await fetch(`http://127.0.0.1:${webPort}/health`);
      if (response.ok) return;
    } catch {}
    await delay(30);
  }
  throw new Error(`Bridge 未啟動：${bridgeLog.slice(-1200)}`);
}

async function stopBridge() {
  if (!bridge || bridge.exitCode !== null) return;
  bridge.kill("SIGTERM");
  await Promise.race([
    new Promise(resolvePromise => bridge.once("exit", resolvePromise)),
    delay(2000).then(() => bridge.kill("SIGKILL"))
  ]);
}

function waitFor(client, predicate, label, timeout = 5000) {
  return new Promise((resolvePromise, reject) => {
    const started = Date.now();
    const timer = setInterval(() => {
      const found = predicate(client);
      if (found) {
        clearInterval(timer);
        resolvePromise(found);
      } else if (Date.now() - started > timeout) {
        clearInterval(timer);
        reject(new Error(`等待 ${label} 逾時；text=${client.text.slice(-500)} controls=${JSON.stringify(client.controls.map(x => x.type))}`));
      }
    }, 20);
  });
}

async function openClient(token = "") {
  const client = {ws: null, text: "", controls: [], closed: false};
  const ws = new WebSocket(`ws://127.0.0.1:${webPort}/mud`);
  client.ws = ws;
  clients.add(client);
  ws.on("message", (data, isBinary) => {
    const text = Buffer.from(data).toString("utf8");
    if (!isBinary && text.startsWith(resumePrefix)) {
      client.controls.push(JSON.parse(text.slice(resumePrefix.length)));
    } else {
      client.text += text;
    }
  });
  ws.on("close", () => { client.closed = true; });
  await new Promise((resolvePromise, reject) => {
    ws.once("open", resolvePromise);
    ws.once("error", reject);
  });
  ws.send(resumePrefix + JSON.stringify({type: "resume", token}));
  return client;
}

async function login(client, account) {
  await waitFor(client, c => /使用者代號/.test(c.text), "Original Login account prompt");
  client.ws.send(`${account}\r\n`);
  await waitFor(client, c => /請輸入密碼/.test(c.text), "Original Login password prompt");
  client.ws.send(`${testPassword}\r\n`);
  await waitFor(client, c => new RegExp(`ACCOUNT=${account}`).test(c.text), `${account} world entry`);
  const tokenMessage = await waitFor(client, c => c.controls.find(x => x.type === "resume-token"), "server-issued resume token");
  assert.match(tokenMessage.token, /^[A-Za-z0-9_-]{43}$/);
  const sessionId = Number(client.text.match(/SESSION=(\d+)/)[1]);
  return {token: tokenMessage.token, sessionId};
}

async function terminateClient(client) {
  if (client.ws.readyState === WebSocket.OPEN || client.ws.readyState === WebSocket.CONNECTING) client.ws.terminate();
  await waitFor(client, c => c.closed, "websocket close");
}

try {
  await startBridge();

  // 1. 新 WebSocket 仍走 Original Login；2-3. 背景斷線保留 TCP，正確 Token 接回同一 Session。
  const playerA = await openClient();
  const authA = await login(playerA, "playera");
  assert.equal(mudSessions.get(authA.sessionId).closed, false);
  await terminateClient(playerA);
  await delay(60);
  assert.equal(mudSessions.get(authA.sessionId).closed, false, "grace period 內不應關閉 Telnet");
  const resumedA = await openClient(authA.token);
  await waitFor(resumedA, c => c.controls.some(x => x.type === "resume-ok"), "valid resume");
  await waitFor(resumedA, c => /連線已恢復/.test(c.text), "resume confirmation");
  resumedA.ws.send("where\r\n");
  await waitFor(resumedA, c => c.text.includes(`SESSION=${authA.sessionId};ACCOUNT=playera;CMD=where`), "same Telnet session");
  console.log("WEB_SESSION_RESUME_VALID_PASS:same-telnet-session");

  // 4. 不存在的 Token 只回正常 Login，不能取得 A。
  const invalid = await openClient("A".repeat(43));
  await waitFor(invalid, c => c.controls.some(x => x.type === "resume-failed"), "invalid token rejection");
  await waitFor(invalid, c => /使用者代號/.test(c.text), "invalid token login fallback");
  assert.doesNotMatch(invalid.text, /ACCOUNT=playera/);
  console.log("WEB_SESSION_RESUME_INVALID_PASS:no-session-access");

  // 5. Grace timeout 後舊 TCP 與 Token 都失效。
  const expiring = await openClient();
  const expiredAuth = await login(expiring, "expiring");
  await terminateClient(expiring);
  await delay(450);
  assert.equal(mudSessions.get(expiredAuth.sessionId).closed, true);
  const expired = await openClient(expiredAuth.token);
  await waitFor(expired, c => c.controls.some(x => x.type === "resume-failed"), "expired token rejection");
  await waitFor(expired, c => /使用者代號/.test(c.text), "expired token normal login");
  console.log("WEB_SESSION_RESUME_EXPIRED_PASS:grace-close-and-login");

  // 6. Token A 只能接回 Player A；Player B 仍維持自己的 TCP。
  const playerB = await openClient();
  const authB = await login(playerB, "playerb");
  const takeoverA = await openClient(authA.token);
  await waitFor(takeoverA, c => c.controls.some(x => x.type === "resume-ok"), "single attach replacement");
  takeoverA.ws.send("identity\r\n");
  playerB.ws.send("identity\r\n");
  await waitFor(takeoverA, c => c.text.includes(`ACCOUNT=playera;CMD=identity`), "Token A player identity");
  await waitFor(playerB, c => c.text.includes(`SESSION=${authB.sessionId};ACCOUNT=playerb;CMD=identity`), "Player B remains attached");
  assert.doesNotMatch(takeoverA.text, /ACCOUNT=playerb/);
  console.log("WEB_SESSION_RESUME_ISOLATION_PASS:token-a-not-player-b");

  // 7. quit 在 MUD 回覆或 socket close 前已撤銷 Token。
  playerB.ws.send("quit\r\n");
  await waitFor(playerB, c => c.closed, "explicit quit close");
  const quitResume = await openClient(authB.token);
  await waitFor(quitResume, c => c.controls.some(x => x.type === "resume-failed"), "quit token invalidation");
  await waitFor(quitResume, c => /使用者代號/.test(c.text), "quit normal login");
  console.log("WEB_SESSION_RESUME_QUIT_PASS:token-invalidated");

  // 8-9. KING 只恢復同一 admin TCP；普通 Player Token 不可能切到 KING。
  const king = await openClient();
  const kingAuth = await login(king, "king");
  assert.match(king.text, /目前權限: \(admin\)/);
  await terminateClient(king);
  const kingResumed = await openClient(kingAuth.token);
  await waitFor(kingResumed, c => c.controls.some(x => x.type === "resume-ok"), "KING resume");
  kingResumed.ws.send("identity\r\n");
  await waitFor(kingResumed, c => c.text.includes(`SESSION=${kingAuth.sessionId};ACCOUNT=king;CMD=identity`), "same KING TCP");
  takeoverA.ws.send("identity2\r\n");
  await waitFor(takeoverA, c => c.text.includes("ACCOUNT=playera;CMD=identity2"), "ordinary player remains ordinary");
  assert.doesNotMatch(takeoverA.text, /ACCOUNT=king/);
  assert.doesNotMatch(kingResumed.text, /Claim|認領/);
  console.log("WEB_SESSION_RESUME_KING_BOUNDARY_PASS:no-claim-no-privilege-switch");

  // 10. 靜態秘密邊界：不保存密碼、不把 Token 放 URL／Cookie，也不恢復 Owner Claim。
  const {readFile} = await import("node:fs/promises");
  const index = await readFile(resolve(repo, "webtelnet/public/index.html"), "utf8");
  const server = await readFile(resolve(repo, "webtelnet/server.mjs"), "utf8");
  assert.doesNotMatch(index, /localStorage\.setItem\([^\n]*(?:password|passwd)/i);
  assert.doesNotMatch(index, /sessionStorage[^\n]*(?:password|passwd)/i);
  assert.doesNotMatch(index, /[?&]resume=/);
  assert.doesNotMatch(server, /searchParams\.get\(["']resume/);
  assert.doesNotMatch(index + server, /ES2_KING_CLAIM_TOKEN/);
  assert.match(index, /visibilitychange/);
  assert.match(index, /pageshow/);
  assert.doesNotMatch(index, /(?:pagehide|visibilitychange)[\s\S]{0,180}\.close\(/);
  console.log("WEB_SESSION_RESUME_SECRET_STATIC_PASS:no-password-no-url-token");

  // 11. Bridge／Container restart 清空記憶體表；舊 Token 回正常 Original Login。
  await terminateClient(kingResumed);
  await stopBridge();
  await startBridge();
  const afterRestart = await openClient(kingAuth.token);
  await waitFor(afterRestart, c => c.controls.some(x => x.type === "resume-failed"), "restart token rejection");
  await waitFor(afterRestart, c => /使用者代號/.test(c.text), "restart normal login");
  assert.doesNotMatch(afterRestart.text, /ACCOUNT=king/);
  console.log("WEB_SESSION_RESUME_RESTART_PASS:memory-token-invalidated");
  console.log("WEB_SESSION_RESUME_TARGETED_PASS");
} catch (error) {
  console.error(`WEB_SESSION_RESUME_TARGETED_FAIL\n${bridgeLog.slice(-3000)}`);
  throw error;
} finally {
  for (const client of clients) {
    try { client.ws.terminate(); } catch {}
  }
  await stopBridge();
  await new Promise(resolvePromise => mudServer.close(resolvePromise));
}
