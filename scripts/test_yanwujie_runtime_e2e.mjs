import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";
const url=process.env.ES2_E2E_WS_URL,password=process.env.ES2_E2E_KING_PASSWORD;
assert.ok(url&&password);
let socket,output="",lastSentAt=0;
async function connect(){output="";socket=new WebSocket(url);socket.on("message",d=>output+=Buffer.from(d).toString("utf8"));await new Promise((r,j)=>{socket.once("open",r);socket.once("error",j)})}
const wait=(o,m,t=20000)=>new Promise((r,j)=>{const s=Date.now(),x=setInterval(()=>{const q=output.slice(o),ok=typeof m==="string"?q.includes(m):m.test(q);if(ok){clearInterval(x);r(q)}else if(Date.now()-s>t){clearInterval(x);j(new Error(`timeout ${m}\n${q.slice(-1200)}`))}},25)});
async function cmd(v,m="> ",t=20000){const d=Math.max(0,400-(Date.now()-lastSentAt));if(d)await new Promise(r=>setTimeout(r,d));const o=output.length;socket.send(v+"\r\n");lastSentAt=Date.now();return wait(o,m,t)}
function n(t,m){const x=t.match(new RegExp(`->${m}\\([^)]*\\) = (-?\\d+)`));assert.ok(x,t.slice(-500));return Number(x[1])}
await connect();await wait(0,"您的使用者代號");await cmd("king","請輸入密碼");await cmd(password,"目前權限: (admin)");await wait(0,"> ");
await cmd("goto /d/king/wuji_realm","天神殿・無極之境");
assert.match(await cmd("enter"),/競技場：演武界/);
console.log("YANWUJIE_PASS:enter");
const level=n(await cmd("call me->query_level()"),"query_level");
const skill=n(await cmd('call me->query_skill("force",1)'),"query_skill");
const hpMax=n(await cmd('call me->query_stat_maximum("HP")'),"query_stat_maximum");
assert.ok(hpMax>0);
const o=output.length;
socket.send(`call me->consume_stat("HP",${hpMax+1},me)\r\n`);
await wait(o,"演武界法則引動",20000);
const hp=n(await cmd('call me->query_stat_current("HP")'),"query_stat_current");
const hpEff=n(await cmd('call me->query_stat_effective("HP")'),"query_stat_effective");
assert.equal(hp,hpMax);assert.equal(hpEff,hpMax);
assert.equal(n(await cmd("call me->query_level()"),"query_level"),level);
assert.equal(n(await cmd('call me->query_skill("force",1)'),"query_skill"),skill);
assert.match(await cmd('call me->query("life_form")'),/= "living"/);
console.log("YANWUJIE_PASS:defeat-reconstruct-no-ghost");
assert.match(await cmd("out"),/天神殿・無極之境/);
console.log("YANWUJIE_PASS:out");
socket.close();console.log("YANWUJIE_RUNTIME_PASS");
