import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const html = await readFile(new URL("../webtelnet/public/index.html", import.meta.url), "utf8");

// Terminal Output 與 Input Controls 必須位於同一個 80 欄容器，不能各自延伸到寬螢幕。
const shellStart = html.indexOf('<section id="terminal-shell"');
const terminalAt = html.indexOf('<pre id="terminal"');
const formAt = html.indexOf("<form>");
const shellEnd = html.indexOf("</section>", shellStart);
assert.ok(shellStart >= 0 && terminalAt > shellStart && formAt > terminalAt && shellEnd > formAt);

// Desktop 使用 80ch 標準欄寬與 margin-inline 自動置中；字級固定 15px。
assert.match(html, /@media\s*\(min-width:\s*601px\)\s*\{[\s\S]*?#terminal-shell\s*\{[^}]*width:\s*80ch;[^}]*margin-inline:\s*auto;[^}]*font-size:\s*15px;/);
assert.match(html, /#terminal-shell\s*\{\s*width:\s*100%;\s*max-width:\s*100%;\s*\}/);
assert.match(html, /#terminal\s*\{[\s\S]*?white-space:\s*pre;/);

// 反向檢查：不可置中文字內容，也不可用 transform 偽造容器置中。
assert.doesNotMatch(html, /text-align\s*:\s*center/);
assert.doesNotMatch(html, /transform\s*:\s*(?:scale|translate)/);

console.log("M30 DESKTOP CENTERING PASS（測試通過）：80 欄終端與輸入控制區同容器置中，Original 文字對齊未改動。");
