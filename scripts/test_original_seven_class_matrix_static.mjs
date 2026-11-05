import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

// Phase 3 七職業 Static Gate／保護「已證明」與「尚缺 Source」的邊界，
// 避免日後把外部 ES2 family 或聊天敘述誤當成目標版本 Runtime。
const repo = path.resolve(process.argv[2] ?? ".");
const mudlib = path.resolve(process.argv[3] ?? ".runtime/content-audit-original/mudlib");
const read = file => fs.readFileSync(file, "utf8");

const classDir = path.join(mudlib, "daemon/class");
assert.deepEqual(
  fs.readdirSync(classDir).filter(name => name.endsWith(".c")).sort(),
  ["commoner.c", "fighter.c"],
  "pinned Original class daemon 邊界已改變，必須重新做 Evidence audit",
);

const logind = read(path.join(mudlib, "adm/daemons/logind.c"));
const alchemist = read(path.join(mudlib, "d/snow/npc/alchemist.c"));
const teacher = read(path.join(mudlib, "d/snow/npc/teacher.c"));
const gammer = read(path.join(mudlib, "d/snow/npc/gammer.c"));
const who = read(path.join(mudlib, "cmds/usr/who.c"));

assert.match(logind, /set_class\("commoner"\)/);
assert.match(alchemist, /set_class\("alchemist"\)/);
assert.match(teacher, /set_class\("scholar"\)/);
assert.match(gammer, /set_class\("thief"\)/);

for (const classId of ["alchemist", "commoner", "fighter", "soldier", "thief", "taoist", "scholar"]) {
  assert.match(who, new RegExp(`query_class\\(\\)==\"${classId}\"`));
}
assert.doesNotMatch(who, /query_class\(\)=="bonze"/);

for (const [file, label] of [
  ["alchemist.c", "方士"],
  ["taoist.c", "道士"],
]) {
  const source = read(path.join(repo, "es2_king_expansion/runtime/mudlib/daemon/class", file));
  assert.match(source, /\[ES2-KING Reconstruction\]/);
  assert.match(source, new RegExp(`return \"${label}\"`));
  assert.doesNotMatch(source, /initialize\(|advance_level\(|set_skill\(|valid_wield\(|valid_wear\(/);
}

const matrix = read(path.join(repo, "original_es2/research/original_seven_class_runtime_matrix_phase3.md"));
for (const classId of ["commoner", "fighter", "alchemist", "scholar", "thief", "taoist", "bonze", "soldier"]) {
  assert.ok(matrix.includes(`| \`${classId}\` |`), `Matrix 缺少 ${classId} row`);
}
for (const boundary of ["CONFIRMED_SOURCE", "CONFIRMED_RUNTIME", "ARCHIVED_SOURCE", "CORROBORATED", "RECONSTRUCTION", "SOURCE_REQUIRED", "UNKNOWN", "EVIDENCE_EXHAUSTED"]) {
  assert.match(matrix, new RegExp(boundary));
}
assert.match(matrix, /停止條件 C/);
assert.match(matrix, /Track A — Random Task Quest/);
assert.match(matrix, /Track B — Story \/ Area Quest/);

console.log("ORIGINAL_SEVEN_CLASS_MATRIX_STATIC_PASS");
