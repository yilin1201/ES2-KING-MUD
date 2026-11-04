import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";
import { access, readFile } from "node:fs/promises";
import { constants } from "node:fs";
import { prepareCharacterChoice } from "../webtelnet/public/character-input.mjs";

const url=process.env.ES2_E2E_WS_URL, saveDir=process.env.ES2_E2E_SAVE_DIR, password=process.env.ES2_E2E_PASSWORD;
console.log("ORIGINAL_PLAYER_CREATION_E2E_START", Boolean(url), Boolean(saveDir), Boolean(password));
assert.ok(url && saveDir && password);
const exists=async p=>{try{await access(p,constants.F_OK);return true}catch{return false}};

// ANSI Normalization／測試輸出比對前移除 Telnet 終端控制序列；不改變實際送往 Driver 的輸入位元組。
function cleanOutput(value) {
  return value.replace(/\x1b\[[0-?]*[ -/]*[@-~]/g, "").replace(/\x1b\][^\x07]*(?:\x07|\x1b\\)/g, "");
}

function session(){
  const socket=new WebSocket(url); let output="";
  socket.on("open",()=>{console.log("E2E_WS_OPEN");output+="\\n[WEBSOCKET OPEN]\\n"});
  socket.on("error",e=>{console.error("E2E_WS_ERROR",e.message);output+="\\n[WEBSOCKET ERROR] "+e.message+"\\n"});
  socket.on("close",(code,reason)=>{console.log("E2E_WS_CLOSE",code);output+="\\n[WEBSOCKET CLOSE] "+code+" "+Buffer.from(reason||"").toString("utf8")+"\\n"});
  socket.on("message",d=>{console.log("E2E_WS_MESSAGE_BYTES",d.length);output+=Buffer.from(d).toString("utf8")});
  return {socket, output:()=>output, send:s=>socket.send(s), close:()=>socket.close(),
    wait:(m,o=0,t=30000)=>new Promise((res,rej)=>{
      console.log("E2E_WAIT_START",String(m));
      const st=Date.now(),iv=setInterval(()=>{
        const x=cleanOutput(output.slice(o));
        if((typeof m==="string"?x.includes(m):m.test(x))){
          clearInterval(iv);console.log("E2E_WAIT_MATCH",String(m));res(x);
        } else if(Date.now()-st>t){
          rej(new Error("PLAYER CREATE timeout: "+m+"\\n"+x.slice(-1400)));
        }
      },25)
    })};
}
async function choice(s,value){const p=prepareCharacterChoice(cleanOutput(s.output().slice(-1400)),value);assert.ok(p);s.send(p.bytes)}

