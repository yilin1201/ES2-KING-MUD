# Targeted Class Source Recovery — RC1

> Date: 2026-09-28
> Scope: Fighter → Taoist; Bonze/Soldier only if a new source pointer appears.
> Rule: Evidence First. This recovery does not modify Runtime LPC and does not promote external-family code to target Original Source without lineage proof.

## Starting baseline

- Branch: `build/original-es2-races-phase2`
- Starting HEAD: `78a24fe535c9e4295f729dc59c4fad1161054cf0`
- PR #13: OPEN / NOT MERGED.
- Existing target audit: seven-class matrix already records Fighter/Taoist as Source-blocked and Bonze/Soldier as exhausted or Source-required.

## Target tree / current branch negative evidence

Targeted code search on the current ES2-KING branch found no direct player transition for:

- `set_class("fighter")`
- `set_class("taoist")`
- the historical Tian-shi master names 郭布、安懶道人、白齊、華子儀.

This does not prove that no historical ES2 version ever contained such a chain. It records the current target-tree boundary only.

## R4 — taedlar/es2_mudlib v1.4-lineage cross-check

Public source at commit `4321c8f36657bff43ae03471e60f02c53ab048f8` gives additional direct source evidence that `fighter` is a real runtime class in that lineage:

- `mudlib/obj/npc/garrison.c` assigns the NPC `set_class("fighter")`.
- `mudlib/obj/area/vagabond.c` assigns the NPC `set_class("fighter")`.
- `mudlib/d/snow/npc/guard.c` branches on `this_player()->query_class()=="fighter"`.
- `mudlib/cmds/usr/who.c` filters `-fr` players by `query_class()=="fighter"`.

These prove Fighter runtime identity/consumption, **not** a player entry chain. No `fighter apprentice` / player recruitment source was recovered from this targeted search.

For Taoist, the same lineage preserves `who.c` filtering `query_class()=="taoist"`, but targeted search did not recover a `set_class("taoist")` player transition or Original Taoist class daemon.

Evidence grade: `CONFIRMED_SOURCE` for class identity/consumption inside that public v1.4 lineage; `SOURCE_REQUIRED` for target player entry chain.

## R4 — MudRen/ES2-utf8 external-family cross-check

MudRen/ES2-utf8 at commit `9ccc9da35cf9e9df86ec4ec43278f1eec251836b` contains substantially more complete class systems, but its API/path structure conflicts with the current target lineage.

### Fighter

Recovered external-family examples:

- `std/room/class_guild.c`: directly writes `me->set("class", "fighter")`, sets `startroom` to `CLASS_D("fighter") + "/guildhall"`, and announces the player has become a 武者.
- `daemon/class/fighter/guildhall.c`: inherits `CLASS_GUILD`.
- `d/waterfog/guildhall.c`: clones multiple `CLASS_D("fighter")` masters.
- `daemon/class/ninja/master.c`: apprentice recruitment can set `class` to `fighter`.

### Taoist

Recovered external-family examples:

- `daemon/class/taoist/taolord.c`: Taoist class master object.
- `d/temple/temple1.c`: clones `CLASS_D("taoist") + "/taolord"`.
- multiple `d/temple/npc/*.c` objects identify as `class = taoist`.
- `daemon/class/juechen/master.c`: successful `recruit_apprentice()` sets `class` to `taoist`.

### Lineage boundary

This external family uses data/property APIs such as:

- `me->set("class", "fighter")`
- `ob->set("class", "taoist")`
- `CLASS_D(...)/guildhall`

The current target v1.4 evidence uses character methods such as `set_class()` / `query_class()` and a different class-daemon layout. Therefore these files are **not treated as same-version executable evidence**.

Evidence grade: `CORROBORATED / EXTERNAL_FAMILY / VERSION-LINEAGE CONFLICT`.

They are useful to prove that historical ES2-family implementations had concrete Fighter/Taoist recruitment concepts, but they must not be copied into target Runtime without additional same-lineage proof.

## Fighter result

- Runtime class identity: CONFIRMED_SOURCE.
- Player Entry Room: SOURCE_REQUIRED.
- Player Master NPC: SOURCE_REQUIRED.
- Apprentice/recruit trigger: SOURCE_REQUIRED.
- Player `set_class("fighter")` transition: SOURCE_REQUIRED.
- Target Runtime Gate: **NOT READY**.

## Taoist result

- Historical identity/Help: ARCHIVED_SOURCE.
- Runtime class consumption in public v1.4 lineage: CONFIRMED_SOURCE (`who -tt`).
- Target Entry Room / Master / apprentice transition: SOURCE_REQUIRED.
- Target Original class daemon: SOURCE_REQUIRED.
- External-family Taoist master/recruitment: CORROBORATED only.
- Target Runtime Gate: **NOT READY**.

## Bonze / Soldier

No new target-version source pointer emerged from Fighter/Taoist targeted recovery. Per RC1 scope, Bonze/Soldier were not reopened.

