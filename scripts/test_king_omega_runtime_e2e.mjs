import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";
const url=process.env.ES2_E2E_WS_URL,password=process.env.ES2_E2E_KING_PASSWORD;assert.ok(url&&password);
let socket,output="",lastSentAt=0;const sleep=ms=>new Promise(r=>setTimeout(r,ms));
async function connect(){output="";socket=new WebSocket(url);socket.on("message",d=>{output+=Buffer.from(d).toString("utf8")});await new Promise((r,j)=>{socket.once("open",r);socket.once("error",j)})}
function wait(offset,matcher,timeout=30000){return new Promise((r,j)=>{const s=Date.now(),t=setInterval(()=>{const x=output.slice(offset),ok=typeof matcher==="string"?x.includes(matcher):matcher.test(x);if(ok){clearInterval(t);r(x)}else if(Date.now()-s>timeout){clearInterval(t);j(new Error("KING OMEGA timeout: "+matcher+"\n"+x.slice(-2400))) }},25)})}
async function command(line,matcher="> ",timeout=30000){const d=Math.max(0,450-(Date.now()-lastSentAt));if(d)await sleep(d);const o=output.length;socket.send(line+"\r\n");lastSentAt=Date.now();return wait(o,matcher,timeout)}
async function login(){await connect();await wait(0,"您的使用者代號");await command("king","請輸入密碼");await command(password,"目前權限: (admin)");await wait(0,"> ")}
await login();
let inv=await command("inventory");assert.match(inv,/神之戒/);assert.equal(inv.split("神之戒").length-1,1);
console.log("KING_OMEGA_STAGE_PASS:god-ring-provisioned");
const release=await command("release omega",/成功裝備了「超級Ω神聖衣」全套防具/);
for(const n of ["頭盔","盔甲","披風光翼","腰帶","手套","腳套","鞋子"])assert.match(release,new RegExp("超級Ω神聖衣。"+n));
console.log("KING_OMEGA_STAGE_PASS:release-omega-seven-piece");
inv=await command("inventory");
for(const n of ["超級Ω神聖衣。頭盔","超級Ω神聖衣。盔甲","超級Ω神聖衣。披風光翼","超級Ω神聖衣。腰帶","超級Ω神聖衣。手套","超級Ω神聖衣。腳套","超級Ω神聖衣。鞋子"])assert.equal(inv.split(n).length-1,1,n+" 必須剛好一件");
console.log("KING_OMEGA_STAGE_PASS:inventory-no-duplicate");
await command("release omega",/成功裝備了「超級Ω神聖衣」全套防具/);
inv=await command("inventory");
for(const n of ["超級Ω神聖衣。頭盔","超級Ω神聖衣。盔甲","超級Ω神聖衣。披風光翼","超級Ω神聖衣。腰帶","超級Ω神聖衣。手套","超級Ω神聖衣。腳套","超級Ω神聖衣。鞋子"])assert.equal(inv.split(n).length-1,1,"再次 release 不得重複 "+n);
console.log("KING_OMEGA_STAGE_PASS:repeat-release-no-duplicate");
socket.close();console.log("KING_OMEGA_RUNTIME_E2E_PASS");
