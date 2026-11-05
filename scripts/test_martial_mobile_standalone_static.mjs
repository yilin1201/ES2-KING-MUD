#!/usr/bin/env node
// 手機網頁離線防退化檢查：不連外、不部署、不宣稱 Safari Runtime PASS。
import assert from "node:assert/strict";
import fs from "node:fs";
import vm from "node:vm";
const html = fs.readFileSync("docs/tools/martial_arts_simulator.html", "utf8");
assert.match(html, /<meta name="viewport"[^>]*width=device-width/);
assert.match(html, /viewport-fit=cover/);
assert.match(html, /@media\(max-width:620px\)/);
assert.match(html, /id="copy"/);
assert.match(html, /navigator\.clipboard/);
assert.match(html, /document\.execCommand\("copy"\)/);
assert.match(html, /window\.isSecureContext/);
assert.doesNotMatch(html, /<script[^>]+src=|<link[^>]+href=/i);
const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)];
assert.equal(scripts.length, 1, "必須只有一段內嵌 JS");
const context = vm.createContext({});
new vm.Script(scripts[0][1], { filename: "martial_arts_simulator.inline.js" }).runInContext(context);
assert.ok(context.MartialSimulatorCore, "無 DOM 模式必須能載入核心");
console.log("MARTIAL_MOBILE_STANDALONE_STATIC_PASS (Safari/browser runtime UNKNOWN)");
