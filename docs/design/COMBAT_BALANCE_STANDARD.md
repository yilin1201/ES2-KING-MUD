# ES2-KING Combat Balance Standard

## Purpose
Balance is measured before damage values are changed. Original ES2 combat formulas and Source-backed martial values are preserved until runtime evidence shows a concrete imbalance.

## Player baseline
General balance uses ordinary-player checkpoints: Lv.50, Lv.100, Lv.150, Lv.200.
KING/Owner Lv.300 is excluded from ordinary-player balance and is only an upper-bound/regression profile.

## Measurement model
For a fixed attacker/target/equipment setup, collect:
- attempts and landed hits
- hit rate
- damage per landed hit: mean, median (P50), P95, min, max
- rounds/time to defeat or sparring resolution (TTK)
- resource cost per resolved fight and damage/resource efficiency when observable
- post-combat command/movement recovery

Do not infer balance from narration length, ANSI color, or visual impact.

## Role bands
These are ES2-KING design targets, not claims about Original ES2:
- basic/steady technique: relative attack coefficient target 0.90–1.10
- standard school technique: 1.00–1.20
- advanced technique: 1.15–1.35
- explicit perform/burst technique: 1.40–1.80, balanced by resource cost, busy/cooldown, accuracy/risk, or prerequisites

The coefficient is a comparison target, not a license to multiply Original damage directly.

## TTK targets
Against an equal-tier ordinary target:
- normal opponent: 3–6 effective combat rounds
- strong opponent: 8–15
- elite: 15–30
- boss: 30+

Targets are tuning bands. Source-backed NPC behavior may intentionally fall outside them and must be documented before changing it.

## Martial identity
Power is multi-dimensional:
- 冷梅劍法: stable sword/parry identity
- 傲梅暗劍訣: left-hand/tactical burst identity
- 傲劍訣: advanced burst identity
- 如來神掌: unarmed heavy-hit identity
- 大邪七損刀: high-output with meaningful cost/risk
- 青邪杖法: control/defense-break identity pending Source/Canon implementation
- 易筋經: internal-force/sustain identity
- 霸天煉體訣: defense/mitigation identity

Do not make a new martial art superior in every dimension.

## Regression rules
1. Original combat narration is immutable for layout/balance reasons.
2. Never shorten evidence-backed move text to change combat pacing.
3. No KING/Admin/Wizard test may substitute for ordinary-player balance evidence.
4. Balance fixtures use isolated Runtime only; never production Neon.
5. A numeric change requires before/after benchmark evidence.
6. If Source gives an exact value, record it separately from ES2-KING tuning.
