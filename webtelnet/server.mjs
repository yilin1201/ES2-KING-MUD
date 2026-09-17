import { createReadStream } from "node:fs";
import { createServer } from "node:http";
import { connect } from "node:net";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { WebSocketServer } from "ws";

const here = dirname(fileURLToPath(import.meta.url));
const webPort = Number(process.env.WEBTELNET_PORT || 8080);
const mudHost = process.env.ES2_HOST || "127.0.0.1";
const mudPort = Number(process.env.ES2_PORT || 4000);

// HTTP（網頁傳輸協定）只提供固定入口頁，避免把檔案系統暴露給瀏覽器。
const http = createServer((request, response) => {
  if (request.url !== "/" && request.url !== "/index.html") {
    response.writeHead(404).end("Not found");
    return;
  }
  response.writeHead(200, { "content-type": "text/html; charset=utf-8" });
  createReadStream(join(here, "public", "index.html")).pipe(response);
});

const sockets = new WebSocketServer({ server: http, path: "/mud" });
sockets.on("connection", (browser) => {
  // 每個瀏覽器連線各自建立一條 Telnet（文字終端連線協定）TCP 連線。
  const mud = connect({ host: mudHost, port: mudPort });
  mud.on("data", (data) => browser.readyState === browser.OPEN && browser.send(data));
  mud.on("error", (error) => browser.close(1011, `MUD connection failed: ${error.message}`));
  mud.on("close", () => browser.close(1000, "MUD connection closed"));
  browser.on("message", (data) => mud.writable && mud.write(data));
  browser.on("close", () => mud.destroy());
  browser.on("error", () => mud.destroy());
});

http.listen(webPort, "0.0.0.0", () => {
  console.log(`ES2-KING WebTelnet: http://0.0.0.0:${webPort} -> ${mudHost}:${mudPort}`);
});
