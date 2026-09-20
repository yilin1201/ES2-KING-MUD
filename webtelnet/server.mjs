import { createReadStream } from "node:fs";
import { createServer } from "node:http";
import { connect } from "node:net";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { WebSocketServer } from "ws";
import { TelnetTextFilter } from "./telnet.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const webPort = Number(process.env.PORT || process.env.WEBTELNET_PORT || 8080);
const mudHost = process.env.ES2_HOST || "127.0.0.1";
const mudPort = Number(process.env.ES2_PORT || 4000);
// Build Identity（建置版本識別）：Render 提供的公開 Commit SHA 只用於核對部署版本，
// 不讀取或輸出其他環境變數，避免洩漏 Secret（秘密資料）。
const buildCommit = process.env.RENDER_GIT_COMMIT || process.env.ES2_BUILD_COMMIT || "unknown";
const buildVersion = process.env.ES2_BUILD_VERSION || "m30-public-runtime";

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
    response.end(JSON.stringify({ web: true, bridge: true, neolith, build_commit: buildCommit, build_version: buildVersion }));
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
sockets.on("connection", (browser) => {
  // 每個瀏覽器連線各自建立一條 Telnet（文字終端連線協定）TCP 連線。
  // Public Session ID（公開工作階段編號）只用於除錯生命週期，不記錄玩家輸入、密碼或 Claim Token。
  const sessionId = ++publicSessionSequence;
  console.log(`[public-session ${sessionId}] websocket-open`);
  const mud = connect({ host: mudHost, port: mudPort });
  const telnetText = new TelnetTextFilter();
  mud.setTimeout(10000, () => mud.destroy(new Error("MUD connection timeout")));
  mud.once("connect", () => mud.setTimeout(0));
  mud.on("data", (data) => {
    // Neolith 使用 UTF-8，但 Telnet IAC 控制位元組不是文字；先剝離協定再交給瀏覽器解碼。
    const text = telnetText.push(data);
    if (text.length > 0 && browser.readyState === browser.OPEN) browser.send(text);
  });
  mud.on("error", (error) => browser.close(1011, `MUD connection failed: ${error.message}`));
  mud.on("close", () => browser.close(1000, "MUD connection closed"));
  browser.on("message", (data) => {
    if (!mud.writable) return;
    // 只記錄位元組數，不記錄內容，讓 Public blocker 可判斷 Browser→Bridge 是否真的有送資料且不洩漏秘密。
    console.log(`[public-session ${sessionId}] browser-to-mud bytes=${data.length}`);
    mud.write(data);
  });
  browser.on("close", () => { console.log(`[public-session ${sessionId}] websocket-close`); mud.destroy(); });
  browser.on("error", () => mud.destroy());
});

http.listen(webPort, "0.0.0.0", () => {
  console.log(`ES2-KING WebTelnet: http://0.0.0.0:${webPort} -> ${mudHost}:${mudPort}`);
});
