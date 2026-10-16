# Combat Benchmark Runtime Plan

## Stage A — zero-intrusion observation
Use the ordinary-player source-backed sparring route already covered by Player Open Alpha E2E.
Record elapsed combat time, observable combat events, and post-combat recovery.
Damage fields MUST remain null when the player-visible transcript does not expose reliable HP deltas.

## Stage B — isolated Runtime instrumentation
Locate the Original damage application boundary in the generated isolated Runtime and add observation-only logging there.
Requirements:
- no formula change
- no RNG change
- no extra damage/heal
- no production Neon
- attacker/target/skill/weapon, before/after HP-equivalent stat and applied delta where the Original engine exposes them
- instrumentation must be removable and gated as test-only

Only Stage B evidence may populate damage mean/P50/P95/min/max when player output itself cannot.

## Stage C — repeated baselines
Run fixed profiles at ordinary-player Lv.50/100/150/200 with controlled equipment/target.
KING Lv.300 remains regression-only.

## Stage D — tuning
A martial numeric change is permitted only after a before-baseline exists. Re-run the identical benchmark after the change and compare TTK, hit rate, damage distribution and resource efficiency.
