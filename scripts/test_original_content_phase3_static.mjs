import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

// Phase 3 static gate／只驗證目標 Original 殘鏈、Evidence Boundary 與兩個最小 compatibility fix。
const repo = path.resolve(process.argv[2] ?? ".");
const mudlib = path.resolve(process.argv[3] ?? ".runtime/content-audit-original/mudlib");
const read = file => fs.readFileSync(file, "utf8");

const child = read(path.join(mudlib, "d/snow/npc/child.c"));
const gammer = read(path.join(mudlib, "d/snow/npc/gammer.c"));
const guard = read(path.join(mudlib, "d/snow/npc/guard.c"));
const bridge = read(path.join(mudlib, "d/snow/ebridge.c"));
const security = read(path.join(mudlib, "adm/daemons/securityd.c"));
const explore = read(path.join(mudlib, "include/explore.h"));

assert.match(guard, /\/d\/snowkeep\/entrance/);
assert.match(bridge, /\/\/\s*"east"\s*:\s*"\/d\/snowkeep\/entrance"/);
assert.match(explore, /#define\s+ID_SNOWKEEP\s+10/);
assert.equal(fs.existsSync(path.join(mudlib, "d/snowkeep")), false);

for (const state of [3, 5, 10, 13, 15, 43, 50]) {
  assert.match(child, new RegExp(`(?:set_temp|query_temp)\\(\\"try/fon\\"(?:,${state})?`));
}
for (const state of [8, 10, 16, 18, 43, 45, 48]) {
  assert.match(gammer, new RegExp(`(?:set_temp|query_temp)\\(\\"try/fon\\"(?:,\\s*${state})?`));
}
assert.match(child, /ob->id\("__ID_CHALLIE__"\)/);
assert.match(gammer, /ob->id\("__ID_CHALLIE__"\)/);
assert.doesNotMatch(child + gammer, /#define\s+__ID_CHALLIE__/);
assert.match(security, /"\/d\/fon"\s*:\s*\(\{\s*"newbie"\s*\}\)/);
assert.equal(fs.existsSync(path.join(mudlib, "d/fon")), false);

const crate = read(path.join(mudlib, "d/snow/npc/obj/crate.c"));
const wagon = read(path.join(mudlib, "d/snow/npc/obj/wagon.c"));
const originalForeman = read(path.join(mudlib, "d/snow/npc/foreman.c"));
const fixedForeman = read(path.join(repo, "es2_king_expansion/runtime/mudlib/d/snow/npc/foreman.c"));
assert.match(crate, /set\("wage",\s*25\)/);
assert.match(wagon, /add_temp\("wage_deserved",\s*ob->query\("wage"\)\)/);
assert.match(originalForeman, /money->move\(this_object\(\)\)/);
assert.match(originalForeman, /give coin to/);
assert.match(fixedForeman, /ES2-KING Original compatibility/);
assert.match(fixedForeman, /money->move\(me\)/);
assert.doesNotMatch(fixedForeman, /give coin to/);

const teacher = read(path.join(mudlib, "d/snow/npc/teacher.c"));
const apply = read(path.join(repo, "scripts/apply_es2_king_expansion.sh"));
assert.match(teacher, /query_skill\("literate"\)\s*>=\s*5/);
assert.match(teacher, /set_class\("scholar"\)/);
assert.match(teacher, /member_array\(msg\[0\.\.1\],\s*\(\{"想", "是", "好"\}\)\)/);
assert.match(apply, /ES2-KING ORIGINAL SCHOLAR UTF-8 COMPATIBILITY/);
assert.match(apply, /strsrch\(msg, \"想\"\)==0/);

console.log("ORIGINAL_CONTENT_PHASE3_STATIC_PASS");
