import { createReadStream } from "node:fs";
import { createServer } from "node:http";
import { connect } from "node:net";
import { randomBytes } from "node:crypto";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { WebSocketServer } from "ws";
import { TelnetTextFilter, initialTelnetResponse } from "./telnet.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const webPort = Number(process.env.PORT || process.env.WEBTELNET_PORT || 8080);
const mudHost = process.env.ES2_HOST || "127.0.0.1";
const mudPort = Number(process.env.ES2_PORT || 4001);
// Build Identity（建置版本識別）：Render 提供的公開 Commit SHA 只用於核對部署版本，
// 不讀取或輸出其他環境變數，避免洩漏 Secret（秘密資料）。
const buildCommit = process.env.RENDER_GIT_COMMIT || process.env.ES2_BUILD_COMMIT || "unknown";
const buildVersion = process.env.ES2_BUILD_VERSION || "m30-public-runtime";
const characterTransportVersion = "race-telnet-crlf-v9";

// HTTP（網頁傳輸協定）只提供固定入口頁，避免把檔案系統暴露給瀏覽器。
function neolithReachable() {
  return new Promise(resolve => {
    const socket = connect({ host: mudHost, port: mudPort });
    socket.setTimeout(1000);
    socket.once("connect", () => { socket.destroy(); resolve(true); });
    socket.once("error", () => resolve(false));
    socket.once("timeout", () => { socket.destroy(); resolve(false); });
  });
}

const http = createServer(async (request, response) => {
  // URL Path（網址路徑）只比較標準化 pathname，讓 /health、/health/ 與查詢參數都能正常檢查。
  const pathname = new URL(request.url || "/", "http://127.0.0.1").pathname.replace(/\/$/, "") || "/";
  if (pathname === "/health") {
    const neolith = await neolithReachable();
    response.writeHead(neolith ? 200 : 503, {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store"
    });
    response.end(JSON.stringify({ web: true, bridge: true, neolith, build_commit: buildCommit, build_version: buildVersion, character_transport: characterTransportVersion }));
    return;
  }
  if (pathname === "/claim-input.mjs" || pathname === "/character-input.mjs") {
    response.writeHead(200, {
      "content-type": "text/javascript; charset=utf-8",
      "cache-control": "no-store"
    });
    createReadStream(join(here, "public", pathname.slice(1))).pipe(response);
    return;
  }
  if (pathname !== "/" && pathname !== "/index.html") {
    response.writeHead(404).end("Not found");
    return;
  }
  // 手機驗收必須取得目前部署版本，避免舊 HTML 快取掩蓋編碼或排版修正。
  response.writeHead(200, {
    "content-type": "text/html; charset=utf-8",
    "cache-control": "no-store"
  });
  createReadStream(join(here, "public", "index.html")).pipe(response);
});

const sockets = new WebSocketServer({ server: http, path: "/mud" });
let publicSessionSequence = 0;

// Mobile Session Resume／手機背景續接：Safari 回收 WebSocket 時保留原 Telnet 連線五分鐘。
// Token 由 Bridge 在 Original Login 成功後才以 CSPRNG（密碼學安全亂數）產生；它不是密碼或權限，
// 只經加密 WebSocket 控制訊息傳送，絕不放在 URL、一般 log 或玩家存檔。Container restart 後記憶體表自然失效。
const resumeControlPrefix = "\x1eES2RESUME:";
const resumeTokenPattern = /^[A-Za-z0-9_-]{43}$/;
const configuredGraceMs = Number(process.env.ES2_WEB_RESUME_GRACE_MS || 300000);
const resumeGraceMs = Number.isFinite(configuredGraceMs) && configuredGraceMs >= 100
  ? configuredGraceMs
  : 300000;
const resumeHandshakeMs = 250;
const resumableSessions = new Map();

function sendResumeControl(browser, message) {
  if (browser && browser.readyState === browser.OPEN) browser.send(resumeControlPrefix + JSON.stringify(message));
}

function parseResumeControl(data, isBinary) {
  if (isBinary) return null;
  const text = Buffer.from(data).toString("utf8");
  if (!text.startsWith(resumeControlPrefix)) return null;
  try {
    const message = JSON.parse(text.slice(resumeControlPrefix.length));
    return message?.type === "resume" && typeof message.token === "string" ? message : null;
  } catch {
    return null;
  }
}

function createResumeToken() {
  let token;
  do token = randomBytes(32).toString("base64url");
  while (resumableSessions.has(token));
  return token;
}

