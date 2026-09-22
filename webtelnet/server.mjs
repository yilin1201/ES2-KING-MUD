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
const characterTransportVersion = "race-numeric-lf-v5";

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
sockets.on("connection", (browser) => {
  // 每個瀏覽器連線各自建立一條 Telnet（文字終端連線協定）TCP 連線。
  // Public Session ID（公開工作階段編號）只用於除錯生命週期，不記錄玩家輸入、密碼或 Claim Token。
  const sessionId = ++publicSessionSequence;
  console.log(`[public-session ${sessionId}] websocket-open`);
  const mud = connect({ host: mudHost, port: mudPort });
  const telnetText = new TelnetTextFilter();
  let runtimeTail = "";
  mud.setTimeout(10000, () => mud.destroy(new Error("MUD connection timeout")));
  mud.once("connect", () => mud.setTimeout(0));
  mud.on("data", (data) => {
    // Neolith 使用 UTF-8，但 Telnet IAC 控制位元組不是文字；先剝離協定再交給瀏覽器解碼。
    const text = telnetText.push(data);
    runtimeTail = (runtimeTail + text).slice(-1024);
    if (text.length > 0 && browser.readyState === browser.OPEN) browser.send(text);
  });
  mud.on("error", (error) => browser.close(1011, `MUD connection failed: ${error.message}`));
  mud.on("close", () => browser.close(1000, "MUD connection closed"));
  browser.on("message", (data) => {
    if (!mud.writable) return;
    // 只記錄位元組數，不記錄內容，讓 Public blocker 可判斷 Browser→Bridge 是否真的有送資料且不洩漏秘密。
    console.log(`[public-session ${sessionId}] browser-to-mud bytes=${data.length}`);
    // Character Transport／角色輸入傳輸：Race 使用明確的 WebSocket 訊息封套，
    // Bridge 在伺服器端依 Runtime 模式轉換；line-input 使用 Telnet 標準 CRLF 完成整行提交，避免 Neolith 只收到 LF 而持續等待。
    const incoming = Buffer.from(data).toString("utf8");
    if (["ES2RACE:1", "ES2RACE:2", "ES2RACE:human", "ES2RACE:avatar"].includes(incoming)) {
      const choice = incoming.slice("ES2RACE:".length);
      const race = choice === "1" ? "human" : choice === "2" ? "avatar" : choice;
      // Runtime Adaptive Race／Runtime 自適應種族輸入：
      // 新 Runtime 使用 input_to 文字行；尚未更新的 Original Runtime 仍使用 get_char 游標選單。
      // 依實際 Prompt 選擇傳輸，讓 Public 部署新舊不同步時仍可完成 Race。
      const lineRace = /請輸入編號 1 或 2/.test(runtimeTail)
        || /選擇你的角色所屬的種族\s*\(human\/avatar\)/.test(runtimeTail)
        || /請輸入 human 或 avatar/.test(runtimeTail);
      if (lineRace) {
        // Neolith input_to 以 LF 完成文字行；Public 實機顯示 CRLF 會留下額外空輸入並出現「>」。
        // Race 封套只在這個明確 prompt 使用單一 LF，不影響一般 Original Telnet 輸入。
        mud.write(Buffer.from((choice === "1" || choice === "2" ? choice : race) + "\n", "utf8"));
      } else if (race === "human") {
        // Original cursor 預設停在 human；CR 確認目前選項。
        mud.write(Buffer.from("\r", "utf8"));
      } else {
        // Original avatar 為第二項；ANSI Down 移到下一項後再確認。
        mud.write(Buffer.from("\x1b[B", "binary"));
        setTimeout(() => { if (mud.writable) mud.write(Buffer.from("\r", "utf8")); }, 80);
      }
      return;
    }
    // 其他 Original get_char／一般文字輸入維持原始位元組。
    mud.write(Buffer.from(data));
  });
  browser.on("close", () => { console.log(`[public-session ${sessionId}] websocket-close`); mud.destroy(); });
  browser.on("error", () => mud.destroy());
});

http.listen(webPort, "0.0.0.0", () => {
  console.log(`ES2-KING WebTelnet: http://0.0.0.0:${webPort} -> ${mudHost}:${mudPort}`);
});
