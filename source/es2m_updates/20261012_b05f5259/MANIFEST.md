# ES2M Update Snapshot — 2026-10-12

- Source repository: wolfer168/es2-webmud
- Source branch: main
- Source HEAD reviewed: b05f52591d7df60f90305d88d271b59086117397
- Previous KING snapshot baseline: 424c10c8533a7b9f575c43d2da2f3b1627bff205 (2026-10-07)
- Snapshot scope: the eight runtime mudlib files changed by the verified 2026-10-12 military-skill update commit.
- Evidence policy: source preservation only; this snapshot does not claim runtime integration or gameplay PASS.
- Scope warning: the comparison from the previous baseline to this source HEAD contains 74 upstream commits. This snapshot preserves the latest military-skill commit's changed files, not all 74 commits.

## Captured files and source blob SHA

- `adm/daemons/combatd.c` — `7b104a1809241fcb7aa80f5dcdbf60ae4eec8cc7`
- `cmds/std/berserk.c` — `01b4b65dbe12d6afe6b5447efca1763a75b0e919`
- `custom/zhenwu/npc/mee_pei.c` — `e4a09e0733c366b18fcf90394521563da97666b3`
- `custom/zhenwu/obj/recruit_stone.c` — `7a1916b63116862a9e1875bc23bf27752696cf78`
- `daemon/skill/berserk.c` — `f0d5d2736509fb69094b4d1e784d0ea5361d30b8`
- `daemon/skill/heavy_parry.c` — `a2dacaec305bead8fba77254c6d3d79bd4b289a8`
- `daemon/skill/powerblow.c` — `96f3f1838173b496df3b1fcc61bc1b9623bad72e`
- `feature/equip.c` — `cd4ea240add2f48a3ffa2b43ca9d8189082b2325`

## Changes represented

- Berserk experience calculation and level rewards.
- Powerblow experience calculation and level rewards.
- Heavy parry learning/rewards and the Mee Pei teaching journey.
- Recruitment flow no longer grants heavy parry automatically.
- Source changes in combat experience dispatch and equipment damage handling.

## Integration status

SOURCE SNAPSHOT CAPTURED; KING RUNTIME INTEGRATION PENDING REVIEW AND TESTS.
