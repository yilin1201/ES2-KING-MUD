import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

// K Admin Runtime Journey／雙帳號真 Driver 驗證；所有帳號只存在一次性 Runtime。
const url = process.env.ES2_E2E_WS_URL;
const password = process.env.ES2_E2E_PASSWORD;
assert.ok(url && password);

class Client {
  constructor(id) { this.id = id; this.output = ""; this.socket = null; this.lastSentAt = 0; }
  async connect() {
    this.output = "";
    this.socket = new WebSocket(url);
    this.socket.on("message", data => { this.output += Buffer.from(data).toString("utf8"); });
    await new Promise((resolve, reject) => {
      this.socket.once("open", resolve);
      this.socket.once("error", reject);
    });
  }
  wait(offset, matcher, timeout = 20000) {
    return new Promise((resolve, reject) => {
      const started = Date.now();
      const timer = setInterval(() => {
        const tail = this.output.slice(offset);
        const matched = typeof matcher === "string" ? tail.includes(matcher) : matcher.test(tail);
        if (matched) { clearInterval(timer); resolve(tail); }
        else if (Date.now() - started > timeout) {
          clearInterval(timer);
          reject(new Error(`${this.id} 等待逾時：${String(matcher)}\n${tail.slice(-2200)}`));
        }
      }, 25);
    });
  }
  async command(line, matcher = "> ", timeout = 20000) {
    const delay = Math.max(0, 400 - (Date.now() - this.lastSentAt));
    if (delay) await new Promise(resolve => setTimeout(resolve, delay));
    const offset = this.output.length;
    this.socket.send(`${line}\r\n`);
    this.lastSentAt = Date.now();
    return this.wait(offset, matcher, timeout);
  }
  async login() {
    await this.connect();
    await this.wait(0, "您的使用者代號");
    await this.command(this.id, "請輸入密碼");
    await this.command(password, "> ");
  }
  async quit() {
    const offset = this.output.length;
    this.socket.send("quit\r\n");
    await this.wait(offset, "歡迎下次再來");
    this.socket.close();
    await new Promise(resolve => setTimeout(resolve, 150));
  }
}

function has(text, matcher) { assert.match(text, matcher); }
function lacks(text, matcher) { assert.doesNotMatch(text, matcher); }

const king = new Client("king");
const probe = new Client("kprobe");
await king.login();

// KING help index／help k 與 help wiz 使用同一份依權限過濾的表。
for (const topic of ["k", "wiz"]) {
  const text = await king.command(`help ${topic}`);
  has(text, /KING 專屬/); has(text, /kadmin/); has(text, /kroom/); has(text, /kgoto/);
}
console.log("K_HELP_PASS:king-index");

// 每個正式 k* command 都必須經 Original help command 呼叫自身 help()。
for (const command of [
  "khome", "kcreate", "kcanon", "kmartial", "kadmin", "kroom", "kexit", "kmap",
  "kact", "kwhere", "knpc", "kitem", "kgoto", "kobj", "ktrace", "kbroken", "kmiss",
]) has(await king.command(`help ${command}`), /指令格式/);
console.log("K_HELP_PASS:command-help");

// Owner command／只做非破壞性查詢；Canon 與武學不在本輪改寫。
has(await king.command("khome"), /天神殿・無極之境/);
has(await king.command("kcreate list"), /KING 可建立項目/);
has(await king.command("kcanon"), /格式：kcanon/);
has(await king.command("kmartial daxie status"), /哭笑門心法/);
has(await king.command("kadmin list"), /K 管理團隊/);
// Legacy compatibility／舊 king* 指令保持可用。
has(await king.command("kinghome"), /天神殿・無極之境/);
has(await king.command("kingcreate list"), /KING 可建立項目/);
has(await king.command("kingcanon"), /格式：kingcanon|指令格式/);
has(await king.command("kingmartial daxie status"), /哭笑門心法/);
console.log("K_ADMIN_PASS:king-owner-and-legacy");