function createMudSession(browser, firstMessage = null) {
  // Public Session ID（公開工作階段編號）只用於除錯生命週期，不記錄玩家輸入、密碼或 Resume Token。
  const sessionId = ++publicSessionSequence;
  console.log(`[public-session ${sessionId}] websocket-open`);
  const mud = connect({ host: mudHost, port: mudPort });
  const telnetText = new TelnetTextFilter();
  let runtimeTail = "";
  let numericRaceActive = false;
  let inventoryProbePending = null;
  let activeBrowser = null;
  let expiryTimer = null;
  let resumeToken = null;
  let explicitQuit = false;

  const invalidateResume = () => {
    clearTimeout(expiryTimer);
    expiryTimer = null;
    if (resumeToken && resumableSessions.get(resumeToken) === session) resumableSessions.delete(resumeToken);
    resumeToken = null;
  };

  const armExpiry = () => {
    clearTimeout(expiryTimer);
    expiryTimer = setTimeout(() => {
      console.log(`[public-session ${sessionId}] resume-expired`);
      invalidateResume();
      mud.destroy();
    }, resumeGraceMs);
  };

  const detachBrowser = closedBrowser => {
    if (activeBrowser !== closedBrowser) return;
    console.log(`[public-session ${sessionId}] websocket-detach`);
    activeBrowser = null;
    session.browser = null;
    if (explicitQuit || !resumeToken) {
      mud.destroy();
      return;
    }
    armExpiry();
  };

  const forwardBrowserMessage = data => {
    if (!mud.writable) return;
    const incoming = Buffer.from(data).toString("utf8");
    // 控制訊息只屬 Bridge，任何情況都不得落入 Original Login／遊戲命令。
    if (incoming.startsWith(resumeControlPrefix)) return;
    // 只記錄位元組數，不記錄內容，避免帳號、密碼或 Token 進入 log。
    console.log(`[public-session ${sessionId}] browser-to-mud bytes=${data.length}`);
    const inventoryProbe = incoming.trim().toLowerCase();
    if (inventoryProbe === "quit") {
      explicitQuit = true;
      invalidateResume();
    }
    if (inventoryProbe === "i" || inventoryProbe === "inventory" || inventoryProbe === "look king") {
      inventoryProbePending = {kind: inventoryProbe === "look king" ? "look-self" : inventoryProbe, started: Date.now()};
      console.log(`[public-session ${sessionId}] inventory-probe=${inventoryProbe === "look king" ? "look-self" : inventoryProbe} bridge-forwarded=true`);
    }
    if (/^ES2RACE:(?:[1-9]|1[0-2]|human|avatar|blackteeth|yenhold|jiaojao|woochan|dingling|headless|rainner|malik|yaksa|ashura)$/.test(incoming)) {
      const choice = incoming.slice("ES2RACE:".length);
      const raceIds = ["", "human", "avatar", "blackteeth", "yenhold", "jiaojao", "woochan", "dingling", "headless", "rainner", "malik", "yaksa", "ashura"];
      const race = /^\d+$/.test(choice) ? raceIds[Number(choice)] : choice;
      const lineRace = numericRaceActive
        || /請輸入編號 1-12 或種族 ID|請輸入編號 1 或 2/.test(runtimeTail)
        || /選擇你的角色所屬的種族\s*\(human\/avatar\)/.test(runtimeTail)
        || /請輸入 human 或 avatar/.test(runtimeTail);
      if (lineRace) {
        mud.write(Buffer.from((/^\d+$/.test(choice) ? choice : race) + "\r\n", "utf8"));
      } else if (race === "human") {
        mud.write(Buffer.from("\r", "utf8"));
      } else {
        mud.write(Buffer.from("\x1b[B", "binary"));
        setTimeout(() => { if (mud.writable) mud.write(Buffer.from("\r", "utf8")); }, 80);
      }
      return;
    }
    // Original get_char／Login／一般命令維持原始位元組；Resume 不解析或保存密碼。
    mud.write(Buffer.from(data));
  };

  const attach = (newBrowser, resumed = false) => {
    const oldBrowser = activeBrowser;
    activeBrowser = newBrowser;
    session.browser = newBrowser;
    clearTimeout(expiryTimer);
    expiryTimer = null;
    newBrowser.on("message", forwardBrowserMessage);
    newBrowser.on("close", () => detachBrowser(newBrowser));
    newBrowser.on("error", () => detachBrowser(newBrowser));
    if (oldBrowser && oldBrowser !== newBrowser && oldBrowser.readyState === oldBrowser.OPEN) {
      try { oldBrowser.close(4001, "Session resumed in another browser connection"); } catch {}
    }
    if (resumed) {
      console.log(`[public-session ${sessionId}] websocket-resume`);
      sendResumeControl(newBrowser, {type: "resume-ok", grace_ms: resumeGraceMs});
      newBrowser.send("\n[ES2-KING] 連線已恢復。\n");
    }
  };

  const session = {sessionId, mud, browser, attach};
  attach(browser);
  mud.setTimeout(10000, () => {
    console.error(`[public-session ${sessionId}] mud-timeout host=${mudHost} port=${mudPort}`);
    mud.destroy(new Error("MUD connection timeout"));
  });
  mud.once("connect", () => {
    mud.setTimeout(0);
    console.log(`[public-session ${sessionId}] mud-connected host=${mudHost} port=${mudPort}`);
    // Telnet negotiation／先回覆 Neolith 的 TTYPE、NAWS、LINEMODE 要求；
    // 此文字橋接不支援這三項終端功能，明確回 WONT，不把控制位元組送到瀏覽器。
    mud.write(initialTelnetResponse());
    if (firstMessage) forwardBrowserMessage(firstMessage);
  });
  mud.on("data", data => {
    console.log(`[public-session ${sessionId}] mud-to-browser bytes=${data.length}`);
    const text = telnetText.push(data);
    if (inventoryProbePending) {
      const elapsed = Date.now() - inventoryProbePending.started;
      console.log(`[public-session ${sessionId}] inventory-response probe=${inventoryProbePending.kind} bytes=${data.length} filteredChars=${text.length} elapsedMs=${elapsed}`);
      inventoryProbePending = null;
    }
    runtimeTail = (runtimeTail + text).slice(-1024);
    if (/請輸入編號 1-12 或種族 ID|請輸入編號 1 或 2/.test(text)) numericRaceActive = true;
    if (/您要扮演的哪種性別/.test(text)) numericRaceActive = false;
    // Original Login 成功後才發 Token；權限仍完全由既有 interactive actor／帳號／admin 判定。
    if (!resumeToken && /目前權限:\s*\((?:player|wizard|arch|admin)\)/.test(runtimeTail)) {
      resumeToken = createResumeToken();
      resumableSessions.set(resumeToken, session);
      sendResumeControl(activeBrowser, {type: "resume-token", token: resumeToken, grace_ms: resumeGraceMs});
      console.log(`[public-session ${sessionId}] resume-enabled`);
    }
    if (text.length > 0 && activeBrowser && activeBrowser.readyState === activeBrowser.OPEN) activeBrowser.send(text);
  });
  mud.on("error", error => {
    console.error(`[public-session ${sessionId}] mud-error code=${error.code || "unknown"} message=${error.message}`);
    if (activeBrowser && activeBrowser.readyState === activeBrowser.OPEN) activeBrowser.close(1011, `MUD connection failed: ${error.message}`);
  });
  mud.on("close", hadError => {
    console.log(`[public-session ${sessionId}] mud-close hadError=${hadError}`);
    invalidateResume();
    if (activeBrowser && activeBrowser.readyState === activeBrowser.OPEN) activeBrowser.close(1000, "MUD connection closed");
  });
}

