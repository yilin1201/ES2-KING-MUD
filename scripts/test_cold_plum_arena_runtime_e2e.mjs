import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";
const url=process.env.ES2_E2E_WS_URL,password=process.env.ES2_E2E_KING_PASSWORD;assert.ok(url&&password);
let socket,output="",last=0;
async function connect(){output="";socket=new WebSocket(url);socket.on("message",d=>output+=Buffer.from(d).toString("utf8"));await new Promise((r,j)=>{socket.once("open",r);socket.once("error",j)})}
const wait=(o,m,t=20000)=>new Promise((r,j)=>{const s=Date.now(),x=setInterval(()=>{const z=output.slice(o),ok=typeof m==="string"?z.includes(m):m.test(z);if(ok){clearInterval(x);r(z)}else if(Date.now()-s>t){clearInterval(x);j(new Error("timeout "+String(m)+"\n"+z.slice(-3000))) }},25)});
async function send(s){const d=Math.max(0,400-(Date.now()-last));if(d)await new Promise(r=>setTimeout(r,d));const o=output.length;socket.send(s+"\r\n");last=Date.now();return o}
async function cmd(s,m="> ",t=20000){const o=await send(s);return wait(o,m,t)}
async function call(s){return cmd("call "+s)}
function n(s,name){const m=s.match(new RegExp("->"+name+"\\([^)]*\\) = (-?\\d+)"));assert.ok(m,s.slice(-800));return +m[1]}
await connect();await wait(0,"您的使用者代號");await cmd("king","請輸入密碼");await cmd(password,"目前權限: (admin)");await wait(0,"> ");
for(const p of ["/d/arena/skill/lunmay","/d/arena/obj/charred_plum_branch","/d/arena/npc/mei_hanshuang","/d/arena/yanwujie"])assert.match(await cmd("update "+p),/更新|載入|重新編譯|成功|Ok/i);
await cmd("goto /d/arena/yanwujie","競技場：演武界");assert.match(await cmd("look mei"),/梅寒霜/);
for(const sk of ["hainmay force","advance_lunmay","lunmay","mayin","seven"])
  assert.equal(n(await call('mei->query_skill("'+sk+'")'),"query_skill"),300,sk);
for(const a of ["str","cor","int","spi","cps","dex","con","wis"])assert.equal(n(await call('mei->query_attr("'+a+'")'),"query_attr"),50);
console.log("COLD_PLUM_PASS:npc-attributes-skills");
for(const s of ["gin","kee","sen","HP"])await call('set_stat_current("'+s+'",100000)');
const start=output.length;await send("kill mei");await wait(start,/【明鏡止水】/,30000);console.log("COLD_PLUM_PASS:mirror-mind-state");
const forms=["梅二方劍","梅四方劍","梅八方劍","愛霜恨雪","寒霜三千里","傲梅暗劍訣"];
await wait(start,new RegExp(forms.join(".*"),"s"),60000);for(const f of forms)assert.ok(output.slice(start).includes(f),f);console.log("COLD_PLUM_PASS:six-forms-runtime");
await call('mei->set_stat_current("kee",1)');await call('mei->set_stat_current("HP",1)');
await wait(start,/死了|倒在地上|死亡|屍體|corpse|殺死/,45000);console.log("COLD_PLUM_PASS:king-kill-mei");
assert.equal(n(await call('environment()->query("arena_zone")'),"query"),1);console.log("COLD_PLUM_PASS:arena-protection-boundary");
socket.close();console.log("COLD_PLUM_RUNTIME_PASS");
