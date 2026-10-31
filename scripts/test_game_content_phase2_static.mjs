import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

// Game Content Phase 2／以 pinned Original mudlib 為輸入，重建可重複的 Snow 內容清冊與連線檢查。
const mudlib = path.resolve(process.argv[2] ?? ".runtime/content-audit-original/mudlib");
const snow = path.join(mudlib, "d/snow");
const read = file => fs.readFileSync(file, "utf8");
const cFiles = dir => fs.readdirSync(dir)
  .filter(name => name.endsWith(".c"))
  .sort();

assert.ok(fs.existsSync(snow), `找不到 Original Snow：${snow}`);

const roomFiles = cFiles(snow);
const npcFiles = cFiles(path.join(snow, "npc"));
const snowNpcObjects = cFiles(path.join(snow, "npc/obj"));
const snowObjects = cFiles(path.join(snow, "obj"));
const sharedAreaObjects = cFiles(path.join(mudlib, "obj/area/obj"));

assert.equal(roomFiles.length, 43, "Snow room 數量與 pinned Original 不符");
assert.equal(npcFiles.length, 23, "Snow NPC 數量與 pinned Original 不符");
assert.equal(snowNpcObjects.length, 29, "Snow NPC object 數量與 pinned Original 不符");
assert.equal(snowObjects.length, 3, "Snow area object 數量與 pinned Original 不符");
assert.equal(sharedAreaObjects.length, 26, "共用 area object 數量與 pinned Original 不符");

const roomNames = new Set(roomFiles.map(file => path.basename(file, ".c")));
const edges = new Map([...roomNames].map(name => [name, new Set()]));
const missingActiveDestinations = [];

for (const file of roomFiles) {
  const from = path.basename(file, ".c");
  const source = read(path.join(snow, file));
  const withoutLineComments = source.replace(/\/\/.*$/gm, "");
  const blocks = [
    ...(withoutLineComments.match(/set\s*\(\s*"exits"[\s\S]*?\]\s*\)\s*\);/g) ?? []),
    withoutLineComments,
  ];
  const destinations = new Set();
  for (const block of blocks) {
    for (const match of block.matchAll(/__DIR__\s*"([a-zA-Z0-9_]+)"/g)) destinations.add(match[1]);
    for (const match of block.matchAll(/"\/d\/snow\/([a-zA-Z0-9_]+)"/g)) destinations.add(match[1]);
  }
  for (const destination of destinations) {
    if (roomNames.has(destination)) edges.get(from).add(destination);
    else if (!destination.startsWith("npc") && !destination.startsWith("obj")) {
      missingActiveDestinations.push(`${from}->${destination}`);
    }
  }
}

assert.deepEqual(missingActiveDestinations, [], "存在指向缺檔 Snow room 的 active reference");

const reached = new Set(["inn_hall"]);
const queue = ["inn_hall"];
while (queue.length) {
  const current = queue.shift();
  for (const destination of edges.get(current) ?? []) {
    if (!reached.has(destination)) {
      reached.add(destination);
      queue.push(destination);
    }
  }
}
const unreachableRooms = [...roomNames].filter(name => !reached.has(name));
assert.deepEqual(unreachableRooms, ["inn_staff_room"], "玩家不可達 room 邊界改變");
assert.match(read(path.join(snow, "npc/innkeeper.c")), /inn_staff_room/);

// Evidence Boundaries／這三條缺檔依賴必須留在報告，不得因靜態 Gate 而誤判為完整。
assert.match(read(path.join(snow, "npc/guard.c")), /\/d\/snowkeep\/entrance/);
assert.match(read(path.join(snow, "npc/obj/wine_pot.c")), /\/d\/choyin\/npc\/obj\/red_wine/);
assert.match(read(path.join(mudlib, "adm/daemons/chard.c")), /\/d\/domain\/npc\/police/);

// Closed Target-Version Content／可從入口走完的盜賊鏈只檢查呼叫證據；真正行為由 Runtime E2E 驗收。
assert.match(read(path.join(snow, "npc/child.c")), /new\(__DIR__"obj\/comb"\)/);
assert.match(read(path.join(snow, "npc/gammer.c")), /set_class\("thief"\)/);
assert.match(read(path.join(snow, "npc/gammer.c")), /improve_skill\("sneak", 20\)/);
assert.match(read(path.join(snow, "npc/gammer.c")), /improve_skill\("stealing", 20\)/);

const inventory = {
  area: ["/d/snow"],
  rooms: roomFiles.length,
  playerReachableRooms: reached.size,
  serviceOnlyRooms: unreachableRooms,
  npcs: npcFiles.length,
  snowNpcObjects: snowNpcObjects.length,
  snowObjects: snowObjects.length,
  sharedAreaObjects: sharedAreaObjects.length,
  activeMissingRoomDestinations: missingActiveDestinations,
};
console.log(JSON.stringify(inventory, null, 2));
console.log("GAME_CONTENT_PHASE2_STATIC_PASS");
