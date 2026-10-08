# ES2-KING V13 — ES2M World / NPC / Dialogue Integration Evidence

## Scope

V13 integrates the already preserved ES2M snapshot into the generated Runtime
without replacing the pinned Original ES2 runtime files.

### World zones

- `d/lee` — ES2M snapshot; topology gate already records room/NPC/object closure.
- `d/oldpine` — ES2M snapshot; 50 rooms / 17 NPC / 5 objects are protected by
  the existing topology gate.
- `d/wutang` — ES2M snapshot; 56 rooms / 31 NPC / 2 objects are protected by
  the existing topology gate.
- `custom/zhenwu` — already has a dedicated safe importer and runtime topology
  gate; V13 keeps that path unchanged.
- `d/snow` — remains the pinned Original / existing ES2M integration boundary.

These ES2M snapshot zones are **not** silently relabeled as `CONFIRMED_RUNTIME
Original ES2`. The snapshot remains a separate evidence layer.

## V13 safe import rule

1. Preserve the pinned Original runtime.
2. Add only files that are absent from Runtime.
3. If a same-path file already exists with different SHA-256, stop with
   `CONFLICT_REVIEW`; never overwrite it.
4. Resolve literal LPC file dependencies only when the target exists in either
   snapshot or Runtime.
5. Missing/dynamic/unknown references are not invented.
6. World topology gates run against the generated Runtime after staging.

## Dialogue evidence

The legacy `mudchina/es2-utf8` ES2 lineage preserves:

- `mudlib/cmds/std/ask.c`
- `mudlib/adm/daemons/inquiryd.c`
- NPC `set("inquiry", ([ ... ]))` mappings.

The recovered `ask` command uses the established form:

`ask <NPC> about <topic>`

V13 restores this interface as an isolated runtime overlay. The implementation
does not add new NPC story text or invent missing inquiry topics. NPCs without an
`inquiry` mapping use the generic ES2 fallback responses.

Evidence status: `CORROBORATED_RUNTIME_CANDIDATE` / `ARCHIVED_SOURCE` for the
legacy ES2M dialogue interface. This does **not** upgrade the current taedlar
Original runtime evidence to `CONFIRMED_RUNTIME`.

## Verification boundary

- SOURCE: PASS — source files and topology evidence are present.
- STATIC: PASS — importer safety and dialogue contracts are testable.
- RUNTIME: PENDING until the generated Runtime is actually executed.
- GAMEPLAY: PENDING until a player can traverse an imported zone and exercise
  NPC dialogue in the running MUD.

No GitHub Actions, Oracle, Render, or merge operation is part of this V13 chat
execution.
