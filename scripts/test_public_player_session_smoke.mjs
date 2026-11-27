import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const base = new URL(process.argv[2] || "https://es2-king-mud.onrender.com");
const protocol = base.protocol === "https:" ? "wss:" : "ws:";
const url = `${protocol}//${base.host}/mud`;
// 不送 Y、不設定密碼，因此不建立正式帳號、不寫入 Neon。
const probeId = process.env.ES2_PUBLIC_PLAYER_PROBE_ID || "alphaprobe";

const socket = new WebSocket(url);
let output = "";
socket.on("message", data => { output += Buffer.from(data).toString("utf8"); });

function waitFor(matcher, timeout = 30000) {
  return new Promise((resolve, reject) => {
    const started = Date.now();
    const timer = setInterval(() => {
      if (typeof matcher === "string" ? output.includes(matcher) : matcher.test(output)) {
        clearInterval(timer); resolve();
      } else if (Date.now() - started > timeout) {
        clearInterval(timer);
        reject(new Error(`Public Player Session timeout: ${String(matcher)}\n${output.slice(-1800)}`));
      }
    }, 25);
  });
}
await new Promise((resolve, reject) => {
  socket.once("open", resolve);
  socket.once("error", reject);
});
await waitFor("您的使用者代號");
socket.send(`${probeId}\r\n`);
await waitFor(/使用 .* 這個代號將會創造一個新的人物/);
assert.doesNotMatch(output, /目前權限:\s*\((?:owner|creator|admin|wizard)\)/i);
socket.send("N");
await new Promise(resolve => setTimeout(resolve, 250));
socket.close();
const isPublic = base.protocol === "https:" && !["127.0.0.1", "localhost"].includes(base.hostname);
console.log(isPublic
  ? "PUBLIC_PLAYER_SESSION_PASS:external-wss-new-player-confirmation:no-account-created"
  : "PLAYER_SESSION_SMOKE_PASS:localhost-websocket-new-player-confirmation:no-account-created");
