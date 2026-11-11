import assert from "node:assert/strict";
import { access } from "node:fs/promises";
import { constants } from "node:fs";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const url = process.env.ES2_E2E_WS_URL || "ws://127.0.0.1:18080/mud";
const saveDir = process.env.ES2_E2E_SAVE_DIR;
assert.ok(saveDir, "ES2_E2E_SAVE_DIR（端到端測試存檔目錄）不可省略");

const exists = async path => {
  try { await access(path, constants.F_OK); return true; }
  catch { return false; }
};

const loginFile = `${saveDir}/login/k/king.o`;
const userFile = `${saveDir}/user/k/king.o`;
assert.equal(await exists(loginFile), false, "測試開始前不得存在 KING login save");
assert.equal(await exists(userFile), false, "測試開始前不得存在 KING user save");

const socket = new WebSocket(url);
let received = "";
let submitted = false;

await new Promise((resolve, reject) => {
  const timer = setTimeout(() => reject(new Error(`端到端測試逾時，已收到：${received}`)), 15000);
  socket.on("error", reject);
  socket.on("message", data => {
    received += Buffer.from(data).toString("utf8");
    if (!submitted && received.includes("您的使用者代號")) {
      submitted = true;
      socket.send("king\r\n");
      return;
    }
    if (submitted
        && received.includes("KING Owner 帳號尚未在此 Runtime 初始化，已拒絕公開註冊。")
        && received.split("您的使用者代號").length >= 3) {
      clearTimeout(timer);
      resolve();
    }
  });
});

assert.equal(socket.readyState, WebSocket.OPEN, "拒絕後 WebSocket 應保持可用並返回安全登入流程");
assert.equal(received.includes("將會創造一個新的人物"), false, "KING 不得進入 Character Creation");
assert.equal(await exists(loginFile), false, "拒絕後不得建立 login/k/king.o");
assert.equal(await exists(userFile), false, "拒絕後不得建立 user/k/king.o");
socket.close();

console.log("M30 KING RESERVATION E2E PASS（測試通過）：Neolith → Telnet → Bridge → WebSocket 收到中文拒絕訊息並安全返回登入，且未建立 king.o。");
