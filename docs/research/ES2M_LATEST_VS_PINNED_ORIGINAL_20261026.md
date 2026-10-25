# ES2M latest mirror vs pinned Original ES2 — three-way import baseline

- Latest ES2M: `wolfer168/es2-webmud@88e23bfde225d4d27904533ee606da9b5b20aabb`
- Pinned Original ES2: `taedlar/es2_mudlib@cc45c06af4852380e5148dad3c9d53ff06854f2c`
- KING branch: `build/original-es2-races-phase2`
- Mirror files: 1791
- Pinned Original mudlib files: 536

## Results

| Result | Files |
|---|---:|
| Same path, same Git blob SHA | 346 |
| Same path, different Git blob SHA | 175 |
| ES2M-only paths (potential missing-source candidates) | 1270 |
| Pinned Original-only paths (preserve; do not delete) | 15 |

### Same-path conflicts by category

```json
{
  "Shared/Core": 77,
  "World/NPC/Quest": 71,
  "Classes": 2,
  "Races": 3,
  "Other": 3,
  "Items/Equipment": 19
}
```

### ES2M-only paths by category

```json
{
  "Shared/Core": 19,
  "Items/Equipment": 573,
  "Other": 259,
  "World/NPC/Quest": 326,
  "Classes": 6,
  "Races": 21,
  "Skills": 66
}
```

### Pinned Original-only paths

- `cmds/adm/halt.c`
- `cmds/wiz/analyze.c`
- `log/README.md`
- `obj/drug/black_pill.c`
- `obj/medication/alchemist/aquapill.c`
- `obj/medication/alchemist/black_pill.c`
- `obj/medication/alchemist/green_pill.c`
- `obj/medication/alchemist/major_heal_pill.c`
- `obj/medication/alchemist/minor_heal_pill.c`
- `obj/medication/alchemist/mix_recipe.c`
- `obj/medication/alchemist/mjp_1.c`
- `obj/medication/alchemist/mjp_2.c`
- `obj/medication/alchemist/mjp_3.c`
- `obj/medication/alchemist/refresh_pill.c`
- `obj/medication/black_pill.c`

## Import implications

- **Do not bulk-overwrite the pinned Original mudlib.** There are 175 same-path content conflicts, including 77 shared-core conflicts and 71 world/NPC/quest conflicts.
- The 1270 ES2M-only paths are *candidates*, not auto-import approvals. Their includes, inherits, clone paths, room exits, item references and dynamic loads must be resolved against the target runtime.
- The 15 Original-only files must remain available; the source mirror is not a drop-in replacement for the pinned Original ES2.
- The current Docker build still bootstraps pinned Original ES2 and applies the existing snapshot-based KING scripts. It does **not** yet automatically promote all files from `es2m_source_mirror/mudlib/` into Runtime.
- Therefore the next implementation batch is to create a latest-ES2M candidate manifest, classify by category, then import only absent files whose dependencies close and whose targeted static/Driver tests pass.

*Git tree/blob SHA comparison only; no full byte-level SHA-256 recomputation or live Driver E2E was performed.*
