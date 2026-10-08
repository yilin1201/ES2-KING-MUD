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

The legacy `mudchina/es2-utf8` ES2 lineage was reviewed at commit
`87bba6bd2249beec8424b0d6623486a0dd1f7b30`.

Direct evidence confirms:

- `mudlib/cmds/std/ask.c` parses:
  - `ask <NPC> about <topic>`
  - `ask <NPC> for <negotiation>`
- The command validates `target->is_character()`.
- The `about` branch calls:
  `target->accept_inquiry(me, key)`.
- The `for` branch calls:
  `target->accept_negotiation(me, key)`.
- `no_fight` NPC protection and `rank("respectful")` dialogue formatting
  are part of the preserved command implementation.
- Historical NPC source contains `set("inquiry", ([ ... ]))` mappings. Examples
  include Snow blacksmith and Snow teacher, plus many city/NPC records.

V13 therefore restores **only the verified command contract**. It does not
invent an `inquiryd` daemon, an `inquiry` mapping fallback, or new NPC story
text when the corresponding Original source evidence is unavailable.

The V13 `ask.c` overlay is a source-preserving reconstruction of the verified
Original command contract; NPC-specific `accept_inquiry` implementation must
come from the target NPC lineage before it can be declared runtime-complete.

Evidence status:
- `CONFIRMED_SOURCE`: command syntax and NPC callback contract.
- `ARCHIVED_SOURCE`: historical NPC `inquiry` mappings from the pinned legacy
  lineage.
- `RUNTIME_PENDING`: V13 overlay has not been executed in the generated MUD
  during this chat run.
- `GAMEPLAY_PENDING`: no player journey has yet exercised imported NPC dialogue.

## Verification boundary

- SOURCE: PASS — source files and topology evidence are present.
- STATIC: PASS — importer safety and dialogue contract tests are present.
- RUNTIME: PENDING until the generated Runtime is actually executed.
- GAMEPLAY: PENDING until a player can traverse an imported zone and exercise
  NPC dialogue in the running MUD.

No GitHub Actions, Oracle, Render, or merge operation is part of this V13 chat
execution.