// Original input_to 的確認與性別使用 Y/M + CRLF；只有種族選擇使用 WebTelnet ES2RACE 控制訊息。
async function runPlayer({id,raceChoice,raceLabel,name,raceId}){
  const shard=id[0], login=`${saveDir}/login/${shard}/${id}.o`, user=`${saveDir}/user/${shard}/${id}.o`;
  assert.equal(await exists(login),false); assert.equal(await exists(user),false);
  let s=session();
  console.log("E2E_PLAYER_START",id,raceId);
  await s.wait("您的使用者代號"); const co=s.output().length; s.send(id+"\r\n"); await s.wait("您確定嗎",co); await s.wait("(Yes / No)",co); await choice(s,"yes");
  await s.wait("請設定您的密碼"); s.send(password+"\r\n"); await s.wait("請再輸入一次您的密碼"); s.send(password+"\r\n");
  await s.wait("您的電子郵件地址"); const ro=s.output().length; s.send("none\r\n"); await s.wait(raceLabel,ro); await s.wait("可查閱說明",ro); const go=s.output().length; await choice(s,raceChoice); await s.wait("您要扮演的哪種性別",go); await s.wait("(Male / Female)",go); await choice(s,"male");
  await s.wait("您的顯示名稱"); const fo=s.output().length; s.send(name+"\r\n"); await s.wait("您確定要創造這個角色嗎",fo); await s.wait("(Yes / No)",fo); await choice(s,"yes");
  await s.wait("目前權限: (player)"); await s.wait("客棧大堂"); await s.wait("> ");
  await new Promise(r=>setTimeout(r,1200));
  for(const cmd of ["look","score","skills","inventory"]){const o=s.output().length;s.send(cmd+"\r\n");await s.wait("> ",o)}
  const so=s.output().length; s.send("save\r\n"); await s.wait("檔案儲存完畢",so); assert.equal(await exists(login),true); assert.equal(await exists(user),true);
  const qo=s.output().length; s.send("quit\r\n"); await s.wait("歡迎下次再來",qo); s.close(); await new Promise(r=>setTimeout(r,250));
  const saved=await readFile(user,"utf8"); assert.match(saved,new RegExp(`"race":"${raceId}"`)); assert.match(saved,/"class":"commoner"/); assert.match(saved,/"level":1/);
  s=session(); await s.wait("您的使用者代號"); s.send(id+"\r\n"); await s.wait("請輸入密碼"); s.send(password+"\r\n");
  await s.wait("目前權限: (player)"); await s.wait("客棧大堂"); await s.wait("> ");
  const raceCommandProbe = {
    blackteeth:["gnaw",/你要咬誰/],
    yenhold:["breathe",/沒有敵人|神不足/],
    woochan:["replete",/腹中空鳴|神不足/],
    dingling:["hoof",/你要踢誰|正忙著/],
    jiaojao:["hide",/必須在戰鬥中|正忙著/],
    rainner:["feed",/你要餵養哪一條蛇|正忙著/],
    headless:["dance for glory",/戰舞格式|手中沒有斧頭|正忙著/],
    yaksa:["devour",/你要吞食誰|正忙著/],
  }[raceId];
  if (raceCommandProbe) {
    const [cmd, expected] = raceCommandProbe;
    const o=s.output().length; s.send(cmd+"\r\n"); const ability=await s.wait("> ",o);
    assert.match(ability, expected, `${raceId} 專屬指令未進入普通玩家 command path`);
    console.log(`ES2M_RACE_ABILITY_COMMAND_PASS:${raceId}:${cmd}`);
  }
  s.close();
  console.log(`ORIGINAL_PLAYER_CREATION_${raceId.toUpperCase()}_E2E_PASS`);
  // 數字開頭帳號需走同一套建立、存檔、登出及重新登入流程，驗證資料分片目錄可用。
  if (/^\d/.test(id)) console.log("ORIGINAL_PLAYER_CREATION_NUMERIC_ID_E2E_PASS");
}
const races = [
  ["humanprobe","human","human","人類測試","human"],
  ["blackprobe","blackteeth","blackteeth","黑齒測試","blackteeth"],
  ["yenprobe","yenhold","yenhold","厭火測試","yenhold"],
  ["wooprobe","woochan","woochan","無腸測試","woochan"],
  ["dingprobe","dingling","dingling","釘靈測試","dingling"],
  ["jiaoprobe","jiaojao","jiaojao","焦僥測試","jiaojao"],
  ["rainprobe","rainner","rainner","雨師妾測試","rainner"],
  ["ashprobe","ashura","ashura","阿修羅測試","ashura"],
  ["headprobe","headless","headless","刑天測試","headless"],
  ["yaksaprobe","yaksa","yaksa","夜叉測試","yaksa"],
  ["malikprobe","malik","malik","巫首測試","malik"],
  ["7probe","human","人類 (human)","數字帳號測試","human"]
];
for (const [id,raceChoice,raceLabel,name,raceId] of races)
  await runPlayer({id,raceChoice,raceLabel,name,raceId});
console.log("ES2M_SELECTABLE_RACE_ABILITY_COMMANDS_E2E_PASS");
console.log("ES2M_PLAYER_CREATION_11_SELECTABLE_RACES_E2E_PASS");
