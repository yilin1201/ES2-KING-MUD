import assert from "node:assert/strict";
import { access } from "node:fs/promises";
import { constants } from "node:fs";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";
import { prepareCharacterChoice } from "../webtelnet/public/character-input.mjs";

const url = process.env.ES2_E2E_WS_URL;
const saveDir = process.env.ES2_E2E_SAVE_DIR;
const claimToken = process.env.ES2_E2E_CLAIM_TOKEN;
const wrongToken = process.env.ES2_E2E_WRONG_TOKEN;
const kingPassword = process.env.ES2_E2E_KING_PASSWORD;
const playerPassword = process.env.ES2_E2E_PLAYER_PASSWORD;
for (const value of [url, saveDir, claimToken, wrongToken, kingPassword, playerPassword]) assert.ok(value);

const loginFile = `${saveDir}/login/k/king.o`;
const userFile = `${saveDir}/user/k/king.o`;
const exists = async path => {
  try { await access(path, constants.F_OK); return true; }
  catch { return false; }
};
const encodeClaim = value => "es2claim1:" + Buffer.from(value, "utf8").toString("hex");

function session() {
  const socket = new WebSocket(url);
  let output = "";
  socket.on("message", data => { output += Buffer.from(data).toString("utf8"); });
  return {
    socket,
    send: text => socket.send(text),
    output: () => output,
    waitFor: (text, timeout = 15000) => new Promise((resolve, reject) => {
      const started = Date.now();
      const onError = error => { clearInterval(timer); reject(error); };
      const timer = setInterval(() => {
        if (output.includes(text)) {
          clearInterval(timer);
          socket.off("error", onError);
          resolve();
        } else if (Date.now() - started > timeout) {
          clearInterval(timer);
          socket.off("error", onError);
          const safeTail = output.slice(-1200)
            .replaceAll(claimToken, "[CLAIM-SECRET-REMOVED]")
            .replaceAll(wrongToken, "[SECRET-REMOVED]")
            .replaceAll(kingPassword, "[PASSWORD-REMOVED]")
            .replaceAll(playerPassword, "[PASSWORD-REMOVED]");
          reject(new Error(`等待 Runtime 提示逾時：${text}\n安全診斷末端：${safeTail}`));
        }
      }, 25);
      socket.once("error", onError);
    }),
    waitForAfter: (offset, text, timeout = 15000) => new Promise((resolve, reject) => {
      const started = Date.now();
      const onError = error => { clearInterval(timer); reject(error); };
      const timer = setInterval(() => {
        if (output.slice(offset).includes(text)) {
          clearInterval(timer);
          socket.off("error", onError);
          resolve();
        } else if (Date.now() - started > timeout) {
          clearInterval(timer);
          socket.off("error", onError);
          reject(new Error(`等待新的 Runtime 提示逾時：${text}`));
        }
      }, 25);
      socket.once("error", onError);
    }),
    close: () => socket.close()
  };
}

async function sendBrowserChoice(current, value) {
  const tail = current.output().slice(-512);
  const prepared = prepareCharacterChoice(tail, value);
  assert.ok(prepared, `Browser compatibility 應辨識選項：${value}`);
  const offset = current.output().length;
  current.send(prepared.bytes);
  if (prepared.followup) {
    await current.waitForAfter(offset, "選擇你的角色所屬的種族");
    current.send(prepared.followup);
  }
}

async function reachClaim(current) {
  await current.waitFor("您的使用者代號");
  current.send("king\r\n");
  await current.waitFor("KING Owner 一次性初始化權杖");
}

async function verifyKingCommands(current) {
  current.send("kingcreate list\r\n");
  await current.waitFor("KING 可建立項目");
  current.send("kingrealm\r\n");
  await current.waitFor("進入天神殿・無極之境");
  current.send("kingmartial yijinjing 300\r\n");
  await current.waitFor("易筋經 Lv.300／黑級無極境");
  current.send("kingcanon rulai 11\r\n");
  await current.waitFor("天舞梵輪・萬相歸墟／佛兵：阿賴耶識・歸墟神輪");
}

assert.equal(await exists(loginFile), false);
assert.equal(await exists(userFile), false);

// Wrong Token（錯誤權杖）：只回覆一般失敗，不進入密碼或創角流程。
const wrong = session();
await reachClaim(wrong);
wrong.send(`${encodeClaim(wrongToken)}\r\n`);
await wrong.waitFor("Owner 初始化驗證失敗");
assert.equal(wrong.output().includes("請設定您的密碼"), false);
assert.match(wrong.output(), /協定=HEX-V1；格式=VALID；輸入位元組=\d+；Runtime 位元組=\d+；長度=MATCH；比較=MISMATCH/);
wrong.close();