sockets.on("connection", browser => {
  let settled = false;
  const beginNewSession = firstMessage => {
    if (settled) return;
    settled = true;
    clearTimeout(handshakeTimer);
    browser.off("message", firstBrowserMessage);
    createMudSession(browser, firstMessage);
  };
  const firstBrowserMessage = (data, isBinary) => {
    const request = parseResumeControl(data, isBinary);
    if (!request) {
      beginNewSession(data);
      return;
    }
    settled = true;
    clearTimeout(handshakeTimer);
    browser.off("message", firstBrowserMessage);
    const existing = resumeTokenPattern.test(request.token) ? resumableSessions.get(request.token) : null;
    if (existing && !existing.mud.destroyed && existing.mud.writable) {
      existing.attach(browser, true);
      return;
    }
    sendResumeControl(browser, {type: "resume-failed"});
    createMudSession(browser);
  };
  const handshakeTimer = setTimeout(() => beginNewSession(null), resumeHandshakeMs);
  browser.on("message", firstBrowserMessage);
  browser.once("close", () => { if (!settled) clearTimeout(handshakeTimer); });
  browser.once("error", () => { if (!settled) clearTimeout(handshakeTimer); });
});

http.listen(webPort, "0.0.0.0", () => {
  console.log(`ES2-KING WebTelnet: http://0.0.0.0:${webPort} -> ${mudHost}:${mudPort}`);
});
