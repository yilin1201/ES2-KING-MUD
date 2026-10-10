# ES2M delta archive — 2026-10-11

- Source repository: https://github.com/wolfer168/es2-webmud
- Source branch: `main`
- Source HEAD: `06e8f68f89d8da62507726b60208408ad320c899`
- Previous audited HEAD: `60c12efac447d63730f953ac83ef47fdc62f7368`
- Compare result: 1 commit ahead; 1 added file.
- Classification: ES2M-derived WebMUD custom variant; not Original ES2 canonical content.
- Purpose: evidence preservation only; this package is not an automatic Runtime overlay.

## Archived file

| Source path | Change | Source Git blob | KING decision |
|---|---|---|---|
| `source/upstream/mudlib/custom/wizroom/w/windstory/room/home.c` | Added (18 lines) | `a6f21e4d4763d1adf39c7c75bc9597608f963fc8` | Archive only. Do not overlay into player Runtime until room dependencies and intended scope are verified. |

## Safety notes

- The room short description is `未知地方`.
- East exit targets a sibling `dragon_inn` path; west exit targets `/d/snow/square_w`.
- It creates a closed east door. Do not assume all exit destinations, door behavior, or player-facing design are ready solely because the source file exists.
- No Original ES2 files or KING Runtime files were modified in this batch.
