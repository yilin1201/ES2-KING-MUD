import assert from "node:assert/strict";
import { parseBalanceLog } from "./parse_combat_balance_log.mjs";
const r=parseBalanceLog([
"noise",
"ES2BALANCE damage=10 kill=0 target=child attacker=tester source=/obj/wooden_sword",
"ES2BALANCE damage=20 kill=0 target=child attacker=tester source=/obj/wooden_sword",
"ES2BALANCE damage=30 kill=0 target=child attacker=tester source=/obj/wooden_sword"
].join("\n"));
assert.equal(r.samples,3);
assert.equal(r.damage_mean,20);
assert.equal(r.damage_p50,20);
assert.equal(r.damage_p95,30);
assert.equal(r.damage_min,10);
assert.equal(r.damage_max,30);
console.log("COMBAT_BALANCE_LOG_PARSER_PASS:mean-p50-p95-min-max");
