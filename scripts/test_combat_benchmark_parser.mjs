import assert from "node:assert/strict";
import { summarizeCombatTranscript } from "./combat_benchmark.mjs";

const sample = "你揮劍攻擊小孩。\n小孩閃躲開來。\n你一劍刺向小孩。\n";
const result = summarizeCombatTranscript(sample, 4250, true);
assert.ok(result.observable_events >= 3);
assert.equal(result.ttk_seconds, 4.25);
assert.equal(result.post_combat_recovery, true);
for (const key of ["damage_mean","damage_p50","damage_p95","damage_min","damage_max","hit_rate"]) {
  assert.equal(result[key], null, `${key} 在沒有 HP delta 證據時必須維持 null`);
}
assert.equal(result.damage_evidence, "UNOBSERVED");
console.log("COMBAT_BENCHMARK_PARSER_PASS:no-fabricated-damage:observable-ttk-recovery");
