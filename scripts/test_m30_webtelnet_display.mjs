import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { TelnetTextFilter } from "../webtelnet/telnet.mjs";

const filter = new TelnetTextFilter();
const decoder = new TextDecoder("utf-8");
const banner = "東 方 故 事 Ⅱ\n天     朝     帝     國\nＣelestial  Ｅmpire\n您的使用者代號: ";
const utf8 = Buffer.from(banner, "utf8");

// 模擬 TCP 與 UTF-8 同時分段，並插入 Neolith Telnet negotiation／GA 控制序列。
const chunks = [
  Buffer.concat([Buffer.from([255]), Buffer.from([251, 1]), utf8.subarray(0, 5)]),
  Buffer.concat([utf8.subarray(5, 23), Buffer.from([255, 249, 255, 255]), utf8.subarray(23, 41)]),
  Buffer.concat([Buffer.from([255, 250, 24, 1, 255]), Buffer.from([240]), utf8.subarray(41)])
];

let rendered = "";
for (const chunk of chunks) rendered += decoder.decode(filter.push(chunk), { stream: true });
rendered += decoder.decode();
assert.equal(rendered, banner);
assert.equal(rendered.includes("�"), false);

const html = await readFile(new URL("../webtelnet/public/index.html", import.meta.url), "utf8");
const server = await readFile(new URL("../webtelnet/server.mjs", import.meta.url), "utf8");
assert.match(server, /new TelnetTextFilter\(\)/);
assert.match(server, /telnetText\.push\(data\)/);
assert.match(server, /"content-type": "text\/html; charset=utf-8",\s*"cache-control": "no-store"/);
assert.match(html, /<meta charset="utf-8">/);
assert.match(html, /white-space:\s*pre;/);
assert.match(html, /overflow-x:\s*auto;/);
assert.match(html, /overflow-wrap:\s*normal;/);
assert.match(html, /word-break:\s*normal;/);
assert.match(html, /-webkit-text-size-adjust:\s*100%;/);
assert.doesNotMatch(html, /overflow-wrap:\s*anywhere/);

// Public Login（公開登入）必須在瀏覽器本身遮蔽密碼，且不得儲存或記錄輸入內容。
assert.match(html, /const passwordPrompt = \/\(/);
assert.match(html, /command\.type = secret \? "password" : "text";/);
assert.match(html, /"new-password"/);
assert.match(html, /"current-password"/);
assert.match(html, /outputTail = \(outputTail \+ cleanText\)\.slice\(-256\);/);
assert.doesNotMatch(html, /outputTail\s*\+=\s*command\.value/);
assert.doesNotMatch(html, /console\.(?:log|debug)\(command\.value/);

// Original Race Menu（種族選單）使用 get_char 單鍵操作；Web 表單必須轉譯顯示的完整種族名稱。
assert.match(html, /const racePrompt = \/選擇你的角色所屬的種族/);
assert.match(html, /choice === "human"/);
assert.match(html, /socket\.send\("\\r"\);/);
assert.match(html, /choice === "avatar"/);
assert.match(html, /socket\.send\("\\x1b\[B"\);/);
assert.match(html, /pendingRaceSelection && racePrompt\.test\(outputTail\)/);

console.log("M30 WEBTELNET DISPLAY PASS（測試通過）：UTF-8 中文、Telnet 控制碼過濾、密碼遮蔽、Original 種族單鍵轉譯與固定寬度排版完整。");
