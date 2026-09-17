import http from "node:http";
import { WebSocket } from "../webtelnet/node_modules/ws/wrapper.mjs";

const base = new URL(process.argv[2] || `http://127.0.0.1:${process.env.PORT || 8080}`);

function getHealth() {
  return new Promise((resolve, reject) => {
    const request = http.get(new URL("/health", base), { timeout: 5000 }, response => {
      let body = "";
      response.setEncoding("utf8");
      response.on("data", chunk => { body += chunk; });
      response.on("end", () => {
        try {
          const status = JSON.parse(body);
          if (response.statusCode !== 200 || !status.web || !status.bridge || !status.neolith) {
            reject(new Error(`health not ready: ${response.statusCode} ${body}`));
            return;
          }
          resolve(status);
        } catch (error) { reject(error); }
      });
    });
    request.on("timeout", () => request.destroy(new Error("health timeout")));
    request.on("error", reject);
  });
}

function checkLoginPrompt() {
  return new Promise((resolve, reject) => {
    const protocol = base.protocol === "https:" ? "wss:" : "ws:";
    const socket = new WebSocket(`${protocol}//${base.host}/mud`);
    const timer = setTimeout(() => { socket.terminate(); reject(new Error("ES2 login prompt timeout")); }, 10000);
    let output = "";
    socket.on("message", data => {
      output += Buffer.from(data).toString("utf8");
      if (output.includes("您的使用者代號")) {
        clearTimeout(timer);
        socket.close();
        resolve();
      }
    });
    socket.on("error", error => { clearTimeout(timer); reject(error); });
  });
}

await getHealth();
await checkLoginPrompt();
console.log("M30 DEPLOYMENT SMOKE PASS：HTTP → WebSocket → Bridge → Telnet :4000 → ES2 Login Prompt");