Existing state remains unchanged.

## RC1 conclusion

`TARGETED EVIDENCE RECOVERY EXHAUSTED` for the currently reachable Fighter/Taoist source graph.

New evidence sharpened the boundary but did not satisfy `READY_FOR_RUNTIME`:

- Fighter has stronger direct proof of runtime class use in the public v1.4 lineage.
- MudRen external-family code preserves explicit Fighter and Taoist entry/recruitment implementations.
- The external implementations use a materially different class API/layout and cannot safely fill the target gaps.

Runtime LPC modified: **NO**.
UNKNOWN invented: **NO**.
PR merge requested: **NO**.

Reopen Runtime only when a new same-lineage source supplies at minimum a player Entry/Recruit transition compatible with the target class API, and for Taoist an attributable target-version class daemon.


## 2026-09-28 R4 TARGET — Source Lineage Recovery

### Repository/version facts

Public repository metadata establishes an important boundary:

- `taedlar/es2_mudlib` states that its initial GitHub commit is based on ES2 Mudlib v1.3b and that its `v1.4` branch is the legacy MudOS/FluffOS line.
- `MudRen/ES2-big5` identifies itself as ES2 mudlib v1.3b adapted for FluffOS v2017.
- `MudRen/ES2-utf8` is a later FluffOS v2019 adaptation.
- `mudchina/es2` is a preserved ES2 GBK snapshot with only a shallow public Git history; its source tree nevertheless contains historical class-guild content.

Therefore the public Git commit graphs are **not sufficient to identify a single historical commit at which the class API “forked.”** Much of the historical source predates these Git imports.

### Critical API comparison

The apparent `set_class()` versus `set("class", ...)` split is **not a mutually exclusive lineage fork**.

`MudRen/ES2-big5/feature/char/score.c` contains:

- `query_class() { return query("class"); }`
- `set_class(string new_class)` which internally performs `set("class", new_class)`
- `CLASS_D(new_class)->initialize(this_object())`

`taedlar/es2_mudlib/mudlib/feature/char/score.c` preserves the same essential wrapper/API and initialization pattern.

At the same time, `mudchina/es2/std/room/class_guild.c` and `MudRen/ES2-utf8/std/room/class_guild.c` directly write:

- `me->set("class", "fighter")`

Thus direct property assignment and the `set_class()` wrapper coexist in the broader ES2 source family. The difference is a **call-site / content-generation difference**, not evidence of a clean engine-level API fork.

### Fighter lineage result

`mudchina/es2` preserves a complete historical Fighter guild content chain:

- `std/room/class_guild.c`: `join` sets player class to `fighter` and start room to `CLASS_D("fighter") + "/guildhall"`.
- `daemon/class/fighter/guildhall.c`: identifies the Fighter guildhall and explains that joining makes the player a 武者.

This is much stronger than the earlier MudRen-only observation because the same content exists in the mudchina ES2 snapshot.

However, the current target/taedlar v1.4-style tree lacks `std/room/class_guild.c` and the Fighter guildhall content. This is therefore evidence of **historical ES2 content present in another preserved snapshot but absent from the target snapshot**, not proof that the target release used that exact player-entry chain.

Classification: `ARCHIVED/EXTERNAL ES2 SOURCE — STRONG LINEAGE CORROBORATION`; target Runtime remains blocked.

### Taoist lineage result

`mudchina/es2/daemon/class/taoist/taolord.c` preserves an explicit Taoist master:

- 林忌／六指真人
- 茅山派
- `F_MASTER`
- successful `recruit_apprentice()` writes player `class = taoist`

This source is also represented in the later UTF-8 family.

The target/taedlar v1.4-style snapshot does not preserve this Taoist class content. Therefore it is strong historical ES2-family source evidence, but there is still no direct proof that the target snapshot's live content used this exact master/path/recruitment implementation.

Classification: `ARCHIVED/EXTERNAL ES2 SOURCE — STRONG LINEAGE CORROBORATION`; target Taoist daemon/entry remains SOURCE_REQUIRED.

### R4 TARGET conclusion

The requested “fork point” between `set_class()` and `set("class", ...)` cannot be established because the premise of a clean fork is not supported by the recovered code:

1. `set_class()` is a wrapper around the same underlying `class` property.
2. historical content can directly set the property while the wrapper exists in the same ES2 family.
3. public repositories are later imports/adaptations with shallow/incomplete pre-Git history, so they cannot date the original content divergence precisely.

The meaningful divergence is **content snapshot completeness**, not a proven incompatible class engine.

This improves historical confidence for Fighter/Taoist identity and recruitment design, but does **not** meet the project's target-version Runtime Gate.

Status:

