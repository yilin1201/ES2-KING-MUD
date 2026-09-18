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
  if (request.url === "/health") {
    const neolith = await neolithReachable();
    response.writeHead(neolith ? 200 : 503, {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store"
    });
    response.end(JSON.stringify({ web: true, bridge: true, neolith }));
    return;
  }
  if (request.url !== "/" && request.url !== "/index.html") {
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
sockets.on("connection", (browser) => {
  // 每個瀏覽器連線各自建立一條 Telnet（文字終端連線協定）TCP 連線。
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
  browser.on("message", (data) => mud.writable && mud.write(data));
  browser.on("close", () => mud.destroy());
  browser.on("error", () => mud.destroy());
});

http.listen(webPort, "0.0.0.0", () => {
  console.log(`ES2-KING WebTelnet: http://0.0.0.0:${webPort} -> ${mudHost}:${mudPort}`);
});
