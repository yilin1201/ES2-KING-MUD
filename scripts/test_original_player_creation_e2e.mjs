import assert from "node:assert/strict";
import WebSocket from "../webtelnet/node_modules/ws/wrapper.mjs";
import { access, readFile } from "node:fs/promises";
import { constants } from "node:fs";
import { prepareCharacterChoice } from "../webtelnet/public/character-input.mjs";

const url=process.env.ES2_E2E_WS_URL, saveDir=process.env.ES2_E2E_SAVE_DIR, password=process.env.ES2_E2E_PASSWORD;
assert.ok(url && saveDir && password);

// Character Prompt Contract／登入介面協定回歸：同一解析器須同時支援 Original ES2 與 ES2M。
// 先在啟動 Driver 前驗證格式與實際輸入 bytes，避免只靠後段 timeout 才發現介面不相容。
function testCharacterPromptCompatibility() {
  const originalGender = "您要扮演的哪種性別(外觀)的角色?";
  assert.equal(prepareCharacterChoice(originalGender, "female")?.bytes, "F");
  assert.equal(prepareCharacterChoice(originalGender, "male")?.bytes, "M");
  assert.equal(prepareCharacterChoice(originalGender, "unknown")?.bytes, "N");

  const es2mGender = "您要扮演的哪種性別(外觀)的角色?\n1. 女性\n2. 男性\n3. 無法判斷\n請輸入選項數字:";
  assert.equal(prepareCharacterChoice(es2mGender, "female")?.bytes, "1\r\n");
  assert.equal(prepareCharacterChoice(es2mGender, "male")?.bytes, "2\r\n");
  assert.equal(prepareCharacterChoice(es2mGender, "unknown")?.bytes, "3\r\n");

  const originalConfirm = "您確定要創造這個角色嗎?";
  const es2mConfirm = "使用 7probe 這個代號將會創造一個新的人物﹐您確定嗎? (Yes / No)";
  assert.equal(prepareCharacterChoice(originalConfirm, "yes")?.bytes, "Y");
  assert.equal(prepareCharacterChoice(es2mConfirm, "yes")?.bytes, "Y");
  console.log("CHARACTER_PROMPT_COMPATIBILITY_PASS: Original ES2 + ES2M");
}
testCharacterPromptCompatibility();
const exists=async p=>{try{await access(p,constants.F_OK);return true}catch{return false}};

function session(){
  const socket=new WebSocket(url); let output="";
  socket.on("message",d=>output+=Buffer.from(d).toString("utf8"));
  return {socket, output:()=>output, send:s=>socket.send(s), close:()=>socket.close(),
    wait:(m,o=0,t=30000)=>new Promise((res,rej)=>{const st=Date.now(),iv=setInterval(()=>{const x=output.slice(o);if((typeof m==="string"?x.includes(m):m.test(x))){clearInterval(iv);res(x)}else if(Date.now()-st>t){clearInterval(iv);rej(new Error("PLAYER CREATE timeout: "+m+"\n"+x.slice(-1400)))}},25)})};
}
async function choice(s,value){
  const outputTail=s.output().slice(-512);
  const p=prepareCharacterChoice(outputTail,value);
  // 選項提示解析失敗時先輸出實際畫面尾端，保留 E2E 根因證據再讓測試失敗。
  if(!p){
    console.error("E2E choice parse failed; requested choice="+JSON.stringify(value)+"; last 512 output characters:\n"+outputTail);
    assert.ok(p,"無法從最近 512 字元解析角色建立選項；以上已輸出實際畫面。");
  }
  s.send(p.bytes);
}

