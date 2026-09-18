import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const html = await readFile(new URL("../webtelnet/public/index.html", import.meta.url), "utf8");

// Mobile／Desktop 必須由同一個 600px Media Query 隔離，Desktop 固定 15px 不受動態值影響。
assert.match(html, /#terminal\s*\{[\s\S]*?font:\s*15px\/1\.35/);
assert.match(html, /@media\s*\(max-width:\s*600px\)/);
assert.match(html, /font-size:\s*var\(--mobile-terminal-font-size,\s*14px\)/);
assert.match(html, /matchMedia\("\(max-width: 600px\)"\)/);

// 80 欄依瀏覽器實際字型寬度與目前可視寬度計算，不允許寫死比例或縮放整個頁面。
assert.match(html, /const terminalColumns = 80;/);
assert.match(html, /"0"\.repeat\(terminalColumns\)/);
assert.match(html, /terminal\.clientWidth \/ measuredWidth/);
assert.match(html, /--mobile-terminal-font-size/);
assert.doesNotMatch(html, /transform\s*:\s*scale\s*\(/);

// Original 固定排版、極端內容備援捲動、iPhone 安全區及可操作控制區不得回歸。
assert.match(html, /white-space:\s*pre;/);
assert.match(html, /overflow-x:\s*auto;/);
assert.match(html, /safe-area-inset-left/);
assert.match(html, /safe-area-inset-right/);
assert.match(html, /safe-area-inset-bottom/);
assert.match(html, /input\s*\{[^}]*font-size:\s*16px;/);
assert.match(html, /button\s*\{[^}]*font-size:\s*16px;/);
assert.doesNotMatch(html, /overflow-wrap:\s*anywhere/);
assert.doesNotMatch(html, /white-space:\s*pre-wrap/);

console.log("M30 MOBILE RESPONSIVE PASS（測試通過）：80 欄動態適配、手機／電腦隔離、安全區與控制區字級完整。");
