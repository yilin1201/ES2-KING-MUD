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