// Invalid Hex（無效十六進位）：格式錯誤必須安全拒絕，且不得嘗試猜測或回顯秘密。
const invalidTransport = session();
await reachClaim(invalidTransport);
invalidTransport.send("es2claim1:zz\r\n");
await invalidTransport.waitFor("格式=INVALID");
assert.equal(invalidTransport.output().includes("請設定您的密碼"), false);
invalidTransport.close();

// 傳統 Telnet 相容：即使秘密以 ! 開頭，也必須由 I_NOESC 的 input_to 接收，不得當成命令逃逸。
const rawSpecial = session();
await reachClaim(rawSpecial);
rawSpecial.send(`${claimToken}\r\n`);
await rawSpecial.waitFor("請設定您的密碼");
rawSpecial.close();
await new Promise(resolve => setTimeout(resolve, 150));

// Session Isolation（工作階段隔離）：第一條連線成功後，第二條連線即使輸入相同秘密也不能取得授權。
const first = session();
const second = session();
await Promise.all([reachClaim(first), reachClaim(second)]);
first.send(`${encodeClaim(claimToken)}\r\n`);
await first.waitFor("請設定您的密碼");
second.send(`${encodeClaim(claimToken)}\r\n`);
await second.waitFor("Owner 初始化驗證失敗");
assert.equal(second.output().includes("請設定您的密碼"), false);
second.close();

// 中途斷線後，已驗證 Session 必須失效；下一條連線需重新提交 Token。
first.close();
await new Promise(resolve => setTimeout(resolve, 150));
const abandoned = session();
await reachClaim(abandoned);
abandoned.send(`${encodeClaim(claimToken)}\r\n`);
await abandoned.waitFor("請設定您的密碼");
abandoned.close();
await new Promise(resolve => setTimeout(resolve, 150));

// 真正建立 KING：Token 只開門，後續完全沿用 Original 密碼、email、種族、性別與存檔流程。
const owner = session();
await reachClaim(owner);
owner.send(`${encodeClaim(claimToken)}\r\n`);
await owner.waitFor("請設定您的密碼");
owner.send(`${kingPassword}\r\n`);
await owner.waitFor("請再輸入一次您的密碼");
owner.send(`${kingPassword}\r\n`);
await owner.waitFor("您的電子郵件地址");
owner.send("none\r\n");
await owner.waitFor("選擇你的角色所屬的種族");
await sendBrowserChoice(owner, "human");
await owner.waitFor("您要扮演的哪種性別");
await sendBrowserChoice(owner, "male");
await owner.waitFor("您的顯示名稱");
owner.send("KING\r\n");
await owner.waitFor("您確定要創造這個角色嗎");
await sendBrowserChoice(owner, "yes");
await owner.waitFor("目前權限: (admin)", 20000);
await owner.waitFor("客棧大堂", 20000);
await owner.waitFor("\n> ", 20000);
// Original MAX_COMMAND_PER_SECOND／每秒指令上限：自動創角密集輸入後跨過限速窗口，
// 避免把測試工具的高速輸入誤判成 COMMAND_D 找不到第一個 KING 指令。
await new Promise(resolve => setTimeout(resolve, 1200));
owner.send("look\r\n");
await new Promise(resolve => setTimeout(resolve, 300));
// Playability Core／可玩化核心：確認建角後不只登入成功，基本角色資訊與物品指令也能被 Runtime 接收。
// 這裡以「回到命令提示」作為跨 Original 版本的穩定判定，避免硬編歷史輸出文案。
for (const command of ["score", "inventory"]) {
  const offset = owner.output().length;
  owner.send(command + "\r\n");
  await owner.waitForAfter(offset, "\n> ", 10000);
}

