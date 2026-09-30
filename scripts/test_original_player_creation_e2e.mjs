import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";
import { access, readFile } from "node:fs/promises";
import { constants } from "node:fs";
import { prepareCharacterChoice } from "../webtelnet/public/character-input.mjs";

const url=process.env.ES2_E2E_WS_URL, saveDir=process.env.ES2_E2E_SAVE_DIR, password=process.env.ES2_E2E_PASSWORD;
assert.ok(url && saveDir && password);
const exists=async p=>{try{await access(p,constants.F_OK);return true}catch{return false}};

function session(){
  const socket=new WebSocket(url); let output="";
  socket.on("message",d=>output+=Buffer.from(d).toString("utf8"));
  return {socket, output:()=>output, send:s=>socket.send(s), close:()=>socket.close(),
    wait:(m,o=0,t=30000)=>new Promise((res,rej)=>{const st=Date.now(),iv=setInterval(()=>{const x=output.slice(o);if((typeof m==="string"?x.includes(m):m.test(x))){clearInterval(iv);res(x)}else if(Date.now()-st>t){clearInterval(iv);rej(new Error("PLAYER CREATE timeout: "+m+"\n"+x.slice(-1400)))}},25)})};
}
async function choice(s,value){const p=prepareCharacterChoice(s.output().slice(-512),value);assert.ok(p);s.send(p.bytes)}

async function runPlayer({id,raceChoice,raceLabel,name,raceId}){
  const shard=id[0], login=`${saveDir}/login/${shard}/${id}.o`, user=`${saveDir}/user/${shard}/${id}.o`;
  assert.equal(await exists(login),false); assert.equal(await exists(user),false);
  let s=session();
  await s.wait("您的使用者代號"); s.send(id+"\r\n"); await s.wait("您確定嗎"); await choice(s,"yes");
  await s.wait("請設定您的密碼"); s.send(password+"\r\n"); await s.wait("請再輸入一次您的密碼"); s.send(password+"\r\n");
  await s.wait("您的電子郵件地址"); s.send("none\r\n"); await s.wait(raceLabel);
  const ro=s.output().length; await choice(s,raceChoice); await s.wait("您要扮演的哪種性別",ro); await choice(s,"male");
  await s.wait("您的顯示名稱"); s.send(name+"\r\n"); await s.wait("您確定要創造這個角色嗎"); await choice(s,"yes");
  await s.wait("目前權限: (player)"); await s.wait("客棧大堂"); await s.wait("> ");
  await new Promise(r=>setTimeout(r,1200));
  for(const cmd of ["look","score","skills","inventory"]){const o=s.output().length;s.send(cmd+"\r\n");await s.wait("> ",o)}
  s.send("save\r\n"); await s.wait("檔案儲存完畢"); assert.equal(await exists(login),true); assert.equal(await exists(user),true);
  s.send("quit\r\n"); await s.wait("歡迎下次再來"); s.close(); await new Promise(r=>setTimeout(r,250));
  const saved=await readFile(user,"utf8"); assert.match(saved,new RegExp(`"race":"${raceId}"`)); assert.match(saved,/"class":"commoner"/); assert.match(saved,/"level":1/);
  s=session(); await s.wait("您的使用者代號"); s.send(id+"\r\n"); await s.wait("請輸入密碼"); s.send(password+"\r\n");
  await s.wait("目前權限: (player)"); await s.wait("客棧大堂"); await s.wait("> "); s.close();
  console.log(`ORIGINAL_PLAYER_CREATION_${raceId.toUpperCase()}_E2E_PASS`);
}
await runPlayer({id:"humanprobe",raceChoice:"human",raceLabel:"Human（人類）",name:"人類測試",raceId:"human"});
await runPlayer({id:"avatarprobe",raceChoice:"人類族",raceLabel:"Avatar（人類族）",name:"人類族測試",raceId:"avatar"});
console.log("ORIGINAL_PLAYER_CREATION_E2E_PASS");
