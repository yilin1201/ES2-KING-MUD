#!/usr/bin/env node
// 武功招式模擬器離線驗收：檢查正式規格、JavaScript 語法及純文字輸出順序。
import assert from "node:assert/strict";
import fs from "node:fs";
import vm from "node:vm";

const html = fs.readFileSync("docs/tools/martial_arts_simulator.html", "utf8");
assert.match(html, /<h1>武功招式模擬器<\/h1>/);
assert.doesNotMatch(html, /V9|名稱加寬・精簡選單・即時戰鬥預覽/);
assert.doesNotMatch(html, /<script\s+[^>]*src=|<link\s+[^>]*href=/i, "必須為無外部資源的獨立 HTML");
assert.match(html, /grid-template-columns:minmax\(0,50%\) minmax\(74px,22%\) minmax\(86px,28%\)/);
for (const text of ["無連續特攻", "有連續特攻", "單式預覽", "複製戰鬥文字", "忠", "劍領風騷"])
  assert.ok(html.includes(text), `缺少正式欄位：${text}`);

const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)];
assert.equal(scripts.length, 1, "應只有一段內嵌 JavaScript");
const context = vm.createContext({ console });
new vm.Script(scripts[0][1], { filename: "martial_arts_simulator.inline.js" }).runInContext(context);
const core = context.MartialSimulatorCore;
assert.ok(core, "純函式核心未匯出供離線驗證");

const state = {
  martialName: "測試劍法", martialColor: "黃", martialFrame: "angle", opponent: "木人",
  moveCount: 2, selectedMove: 1, previewMode: "all", comboEnabled: true,
  combo: { name: "連環", color: "紅", frame: "square", prelude: "前奏，", preludeColor: "白", action: "攻向", actionColor: "紅" },
  moves: [
    { name: "忠", color: "綠", frame: "square", prelude: "一式，", preludeColor: "白", action: "刺向", actionColor: "綠" },
    { name: "武", color: "紅", frame: "none", prelude: "二式，", preludeColor: "白", action: "斬向", actionColor: "紅" }
  ]
};
let sections = core.buildSections(state);
assert.equal(sections.length, 3, "連續特攻應先顯示一次，再顯示兩式");
let plain = core.toPlainText(sections);
assert.ok(plain.startsWith("你施展「測試劍法」中的連續特攻【連環】！\n前奏，攻向木人！"));
assert.ok(plain.indexOf("連續特攻") < plain.indexOf("【忠】"));
assert.ok(plain.indexOf("【忠】") < plain.indexOf("招式武"));
assert.doesNotMatch(plain, /ANSI|-kee max/);

state.previewMode = "single";
sections = core.buildSections(state);
plain = core.toPlainText(sections);
assert.equal(sections.length, 1, "單式預覽不得加入連續特攻文字");
assert.match(plain, /中的招式武！/);
assert.doesNotMatch(plain, /連續特攻|【忠】/);

assert.equal(core.framed("名稱", "angle"), "「名稱」");
assert.equal(core.framed("名稱", "square"), "【名稱】");
assert.equal(core.framed("名稱", "none"), "名稱");
console.log("MARTIAL_ARTS_SIMULATOR_STATIC_PASS");
