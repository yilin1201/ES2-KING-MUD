import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";
const url=process.env.ES2_E2E_WS_URL,password=process.env.ES2_E2E_KING_PASSWORD;
assert.ok(url&&password);
let socket,output="",lastSentAt=0;
async function connect(){socket=new WebSocket(url);socket.on("message",d=>output+=Buffer.from(d).toString("utf8"));await new Promise((r,j)=>{socket.once("open",r);socket.once("error",j)})}
const wait=(o,m,t=30000)=>new Promise((r,j)=>{const s=Date.now(),x=setInterval(()=>{const q=output.slice(o),ok=typeof m==="string"?q.includes(m):m.test(q);if(ok){clearInterval(x);r(q)}else if(Date.now()-s>t){clearInterval(x);j(new Error("timeout "+m+"\n"+q.slice(-3000)))}},50)});
async function cmd(v,m="> ",t=30000){const d=Math.max(0,450-(Date.now()-lastSentAt));if(d)await new Promise(r=>setTimeout(r,d));const o=output.length;socket.send(v+"\r\n");lastSentAt=Date.now();return wait(o,m,t)}
await connect();await wait(0,"您的使用者代號");await cmd("king","請輸入密碼");await cmd(password,"目前權限: (admin)");await wait(0,"> ");
await cmd("goto /d/king/wuji_realm","天神殿・無極之境");
const arena=await cmd("enter","競技場：演武界");assert.match(arena,/梅寒霜|Mei hanshuang/i);
console.log("COLD_PLUM_PASS:arena-npc");
const look=await cmd("look mei");assert.match(look,/天涯折梅/);assert.match(look,/傲雪凌霜/);
console.log("COLD_PLUM_PASS:identity");
const start=output.length;socket.send("kill mei\r\n");lastSentAt=Date.now();
await wait(start,"【明鏡止水】",30000);console.log("COLD_PLUM_PASS:mirror-state");
for(const form of ["梅二方劍","梅四方劍","梅八方劍","愛霜恨雪","寒霜三千里","傲梅暗劍訣"]){await wait(start,form,90000);console.log("COLD_PLUM_PASS:form:"+form)}
assert.match(output.slice(start),/焦黑枯梅枝/);console.log("COLD_PLUM_PASS:weapon-combat");
socket.close();console.log("COLD_PLUM_MIRROR_RUNTIME_PASS");
