#!/usr/bin/env node
// 通用武功招式模擬器：獨立邊界測試；不修改 Work 正在開發的 HTML 或既有測試。
import assert from "node:assert/strict";
import fs from "node:fs";
import vm from "node:vm";

const html = fs.readFileSync("docs/tools/martial_arts_simulator.html", "utf8");
const inline = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)];
assert.equal(inline.length, 1, "獨立 HTML 應只有一段內嵌腳本");
const sandbox = vm.createContext({console});
new vm.Script(inline[0][1]).runInContext(sandbox);
const core = sandbox.MartialSimulatorCore;
assert.ok(core?.buildSections && core?.toPlainText, "必須公開可離線測試的純函式核心");
const moves = Array.from({length:12},(_,i)=>({
  name:`測試${i+1}`,color:"白",frame:"square",
  prelude:`前奏${i+1}，`,preludeColor:"白",
  action:`動作${i+1}攻向`,actionColor:"紅"
}));
const state = {
  martialName:"測試武功",martialColor:"黃",martialFrame:"angle",
  opponent:"測試對手",moveCount:12,selectedMove:11,previewMode:"all",comboEnabled:true,
  combo:{name:"連環測試",color:"黃",frame:"angle",prelude:"連續前奏，",preludeColor:"白",action:"連續動作攻向",actionColor:"紅"},
  moves
};
const all = core.buildSections(state);
assert.equal(all.length,13,"12 式加專屬前奏，應有 13 段");
let text = core.toPlainText(all);
assert.equal((text.match(/連續特攻/g)||[]).length,1,"連續特攻只可出現一次");
assert.equal((text.match(/中的招式/g)||[]).length,12,"應完整輸出 12 式");
assert.ok(text.indexOf("連續特攻")<text.indexOf("【測試1】"));
assert.ok(text.indexOf("【測試1】")<text.indexOf("【測試12】"));
assert.ok(text.includes("連續前奏，連續動作攻向測試對手！"));
assert.ok(text.includes("前奏12，動作12攻向測試對手！"));
assert.doesNotMatch(text, /-kee max|undefined|\[object Object\]/);
state.comboEnabled=false;
assert.equal(core.buildSections(state).length,12,"關閉連續特攻仍應顯示所有招式");
state.moveCount=1;
assert.equal(core.buildSections(state).length,1,"調低招式數量只顯示一式");
assert.equal(moves.length,12,"調低數量不得刪除已編輯招式");
state.moveCount=12;state.previewMode="single";state.selectedMove=11;state.comboEnabled=true;
const single=core.toPlainText(core.buildSections(state));
assert.ok(single.includes("【測試12】"),"單式模式必須顯示選中招式");
assert.doesNotMatch(single,/連續特攻|【測試1】/,"單式模式不得混入其他招式或連續特攻");
// 顏色與輸出格式：不以字串拼接 ANSI 或 HTML，保持可複製純文字。
for (const [name, hex] of core.COLORS) {
  assert.equal(core.colorHex(name), hex, `顏色對應錯誤：${name}`);
}
assert.ok(core.COLORS.some(([name])=>name==="青"),"德式預設青色必須出現在選色清單");
const adversarial = structuredClone(state);
adversarial.previewMode="single"; adversarial.selectedMove=0;
adversarial.opponent="<img src=x onerror=alert(1)>";
adversarial.moves[0].name="<script>test</script>";
const escapedSections=core.buildSections(adversarial);
const escapedPlain=core.toPlainText(escapedSections);
assert.ok(escapedPlain.includes("<script>test</script>"),"純文字核心不得無聲刪改玩家輸入");
assert.ok(escapedPlain.includes(adversarial.opponent),"對手名稱應保留於純文字");
assert.ok(escapedSections.every(section=>section.every(line=>line.every(part=>typeof part.text==="string" && /^#[0-9a-f]{6}$/i.test(part.color)))),"彩色輸出應只包含文字與有效 HEX 色碼");
assert.equal(core.buildSections({...state,moveCount:12,previewMode:"all",comboEnabled:false}).length,12);
assert.equal(core.framed("測試","none"),"測試");
assert.equal(core.framed("測試","square"),"【測試】");
assert.equal(core.framed("測試","angle"),"「測試」");
console.log("MARTIAL_ARTS_SIMULATOR_EDGE_CASES_PASS");
