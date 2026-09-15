# Original ES2 Race Reconstruction — Phase 2

Status: IN PROGRESS
Branch: `build/original-es2-races-phase2`
Base: M0–M5 merged `main` (`9740478cad342c3193c5e0f611427e31f5fa1fbc`)

## Safety rule

This phase reconstructs Original ES2 races only from recoverable evidence. Missing race daemons, numerical initializers, natural armor, karma, age, or special abilities MUST NOT be invented. ES2-KING expansion data remains separate.

## Confirmed historical race registry evidence

The archived Original ES2 wizard documentation index explicitly lists these race help topics:

- `human`
- `woochan`
- `jiaojao`
- `yenhold`
- `rainnar`
- `ashura`
- `headless`
- `yaksa`
- `blackteeth`

Current `who.c` additionally preserves filters/abbreviations for `malik`, alongside the historical race identifiers above.

This proves that `headless` and the other identifiers were part of the historical Original ES2 race vocabulary, but it does NOT by itself prove their missing initialization formulas or gameplay effects.

## Current executable baseline

Current Annihilator main exposes registered `human` and `avatar` race daemons. M5 has already verified both end-to-end at runtime. Historical race identifiers must therefore be reconstructed separately rather than silently fabricated into the current baseline.

## M6 accelerated acceptance gate

1. Preserve M0–M5 executable baseline.
2. Establish recoverable historical evidence for `headless` before implementing it.
3. Search source/docs/archives for race-specific semantics and numerical behavior.
4. Only source-supported fields may enter `original_es2/` runtime reconstruction.
5. If exact Original behavior remains unrecovered, record the gap explicitly and continue evidence recovery rather than inventing values.
6. Once sufficient evidence exists, add live creation/runtime/persistence/combat verification and run the full regression gate before review.

## Evidence recovered so far

- `[Confirmed Source]` `docs/legacy/wiz/all`: historical race topic list includes `headless`, `yaksa`, `ashura`, `rainnar`, etc.
- `[Confirmed Source]` `mudlib/cmds/usr/who.c`: historical race filters include `headless` (`-hs`), `yaksa`, `ashura`, `rainnar`, `malik`, `woochan`, `jiaojao`, `yenhold`, `blackteeth`, and `human`.
- `[Confirmed Source]` `mudlib/d/snow/npc/teacher.c`: some NPC behavior explicitly branches on historical race IDs, confirming these IDs participated in gameplay logic.

## Open evidence gap

The current searched repositories have not yet yielded the historical `headless` race daemon or a source-backed mapping from `headless` to a Chinese display name and exact initialization/effect formulas. Those fields remain intentionally unset until evidence is recovered.
