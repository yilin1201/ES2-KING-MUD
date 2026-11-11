# ES2M delta archive — 2026-10-11

- Source repository: https://github.com/wolfer168/es2-webmud
- Source branch: `main`
- Source HEAD: `a1d4f08bcb4a24dbe9abb8618bd32f8e8f0b2192`
- Previous compared HEAD: `06e8f68f89d8da62507726b60208408ad320c899`
- Upstream delta: 13 commits, 21 changed paths.
- Classification: ES2M-derived WebMUD custom variant; not Original ES2 canonical content.
- All changed paths are preserved with upstream relative paths under this folder.
- 11 of the 12 changed mudlib paths are synced to `es2m_snapshot/mudlib/`. The snapshot deliberately retains KING’s custom Tiger Force growth table; the exact ES2M Tiger Force source is archived here but not used to replace the KING snapshot. Only explicitly reviewed files are copied to KING Runtime Overlay.

## Changed source files

### Mudlib (12)
- `source/upstream/mudlib/adm/daemons/combatd.c`
- `source/upstream/mudlib/cmds/usr/gain.c`
- `source/upstream/mudlib/cmds/usr/score.c`
- `source/upstream/mudlib/d/lee/obj/well.c`
- `source/upstream/mudlib/d/snow/npc/obj/pot.c`
- `source/upstream/mudlib/d/snow/npc/obj/wine_pot.c`
- `source/upstream/mudlib/daemon/skill/hainmay_force.c`
- `source/upstream/mudlib/daemon/skill/tiger-force.c`
- `source/upstream/mudlib/feature/char/score.c`
- `source/upstream/mudlib/feature/char/skill.c`
- `source/upstream/mudlib/std/martial_art.c`
- `source/upstream/mudlib/std/room.c`

### Design docs (2)
- `docs/martial_arts/冷梅莊_劍士武功.md`
- `docs/martial_arts/招架規則設計.md`

### Tests (4)
- `tests/test_skill_attr_growth.py`
- `tests/test_v32059_skill_boundaries.py`
- `tests/test_v32059_skill_learned_restore.py`
- `tests/test_v32076_final_skill_and_remove_interaction.py`

### Web UI (3)
- `web/app.js`
- `web/index.html`
- `web/styles.css`

## Runtime integration boundary

Reviewed and integrated: Hainmay Force learning/progression fix, tiered attribute-growth odds, martial-art weapon-object guards, and water/wine container refill behavior.

Archive-only pending compatibility review: shared combat daemon, gain/score/player-level progression, common room base class, Lee village well, Tiger Force full source, and ES2M web client. KING-specific growth rules and the `king` 300-level exception must not be overwritten.
