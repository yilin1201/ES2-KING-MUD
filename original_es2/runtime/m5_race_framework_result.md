# M5 Race Framework — PASS

Status: **PASS**

## Verified runtime

- Branch: `build/executable-mud-phase1`
- Verification commit: `5c8e47cf4fbc1e743d5995559e9a25374d4dc6a6`
- Workflow: `Original ES2 M5 Races`
- Run: `35002032969` (Run #2)
- Job: `104492488818` (`m5-races`)
- M0–M3 regression: `Original ES2 Driver Build`, Run `35002032989` (Run #63), conclusion `success`
- M4 regression: `Original ES2 M4 Combat and Skills`, Run `35002032991` (Run #14), conclusion `success`

## Scope

M5 verifies the race-selection framework that is actually registered in the current executable Original ES2 source. The current source exposes `human` and `avatar`; M5 does not invent unavailable historical races merely to fill a target list.

## Human live evidence

A fresh character `人類測試` was created through the real login race-selection menu.

Observed runtime probe:

`M5PROBE str=15/15 cor=16/16 int=17/17 spi=18/18 cps=17/17 dex=18/18 con=16/16 wis=16/16 RACE=human LEVEL=1 ARMOR=3 HP=80/80 GIN=30/30 KEE=30/30 SEN=30/30`

Verified:

- Race: `human`
- Level: 1
- Eight base attributes are within Original ES2 Human initialization range 13..18
- Gin/Kee/Sen initialized at 30/30
- Character entered the live world at 客棧大堂

## Avatar live evidence

A second fresh character `化身測試` selected `avatar` through the actual cursor-based race menu and entered the world.

Observed runtime probe:

`M5PROBE str=18/18 cor=17/17 int=18/18 spi=17/17 cps=18/18 dex=16/16 con=17/17 wis=18/18 RACE=avatar LEVEL=1 ARMOR=5 HP=85/85 GIN=30/30 KEE=30/30 SEN=30/30`

Verified:

- Race: `avatar`
- Level: 1
- Eight base attributes are within current Original ES2 Avatar initialization range 16..18
- Natural armor runtime modifier is `+5`
- Gin/Kee/Sen initialized at 30/30
- Character entered the live world at 客棧大堂

## Result

Run #2 emitted:

- `M5 SOURCE PASS`
- `M5 PASS HUMAN`
- `M5 PASS AVATAR`
- `M5 PASS RACES`
- `M5 PASS: current Original ES2 Human/Avatar race framework, initialization, and runtime effects verified.`

M5 therefore passes for the currently executable Original ES2 race framework while keeping historical/expansion race reconstruction separate and evidence-driven.
