import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";
const url=process.env.ES2_E2E_WS_URL,password=process.env.ES2_E2E_KING_PASSWORD;assert.ok(url&&password);
let socket,output="",lastSentAt=0;
const plain=s=>s.replace(/\\x1b\\[[0-9;]*m/g,"");const sleep=ms=>new Promise(r=>setTimeout(r,ms));
async function connect(){output="";socket=new WebSocket(url);socket.on("message",d=>{output+=Buffer.from(d).toString("utf8")});await new Promise((r,j)=>{socket.once("open",r);socket.once("error",j)})}
function wait(offset,matcher,timeout=30000){return new Promise((r,j)=>{const s=Date.now(),t=setInterval(()=>{const x=output.slice(offset),ok=typeof matcher==="string"?x.includes(matcher):matcher.test(x);if(ok){clearInterval(t);r(x)}else if(Date.now()-s>timeout){clearInterval(t);j(new Error("KING OMEGA timeout: "+matcher+"\n"+x.slice(-2400))) }},25)})}
async function command(line,matcher="> ",timeout=30000){const d=Math.max(0,450-(Date.now()-lastSentAt));if(d)await sleep(d);const o=output.length;socket.send(line+"\r\n");lastSentAt=Date.now();return wait(o,matcher,timeout)}
async function login(){await connect();await wait(0,"您的使用者代號");await command("king","請輸入密碼");await command(password,"目前權限: (admin)");await wait(0,"> ")}
await login();
let inv=plain(await command("inventory"));assert.match(inv,/神之戒/);assert.equal(inv.split("神之戒").length-1,1);
console.log("KING_OMEGA_STAGE_PASS:god-ring-provisioned");
const release=plain(await command("release omega",/成功裝備了「超級Ω神聖衣」全套防具/));
// Narrative Regression／精簡版著裝敘述需完整呈現七部位及神之戒啟動。
for(const line of [
  "體內億萬細胞轟然共振",
  "八十八星座齊聲共鳴",
  "神聖Ω——終極覺醒",
  "神聖Ω神盔破空扣合",
  "神聖Ω神甲萬光交織",
  "神聖Ω光翼轟然怒展",
  "神聖Ω金鎖瞬間封合",
  "神聖Ω拳套緊扣雙腕",
  "神聖Ω腿甲轟然覆合",
  "神聖Ω戰靴神焰踏落",
]) assert.ok(release.includes(line), "缺少正式著裝敘述："+line);
console.log("KING_OMEGA_STAGE_PASS:release-omega-seven-piece");
inv=plain(await command("inventory"));
for(const n of ["超級Ω神聖衣。頭盔","超級Ω神聖衣。盔甲","超級Ω神聖衣。披風光翼","超級Ω神聖衣。腰帶","超級Ω神聖衣。手套","超級Ω神聖衣。腳套","超級Ω神聖衣。鞋子"])assert.equal(inv.split(n).length-1,1,n+" 必須剛好一件");
console.log("KING_OMEGA_STAGE_PASS:inventory-no-duplicate");
await command("release omega",/成功裝備了「超級Ω神聖衣」全套防具/);
inv=plain(await command("inventory"));
for(const n of ["超級Ω神聖衣。頭盔","超級Ω神聖衣。盔甲","超級Ω神聖衣。披風光翼","超級Ω神聖衣。腰帶","超級Ω神聖衣。手套","超級Ω神聖衣。腳套","超級Ω神聖衣。鞋子"])assert.equal(inv.split(n).length-1,1,"再次 release 不得重複 "+n);
console.log("KING_OMEGA_STAGE_PASS:repeat-release-no-duplicate");
const sealed=plain(await command("recall omega",/七件神聖衣已全部收回/));
assert.match(sealed,/神衣雖歸，神威永存/);
inv=plain(await command("inventory"));
for(const n of ["超級Ω神聖衣。頭盔","超級Ω神聖衣。盔甲","超級Ω神聖衣。披風光翼","超級Ω神聖衣。腰帶","超級Ω神聖衣。手套","超級Ω神聖衣。腳套","超級Ω神聖衣。鞋子"])assert.equal(inv.includes(n),false,"seal 後 Inventory 不得殘留 "+n);
assert.equal(/神之庇護|絕對霸體|光速境界/.test(inv),false,"seal 後不得殘留 Ω 裝備狀態文字");
console.log("KING_OMEGA_STAGE_PASS:seal-back-to-god-ring");
const rerelease=plain(await command("release omega",/成功裝備了「超級Ω神聖衣」全套防具/));
// 裝備狀態由 kring.c 的 omega_equipped() 實際驗證，不再依賴已移除的舊版文字。
assert.match(rerelease,/神聖Ω神盔破空扣合/);
assert.match(rerelease,/神聖Ω戰靴神焰踏落/);
console.log("KING_OMEGA_STAGE_PASS:release-after-seal-states-restored");

// Persistence Gate／神聖衣不是一次性文字演出：存檔離線後七件仍須存在且不得增殖。
// 重新登入後再執行 release omega，必須重用既有七件並恢復完整著裝。
await command("save");
await command("quit",/再見|Goodbye|離開|斷線|quit/i,15000).catch(()=>{});
try{socket.close()}catch{}
await sleep(900);
await login();
inv=plain(await command("inventory"));
for(const n of ["超級Ω神聖衣。頭盔","超級Ω神聖衣。盔甲","超級Ω神聖衣。披風光翼","超級Ω神聖衣。腰帶","超級Ω神聖衣。手套","超級Ω神聖衣。腳套","超級Ω神聖衣。鞋子"])assert.equal(inv.split(n).length-1,1,"relogin 後必須保留且剛好一件 "+n);
console.log("KING_OMEGA_STAGE_PASS:save-quit-relogin-persisted");
await command("release omega",/成功裝備了「超級Ω神聖衣」全套防具/);
inv=plain(await command("inventory"));
for(const n of ["超級Ω神聖衣。頭盔","超級Ω神聖衣。盔甲","超級Ω神聖衣。披風光翼","超級Ω神聖衣。腰帶","超級Ω神聖衣。手套","超級Ω神聖衣。腳套","超級Ω神聖衣。鞋子"])assert.equal(inv.split(n).length-1,1,"relogin 後再次 release 不得重複 "+n);
console.log("KING_OMEGA_STAGE_PASS:relogin-release-no-duplicate");
socket.close();console.log("KING_OMEGA_RUNTIME_E2E_PASS");