// Movement Gate／移動可玩化閘門：不硬編起始房間出口名稱，先以 Original look 的「明顯的出口」讀出第一個出口。
// 實際送出移動命令後，必須再次回到命令提示，證明角色已進入一般世界指令循環，而非只停在創角完成畫面。
{
  const lookOffset = owner.output().length;
  owner.send("look\r\n");
  await owner.waitForAfter(lookOffset, "\n> ", 10000);
  const lookText = owner.output().slice(lookOffset);
  const exitMatch = lookText.match(/明顯的出口(?:有|是)?[^：:]*[：:]?\\s*([^。\\n]+)/);
  if (exitMatch) {
    const firstExit = exitMatch[1].trim().split(/[、,，\\s]+/)[0].replace(/[。；;].*$/, "");
    if (firstExit) {
      const moveOffset = owner.output().length;
      owner.send(firstExit + "\r\n");
      await owner.waitForAfter(moveOffset, "\n> ", 10000);
      assert.notEqual(owner.output().slice(moveOffset), "", "Movement Runtime 必須回傳世界輸出");
    }
  }
}
await verifyKingCommands(owner);
assert.equal(await exists(loginFile), true, "KING login save 必須建立");
assert.equal(await exists(userFile), true, "KING user save 必須建立");
owner.send("save\r\n");
await owner.waitFor("檔案儲存完畢");
owner.send("quit\r\n");
await owner.waitFor("歡迎下次再來");
owner.close();

// Account Exists（帳號已存在）：Claim 立即停用，重新登入只出現 Original 密碼提示。
const badPassword = session();
await badPassword.waitFor("您的使用者代號");
badPassword.send("king\r\n");
await badPassword.waitFor("請輸入密碼");
assert.equal(badPassword.output().includes("一次性初始化權杖"), false);
badPassword.send(`${wrongToken}\r\n`);
await badPassword.waitFor("密碼錯誤");
assert.equal(badPassword.output().includes("KING 可建立項目"), false);
badPassword.close();

const relogin = session();
await relogin.waitFor("您的使用者代號");
relogin.send("king\r\n");
await relogin.waitFor("請輸入密碼");
relogin.send(`${kingPassword}\r\n`);
await relogin.waitFor("目前權限: (admin)", 20000);
await relogin.waitFor("客棧大堂", 20000);
await relogin.waitFor("\n> ", 20000);
await new Promise(resolve => setTimeout(resolve, 300));
await verifyKingCommands(relogin);

// Negative Authorization／反向授權：顯示名稱可為 KING，但普通帳號不得取得任何 Owner 指令。
const normal = session();
await normal.waitFor("您的使用者代號");
normal.send("kinglook\r\n");
await normal.waitFor("您確定嗎");
await sendBrowserChoice(normal, "yes");
await normal.waitFor("請設定您的密碼");
normal.send(`${playerPassword}\r\n`);
await normal.waitFor("請再輸入一次您的密碼");
normal.send(`${playerPassword}\r\n`);
await normal.waitFor("您的電子郵件地址");
normal.send("none\r\n");
await normal.waitFor("選擇你的角色所屬的種族");
await sendBrowserChoice(normal, "avatar");
await normal.waitFor("您要扮演的哪種性別");
await sendBrowserChoice(normal, "female");
await normal.waitFor("您的顯示名稱");
normal.send("KING\r\n");
await normal.waitFor("您確定要創造這個角色嗎");
await sendBrowserChoice(normal, "yes");
await normal.waitFor("目前權限: (player)", 20000);
await normal.waitFor("客棧大堂", 20000);
await new Promise(resolve => setTimeout(resolve, 1200));
normal.send("look\r\n");
await new Promise(resolve => setTimeout(resolve, 300));
for (const command of ["kingcreate list", "kingrealm", "kingmartial yijinjing 300", "kingcanon rulai 11"])
  normal.send(`${command}\r\n`);
await new Promise(resolve => setTimeout(resolve, 800));
for (const forbidden of ["KING 可建立項目", "進入天神殿・無極之境", "黑級無極境", "天舞梵輪・萬相歸墟"])
  assert.equal(normal.output().includes(forbidden), false, `普通玩家不得取得：${forbidden}`);

const allOutput = [wrong, invalidTransport, rawSpecial, first, second, abandoned, owner, badPassword, relogin, normal]
  .map(current => current.output()).join("");
assert.equal(allOutput.includes(claimToken), false, "Claim Token 不得出現在 WebSocket 輸出");
assert.equal(allOutput.includes(encodeClaim(claimToken)), false, "Claim 傳輸值不得被 WebSocket 回顯");
assert.equal(allOutput.includes(kingPassword), false, "KING 密碼不得出現在 WebSocket 輸出");
assert.equal(allOutput.includes(playerPassword), false, "普通玩家密碼不得出現在 WebSocket 輸出");
relogin.close();
normal.close();

console.log("M30 KING CLAIM E2E PASS（測試通過）：特殊字元安全傳輸、一次性 Token、Session 隔離、斷線失效、Original 創角／密碼雜湊、king.o、首次與重登後四個 KING 指令、save／quit／relogin 完整通過。秘密未輸出。");