async function runPlayer({id,raceChoice,raceLabel,name,raceId}){
  const shard=id[0], login=`${saveDir}/login/${shard}/${id}.o`, user=`${saveDir}/user/${shard}/${id}.o`;
  assert.equal(await exists(login),false); assert.equal(await exists(user),false);
  let s=session();
  await s.wait("您的使用者代號"); s.send(id+"\r\n"); await s.wait("您確定嗎"); await choice(s,"yes");
  await s.wait("請設定您的密碼"); s.send(password+"\r\n"); await s.wait("請再輸入一次您的密碼"); s.send(password+"\r\n");
  await s.wait("您的電子郵件地址"); s.send("none\r\n"); await s.wait(raceLabel);
  const ro=s.output().length; await choice(s,raceChoice); await s.wait("您要扮演的哪種性別",ro); await choice(s,"male");
  await s.wait("您的顯示名稱");
  // E2E 診斷：只記錄顯示名稱輸入的 UTF-8 bytes（十六進位），確認是否含 CR/LF 控制字元。
  // 顯示名稱不是密碼；禁止在這裡記錄帳號密碼或其他認證資料。
  const displayNameInput = name + "\r\n";
  const displayNameBytesHex = [...Buffer.from(displayNameInput, "utf8")]
    .map(byte => byte.toString(16).padStart(2, "0"))
    .join(" ");
  console.error("E2E display-name input bytes (hex): " + displayNameBytesHex);
  s.send(displayNameInput);
  try {
    await s.wait("您確定要創造這個角色嗎");
  } catch (error) {
    console.error("E2E display-name confirmation failed; last 512 output characters:\n" + s.output().slice(-512));
    throw error;
  }
  await choice(s, "yes");
  await s.wait("目前權限: (player)"); await s.wait("客棧大堂"); await s.wait("> ");
  await new Promise(r=>setTimeout(r,1200));
  for(const cmd of ["look","score","skills","inventory"]){const o=s.output().length;s.send(cmd+"\r\n");await s.wait("> ",o)}
  s.send("save\r\n"); await s.wait("檔案儲存完畢"); assert.equal(await exists(login),true); assert.equal(await exists(user),true);
  s.send("quit\r\n"); await s.wait("歡迎下次再來"); s.close(); await new Promise(r=>setTimeout(r,250));
  const saved=await readFile(user,"utf8");
  assert.match(saved,new RegExp(`"race":"${raceId}"`));
  assert.match(saved,/"class":"commoner"/);
  assert.match(saved,/"level":1/);

  // ES2M birth-attribute contract／核對實際存檔的八大出生屬性；範圍依同分支 ES2M race daemon 的 base + random(n) 推導。
  // random(n) 的有效範圍為 base 至 base+n-1；這裡只驗證出生屬性範圍，不把 Original ES2 基準與 ES2M 採用值混為一談。
  const birthRanges = {
    human:      {str:[13,18],cor:[13,18],int:[13,18],spi:[13,18],cps:[13,18],dex:[13,18],con:[13,18],wis:[13,18]},
    avatar:     {str:[15,20],cor:[15,20],int:[15,20],spi:[15,20],cps:[15,20],dex:[15,20],con:[15,20],wis:[15,20]},
    blackteeth: {str:[14,19],cor:[15,20],int:[5,15],spi:[3,8],cps:[10,15],dex:[11,16],con:[13,18],wis:[6,11]},
    yenhold:    {str:[15,20],cor:[9,14],int:[5,10],spi:[7,12],cps:[14,20],dex:[9,14],con:[17,22],wis:[10,15]},
    woochan:    {str:[10,15],cor:[10,15],int:[15,20],spi:[15,20],cps:[13,18],dex:[15,20],con:[10,15],wis:[14,22]},
    dingling:   {str:[14,20],cor:[8,11],int:[11,18],spi:[8,11],cps:[8,17],dex:[17,25],con:[14,20],wis:[12,16]},
    jiaojao:    {str:[8,14],cor:[8,13],int:[16,19],spi:[13,19],cps:[13,19],dex:[18,24],con:[11,16],wis:[13,18]},
    rainner:    {str:[6,9],cor:[6,9],int:[17,22],spi:[18,24],cps:[15,20],dex:[10,13],con:[10,13],wis:[20,28]},
    ashura:     {str:[20,25],cor:[25,40],int:[13,18],spi:[14,22],cps:[5,10],dex:[15,20],con:[17,22],wis:[13,18]},
    headless:   {str:[25,30],cor:[15,20],int:[8,13],spi:[5,10],cps:[11,16],dex:[19,24],con:[23,28],wis:[13,18]},
    yaksa:      {str:[16,25],cor:[17,25],int:[13,18],spi:[13,18],cps:[13,18],dex:[13,18],con:[16,25],wis:[13,18]},
    malik:      {str:[8,11],cor:[8,11],int:[25,30],spi:[25,30],cps:[23,28],dex:[20,25],con:[10,15],wis:[20,25]}
  };
  const expectedAttributes = birthRanges[raceId];
  assert.ok(expectedAttributes, `缺少 ${raceId} 出生屬性驗證規格`);
  for (const [attribute, [min, max]] of Object.entries(expectedAttributes)) {
    const match = saved.match(new RegExp(`"${attribute}"\\s*:\\s*(-?\\d+)`));
    assert.ok(match, `存檔缺少出生屬性 ${attribute}，無法判定 ${raceId} 創角數值`);
    const value = Number(match[1]);
    assert.ok(value >= min && value <= max,
      `${raceId} 出生屬性 ${attribute}=${value} 超出 ES2M 快照範圍 ${min}..${max}`);
  }
  console.log(`ES2M_BIRTH_ATTRIBUTES_PASS:${raceId}`);
  s=session(); await s.wait("您的使用者代號"); s.send(id+"\r\n"); await s.wait("請輸入密碼"); s.send(password+"\r\n");
  await s.wait("目前權限: (player)"); await s.wait("客棧大堂"); await s.wait("> ");
  const raceCommandProbe = {
    human:["resurge",/只有形體或氣降到最大值四分之一以下時才能使用 resurge|復甦之力尚未恢復/],
    avatar:["radiate",/身上泛起一陣柔和光芒|radiate 尚在冷卻中/],
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
}
// ES2M login policy／固定來源允許 3–12 位小寫英文字母或數字，顯示名稱允許 1–18 個 UTF-8 字元。
async function testEs2mLoginPolicy(){
  const id="7probe", shard=id[0];
  const login=`${saveDir}/login/${shard}/${id}.o`, user=`${saveDir}/user/${shard}/${id}.o`;
  assert.equal(await exists(login),false); assert.equal(await exists(user),false);
  const s=session();
  await s.wait("您的使用者代號");
  s.send(id+"\r\n");
  await s.wait("您確定嗎");
  await choice(s,"yes");
  await s.wait("請設定您的密碼"); s.send(password+"\r\n");
  await s.wait("請再輸入一次您的密碼"); s.send(password+"\r\n");
  await s.wait("您的電子郵件地址"); s.send("none\r\n");
  await s.wait("Human（人類）");
  const raceOffset=s.output().length;
  await choice(s,"human");
  await s.wait("您要扮演的哪種性別",raceOffset);
  await choice(s,"male");
  await s.wait("您的顯示名稱"); s.send("熊\r\n");
  await s.wait("您確定要創造這個角色嗎"); await choice(s,"yes");
  await s.wait("目前權限: (player)"); await s.wait("客棧大堂"); await s.wait("> ");
  s.send("save\r\n"); await s.wait("檔案儲存完畢");
  assert.equal(await exists(login),true); assert.equal(await exists(user),true);
  const saved=await readFile(user,"utf8");
  assert.match(saved,/"race"\s*:\s*"human"/);
  assert.match(saved,/"name"\s*:\s*"熊"/);
  console.log("ES2M_PLAYER_CREATION_NUMERIC_ID_ACCEPTED_PASS");
  console.log("ES2M_SINGLE_CHARACTER_DISPLAY_NAME_PASS");
  s.send("quit\r\n"); await s.wait("歡迎下次再來"); s.close();
}

const races = [
  ["humanprobe","human","Human（人類）","人類測試","human"],
  ["avatarprobe","人類族","Avatar（人類族）","人類族測試","avatar"],
  ["blackprobe","blackteeth","黑齒","黑齒測試","blackteeth"],
  ["yenprobe","yenhold","厭火","厭火測試","yenhold"],
  ["wooprobe","woochan","無腸","無腸測試","woochan"],
  ["dingprobe","dingling","釘靈","釘靈測試","dingling"],
  ["jiaoprobe","jiaojao","焦僥","焦僥測試","jiaojao"],
  ["rainprobe","rainner","雨師妾","雨師妾測試","rainner"],
  ["ashprobe","ashura","阿修羅","阿修羅測試","ashura"],
  ["headprobe","headless","刑天","刑天測試","headless"],
  ["yaksaprobe","yaksa","夜叉","夜叉測試","yaksa"],
  ["malikprobe","malik","巫首","巫首測試","malik"]
];
for (const [id,raceChoice,raceLabel,name,raceId] of races)
  await runPlayer({id,raceChoice,raceLabel,name,raceId});
await testEs2mLoginPolicy();
console.log("ES2M_RACE_ABILITY_COMMANDS_E2E_PASS");
console.log("ES2M_PLAYER_CREATION_12_RACES_E2E_PASS");
