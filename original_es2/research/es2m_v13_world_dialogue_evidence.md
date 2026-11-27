# ES2-KING V13 — ES2M World / NPC / Dialogue Integration Evidence

## Scope

V13 integrates the preserved ES2M snapshot into generated Runtime without silently
overwriting pinned Original ES2 runtime files.

### World zones

- `d/lee` — ES2M snapshot; topology gate records room/NPC/object closure.
- `d/oldpine` — ES2M snapshot; 50 rooms / 17 NPC / 5 objects are protected by the existing topology gate.
- `d/wutang` — ES2M snapshot; 56 rooms / 31 NPC / 2 objects are protected by the existing topology gate.
- `custom/zhenwu` — existing safe importer and runtime topology gate remain unchanged.
- `d/snow` — pinned Original / existing ES2M integration boundary.

These snapshot zones are not silently relabeled as CONFIRMED_RUNTIME Original ES2.

## V13 safe import rule

1. Preserve the pinned Original runtime.
2. Add only files absent from Runtime.
3. Same-path different SHA-256 => `CONFLICT_REVIEW`; never overwrite.
4. Resolve only literal LPC dependencies whose targets are known.
5. Missing/dynamic/unknown references are not invented.
6. Topology gates run against generated Runtime after staging.
7. Dialogue overlay staging is file-level only and is not Gameplay PASS.

## Dialogue evidence — two verified Original lineages

The legacy `mudchina/es2-utf8` lineage was reviewed at commit
`87bba6bd2249beec8424b0d6623486a0dd1f7b30`.

### A. ES2M / Annihilator 1995 inquiry daemon

Direct historical source:

- `mudlib/adm/daemons/inquiryd.c`
- Header comment: `Created by Annihilator@ES2 (01-19-95)`
- Function: `parse_inquiry(object me, object ob, string topic)`
- Confirmed default topics:
  - `name` / `名字`
  - `here` / `这里`
  - `rumors` / `传闻`
- Unknown topic returns `0`.

The exact historical source is preserved in:
`source/es2m_updates/20261008_v13/runtime_overlay/mudlib/adm/daemons/inquiryd.c`.

### B. Historical ES2M ask command behavior

The same pinned lineage contains `mudlib/cmds/std/ask.c` which directly
confirms:

- `ask <NPC> about <topic>`
- `ask <NPC>` can enumerate `query("inquiry")` keys.
- `can_speak` is checked in that lineage.
- `INQUIRY_D->parse_inquiry(me, ob, topic)` is called before the NPC-specific
  `query("inquiry/" + topic)` fallback.
- Historical NPC files contain `set("inquiry", ([ ... ]))` mappings and
  function-valued handlers.

Examples directly found include Snow blacksmith, Snow teacher, Snow herbalist,
Snow post officer, Snow fist trainer, city NPCs, and many other records.

### C. Later taedlar Original ES2 command contract

The pinned `taedlar/es2_mudlib` commit
`7309240af1720b813cef3eb0ba135afc1f19c2ac` contains a later/different
`ask.c` contract:

- `ask <NPC> about <topic>`
- `ask <NPC> for <negotiation>`
- `target->is_character()`
- `target->query("no_fight")`
- `target->accept_inquiry(me, key)`
- `target->accept_negotiation(me, key)`
- `rank("respectful")`

The V13 ask overlay currently preserves this later Original contract.

## Important compatibility boundary

The two verified lineages are not treated as interchangeable.

The historical ES2M `ask.c` expects `INQUIRY_D` and
`query("inquiry")) behavior, while the later taedlar `ask.c` delegates to
NPC methods `accept_inquiry()` / `accept_negotiation()`.

Current ES2-KING does not yet have verified Runtime evidence for those NPC
methods. Therefore V13 does **not** invent their implementation.

The restored 1995 `inquiryd.c` is currently an evidence-backed source overlay.
The safe overlay script only adds files that do not already exist; it never
overwrites the existing Original `ask.c`. If a same-path conflict occurs it
is recorded as `CONFLICT_REVIEW`.

## Evidence status

- `CONFIRMED_SOURCE`: ES2M 1995 `inquiryd.c), historical `ask.c`, and NPC
  `inquiry` mappings.
- `CONFIRMED_SOURCE`: later taedlar `ask.c` callback contract.
- `STATIC_PASS`: V13 evidence files and safe overlay script are present.
- `RUNTIME_PENDING`: generated MUD has not been executed in this chat run.
- `GAMEPLAY_PENDING`: no player journey has exercised imported NPC dialogue.
- `CONFLICT_REVIEW`: expected for any attempt to replace an existing
  same-path Original command with a different historical lineage.

## Verification boundary

SOURCE: PASS  
STATIC: PASS  
RUNTIME: PENDING  
GAMEPLAY: PENDING

No merge is authorized. PR #13 remains OPEN.
