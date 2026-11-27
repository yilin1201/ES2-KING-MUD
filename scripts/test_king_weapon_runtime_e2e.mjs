import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";

const url = process.env.ES2_E2E_WS_URL;
const password = process.env.ES2_E2E_KING_PASSWORD;
assert.ok(url && password);

let socket, output = "", lastSentAt = 0;
const sleep = ms => new Promise(r => setTimeout(r, ms));
async function connect() {
  output = ""; socket = new WebSocket(url);
  socket.on("message", d => { output += Buffer.from(d).toString("utf8"); });
  await new Promise((resolve,reject)=>{socket.once("open",resolve);socket.once("error",reject);});
}
function wait(offset, matcher, timeout=20000) {
  return new Promise((resolve,reject)=>{
    const started=Date.now(), timer=setInterval(()=>{
      const tail=output.slice(offset), ok=typeof matcher==="string"?tail.includes(matcher):matcher.test(tail);
      if(ok){clearInterval(timer);resolve(tail);}
      else if(Date.now()-started>timeout){clearInterval(timer);reject(new Error(`KING WEAPON E2E timeout: ${String(matcher)}\n${tail.slice(-1800)}`));}
    },25);
  });
}
async function command(line, matcher="> ", timeout=20000) {
  const delay=Math.max(0,450-(Date.now()-lastSentAt)); if(delay) await sleep(delay);
  const offset=output.length; socket.send(line+"\r\n"); lastSentAt=Date.now(); return wait(offset,matcher,timeout);
}
async function login() {
  await connect(); await wait(0,"您的使用者代號"); await command("king","請輸入密碼");
  await command(password,"目前權限: (admin)"); await wait(0,"> ");
}
async function quit() {
  const offset=output.length; socket.send("quit\r\n"); await wait(offset,"歡迎下次再來"); socket.close(); await sleep(150);
}
const has=(t,r,m)=>assert.match(t,r,m);
const lacks=(t,r,m)=>assert.doesNotMatch(t,r,m);

function inventoryCount(text, name) {
  return text.split(name).length-1;
}
async function invFive(stage) {
  const text=await command("inventory");
  for(const name of ["古霄","飛雲","古霄・飛雲","靈刀祭血","九曲十彎"])
    assert.equal(inventoryCount(text,name),1,`${stage}: ${name} 必須剛好一件`);
  return text;
}

await login();
await invFive("login");
console.log("KING_WEAPON_STAGE_PASS:inventory-five");

// Empty Hand／以 Original unwield 回應驗證沒有登入自動裝備。
for(const name of ["古霄","飛雲","古霄・飛雲","靈刀祭血","九曲十彎"])
  has(await command(`unwield ${name}`),/並沒有裝備|沒有裝備|沒有使用|並未裝備/);
console.log("KING_WEAPON_STAGE_PASS:login-empty-hand");

has(await command("wield 古霄 as sword"),/裝備.*古霄.*武器|古霄.*裝備/s);
has(await command("unwield 古霄"),/卸下|解除|不再使用|收起/s);
console.log("KING_WEAPON_STAGE_PASS:guxiao-sword");

has(await command("wield 古霄 as sword"),/裝備.*古霄.*武器|古霄.*裝備/s);
has(await command("wield 飛雲 as secondhand sword"),/裝備.*飛雲.*武器|飛雲.*裝備/s);
has(await command("unwield 古霄"),/卸下|解除|不再使用|收起/s);
has(await command("unwield 飛雲"),/卸下|解除|不再使用|收起/s);
console.log("KING_WEAPON_STAGE_PASS:dual-wield");

has(await command("wield 古霄・飛雲 as sword"),/裝備.*古霄・飛雲.*武器|古霄・飛雲.*裝備/s);
await command("unwield 古霄・飛雲");
has(await command("wield 古霄・飛雲 as twohanded sword"),/裝備.*古霄・飛雲.*武器|古霄・飛雲.*裝備/s);
// Original Human Rule：雙手武器持有時不得再裝第二把。
has(await command("wield 飛雲 as secondhand sword"),/雙手|兩手|無法|不能|已經.*武器|騰出/s);
await command("unwield 古霄・飛雲");
console.log("KING_WEAPON_STAGE_PASS:merged-sword-one-two-handed");

has(await command("wield 靈刀祭血 as blade"),/裝備.*靈刀祭血.*武器|靈刀祭血.*裝備/s);
await command("unwield 靈刀祭血");
console.log("KING_WEAPON_STAGE_PASS:blood-blade");

has(await command("wield 九曲十彎 as twohanded staff"),/裝備.*九曲十彎.*武器|九曲十彎.*裝備/s);
await command("unwield 九曲十彎");
console.log("KING_WEAPON_STAGE_PASS:god-cane");

// Persistence／存檔前全部已卸下；重登後 provisioning 不得 duplicate，也不得 auto-wield。
has(await command("save"),/檔案儲存完畢/);
await quit();
await login();
await invFive("relogin");
for(const name of ["古霄","飛雲","古霄・飛雲","靈刀祭血","九曲十彎"])
  has(await command(`unwield ${name}`),/並沒有裝備|沒有裝備|沒有使用|並未裝備/);
console.log("KING_WEAPON_STAGE_PASS:save-quit-relogin-no-duplicate-empty-hand");

socket.close();
console.log("KING_WEAPON_RUNTIME_E2E_PASS");
