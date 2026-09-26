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
// Browser Module Syntax Gate／瀏覽器模組語法閘門：HTML 可正常載入不代表 <script type="module"> 可執行。
// 移除 import 宣告後交給 JavaScript parser；ANSI regex 若被雙重跳脫造成語法錯誤，Build 必須直接 FAIL。
const moduleStart = html.indexOf('<script type="module">');
const moduleEnd = html.indexOf('</script>', moduleStart);
const moduleMatch = moduleStart >= 0 && moduleEnd > moduleStart
  ? [html.slice(moduleStart, moduleEnd + 9), html.slice(moduleStart + '<script type="module">'.length, moduleEnd)]
  : null;
assert.ok(moduleMatch, "missing browser module");
const browserModuleWithoutImports = moduleMatch[1].replace(/^\\s*import\\s+.*?;\\s*$/gm, "");
assert.doesNotThrow(() => new Function(browserModuleWithoutImports), "browser module must parse");
assert.doesNotMatch(moduleMatch[1], /\\\\\\\\x1b\\\\\\\\\\\\\\[/);

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
assert.match(html, /function appendAnsiText\(raw\)/);
assert.match(html, /ansi-93/);
assert.match(html, /appendAnsiText\(decoded\)/);
assert.doesNotMatch(html, /terminal\.textContent \+= cleanText/);

// Public Login（公開登入）必須在瀏覽器本身遮蔽密碼，且不得儲存或記錄輸入內容。
assert.match(html, /const passwordPrompt = \/\(/);
assert.match(html, /command\.type = secret \? "password" : "text";/);
assert.match(html, /"new-password"/);
assert.match(html, /"current-password"/);
assert.match(html, /KING Owner 一次性初始化權杖/);
assert.match(html, /prepareOwnerClaim/);
assert.match(html, /MINIMUM_OWNER_CLAIM_BYTES/);
assert.match(html, /ownerClaimPrompt\.test\(outputTail\)/);
assert.match(html, /KING Claim 安全傳輸：HEX-V1 已送出；輸入長度=/);
assert.match(html, /至少需要 \$\{MINIMUM_OWNER_CLAIM_BYTES\} bytes，尚未送出/);
assert.match(html, /command\.addEventListener\("paste"/);
assert.match(html, /command\.addEventListener\("input"/);
assert.match(html, /command\.addEventListener\("compositionend"/);
assert.match(html, /claimPastePending \|\| claimCompositionActive/);
assert.match(html, /outputTail = \(outputTail \+ cleanText\)\.slice\(-256\);/);
assert.doesNotMatch(html, /outputTail\s*\+=\s*command\.value/);
assert.doesNotMatch(html, /console\.(?:log|debug)\(command\.value/);
assert.doesNotMatch(html, /prepareOwnerClaim\(command\.value\.trim\(\)\)/);

// Original get_char 單鍵選單由獨立相容模組處理，並提供 iPhone 可點選按鈕。
assert.match(html, /import \{ characterMenuFor, prepareCharacterChoice \}/);
assert.match(html, /id="character-choices"/);
assert.match(html, /button\.type = "button"/);
assert.match(html, /sendCharacterChoice\(option\.value\)/);
assert.match(html, /pendingCharacterFollowup/);
assert.doesNotMatch(html, /socket\.send\("\\r"\)/);

console.log("M30 WEBTELNET DISPLAY PASS（測試通過）：UTF-8 中文、Telnet 控制碼過濾、密碼遮蔽、Original 種族單鍵轉譯與固定寬度排版完整。");