// 初始 Player help 不公開管理細節，且 k 維持 Original kill alias。
await probe.login();
for (const topic of ["k", "wiz"]) {
  const text = await probe.command(`help ${topic}`);
  has(text, /一般玩家：k = kill/); lacks(text, /kadmin|kgoto|kroom\s+查看/);
}
has(await probe.command("k"), /你想殺誰/);
has(await probe.command("kroom"), /沒有 K 地圖巡查權限/);
console.log("K_PERMISSION_PASS:player-deny-and-kill-alias");
await probe.quit();

// KING 離線授予 Wizard；不得改 Original wiz_status。
has(await king.command("kadmin kprobe wizard"), /kprobe -> wizard/);
has(await king.command("kadmin kprobe status"), /kprobe：wizard/);
await probe.login();
for (const topic of ["k", "wiz"]) {
  const text = await probe.command(`help ${topic}`);
  has(text, /kroom/); lacks(text, /KING 專屬|kgoto/);
}
has(await probe.command("kroom"), /Room:|Raw exits:/);
has(await probe.command("kexit"), /VISIBLE \/ RAW EXIT|MISSING|沒有 RAW EXIT/);
has(await probe.command("kmap"), /KMAP/);
has(await probe.command("kact"), /STATIC SOURCE ANALYSIS REQUIRED/);
has(await probe.command("kwhere"), /kprobe ->/);
await probe.command("knpc"); await probe.command("kitem");
has(await probe.command("kgoto /d/snow/square"), /只有 KING／大巫師/);
has(await probe.command("kadmin list"), /What\?|沒有這個指令|無法使用|沒有 K|權限|command/i);
console.log("K_PERMISSION_PASS:wizard-readonly");
await probe.quit();

// Arch 取得進階唯讀／導航工具，但仍無 KING Owner 指令。
has(await king.command("kadmin kprobe arch"), /kprobe -> arch/);
await probe.login();
for (const topic of ["k", "wiz"]) {
  const text = await probe.command(`help ${topic}`);
  has(text, /kroom/); has(text, /kgoto/); lacks(text, /KING 專屬|kadmin\s+巫師/);
}
has(await probe.command("kgoto /d/snow/square"), /KGOTO -> \/d\/snow\/square/);
has(await probe.command("kroom"), /climb 榕樹 -> \/d\/snow\/tree\s+\[SOURCE CONFIRMED\]/);
has(await probe.command("kact"), /Command : climb 榕樹[\s\S]*Target\s+: \/d\/snow\/tree[\s\S]*Status\s+: SOURCE CONFIRMED/);
has(await probe.command("kobj kprobe"), /id="kprobe"|id='kprobe'/);
has(await probe.command("ktrace /d/snow/square_e"), /DIRECT: east -> \/d\/snow\/square_e/);
await probe.command("kbroken"); await probe.command("kmiss");
has(await probe.command("kcanon"), /What\?|沒有這個指令|無法使用|權限|command/i);
console.log("K_PERMISSION_PASS:arch-tools-owner-deny");
await probe.quit();

// Remove 後重新登入必須回到 Player；save／quit／relogin 不得產生角色權限污染。
has(await king.command("kadmin kprobe remove"), /kprobe -> remove/);
await probe.login();
has(await probe.command("kroom"), /沒有 K 地圖巡查權限/);
has(await probe.command("k"), /你想殺誰/);
has(await probe.command("save"), /檔案儲存完畢/);
await probe.quit();
await probe.login();
has(await probe.command("kroom"), /沒有 K 地圖巡查權限/);
has(await probe.command("help k"), /一般玩家：k = kill/);
console.log("K_PERMISSION_PASS:remove-save-quit-relogin");

probe.socket.close();
king.socket.close();
console.log("K_ADMIN_RUNTIME_PASS");
console.log("K_HELP_RUNTIME_PASS");
console.log("K_PERMISSION_REGRESSION_PASS");