- Fighter historical ES2 recruitment source: STRONG / preserved in mudchina snapshot.
- Taoist historical ES2 recruitment source: STRONG / preserved in mudchina snapshot.
- Exact target-version adoption of those chains: UNKNOWN / SOURCE_REQUIRED.
- Clean API fork commit/date: EVIDENCE EXHAUSTED with current public history.
- `READY_FOR_RUNTIME`: **NO** under the existing strict same-target-version rule.
- Runtime modified: **NO**.


## 2026-09-28 R4 TARGET GATE — Historical Source Reconstruction Audit

### Gate rule

No Runtime LPC was modified. This audit asks whether preserved historical ES2 Fighter/Taoist content can be expressed by the current target engine without inventing game rules.

### Compatibility matrix

| Layer | Fighter | Taoist |
|---|---|---|
| Historical class identity | DIRECTLY COMPATIBLE | DIRECTLY COMPATIBLE |
| Historical entry/recruit source | STRONG: `class_guild.c` + `fighter/guildhall.c` | STRONG: `taolord.c` + F_MASTER recruitment |
| Target class storage | DIRECTLY COMPATIBLE: `query("class")` underlies `query_class()` | DIRECTLY COMPATIBLE |
| Target `set_class()` | DIRECTLY COMPATIBLE and safer than historical direct property write | DIRECTLY COMPATIBLE mechanically |
| Target `CLASS_D` | CONFIRMED | CONFIRMED mechanically |
| Target Original class daemon | CONFIRMED: `daemon/class/fighter.c` | MISSING: only ES2-KING rank compatibility reconstruction |
| `initialize()` dependency | Target `fighter.c` has no explicit initialize; engine call is still attributable | Original Taoist initialize/behavior is UNKNOWN |
| Entry room/path | Historical Waterfog entrance→Fighter guildhall is preserved in mudchina, absent from target snapshot | Historical temple/master placement exists outside target snapshot; target placement UNKNOWN |
| Apprentice/recruit API | Fighter historical entry uses `join`, so no invented apprentice condition is needed | Historical source uses a different F_MASTER/recruit command generation than target v1.4 apprentice command |
| Persistence | Target M31 Driver already proves the `class` property survives save→quit→relogin→restore | Same storage mechanism is proven, but semantic daemon behavior remains missing |

### Fighter — minimal Reconstruction Adapter

Historical ES2 Source proves the rule:

`join Fighter guild → class=fighter → Fighter guildhall/startroom`.

The current target engine proves:

- player class is stored in the same `class` property;
- `set_class("fighter")` is the target-safe wrapper for that property;
- target Original `daemon/class/fighter.c` exists;
- rank lookup through `CLASS_D("fighter")` is attributable;
- M31 has already proven that a class property changed through the target engine persists through real save/quit/relogin/restore.

Therefore a bounded reconstruction can translate the historical direct assignment:

`me->set("class","fighter")`

to the target-safe call:

`me->set_class("fighter")`

without changing the historical gameplay rule (join→fighter). This is an **adapter**, not a claim that the missing target file has been recovered byte-for-byte.

However, the historical Waterfog room/guildhall files themselves are absent from the target snapshot. A reconstruction must preserve their provenance and must not claim them as recovered target LPC.

**Fighter Gate: `RECONSTRUCTION_READY`**, bounded to the historical join→fighter class transition and target persistence. Do not infer additional school masters, recruit conditions, skills, formulas, equipment rules, or advancement.

### Taoist — gate remains closed

Historical `mudchina/es2/daemon/class/taoist/taolord.c` proves a real ES2 Taoist recruitment design, but direct transplant/adaptation is not yet safe:

1. the historical NPC uses `F_MASTER` + `attempt_apprentice()` + `recruit_apprentice()`;
2. the current target v1.4 `cmds/std/apprentice.c` instead calls NPC `accept_apprentice()` then `init_apprentice()`;
3. target Original Taoist class daemon is missing;
4. Taoist initialize/advance behavior and exact target entry placement remain UNKNOWN.

Using the historical Taoist NPC would therefore require inventing or adapting more than a storage call; it would require a recruitment-protocol adapter and a non-Original class daemon boundary.

**Taoist Gate: `SOURCE_REQUIRED`**.

### Persistence boundary

The existing M31 isolated Driver test is direct target Runtime evidence that the `class` value is serialized and restored:

commoner → Original apprentice transition → alchemist → save → quit → relogin → class restored.

This establishes persistence of the class property generically. It does not prove Fighter/Taoist entry semantics by itself, but it closes the storage/persistence layer needed by the Fighter reconstruction gate.

### Final gate result

- Fighter: **RECONSTRUCTION_READY**
  - allowed scope: historical `join → fighter` transition, adapted to target `set_class("fighter")`, with explicit Reconstruction provenance;
  - required validation before PASS: Static + real Driver Entry→Class→rank→save→quit→relogin.
- Taoist: **SOURCE_REQUIRED**
  - blocker: recruitment protocol mismatch + missing target Original daemon/initialize boundary.
- Runtime modified by this audit: **NO**.
- UNKNOWN invented: **NO**.
