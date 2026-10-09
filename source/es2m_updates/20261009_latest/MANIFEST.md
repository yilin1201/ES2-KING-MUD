# ES2M-derived source delta — 2026-10-09

## Source identity
- Source repository: https://github.com/wolfer168/es2-webmud
- Source branch: `main`
- Exact source HEAD: `0948a4cb77fb5fe982d7fe09681791255db18253`
- Previous KING tracked baseline: `be98db057a7de64f368037b6bad9504764cdd854`
- Upstream delta: 35 commits, 134 changed paths.
- Archived in this package: 23 exact text files selected for source preservation and targeted review.
- Scope: NPC power-tier custom system, training dummy behavior, skill progression, Tiger Blade martial arts, and related evidence/tests.
- Classification: **ES2M-derived WebMUD custom variant**, not confirmed Original ES2 canonical content.

## Safety boundary
This package is source evidence only. It does not replace `es2m_snapshot`, pinned Original ES2, or KING Runtime. The upstream changes include custom features and broad NPC rebalance. Do not bulk-overlay them into KING.

## Archived runtime source (18 files)
- `source/upstream/mudlib/daemon/misc/npc_power.c`
- `source/upstream/mudlib/std/char/npc.c`
- `source/upstream/mudlib/daemon/race/beast.c`
- `source/upstream/mudlib/include/daemon.h`
- `source/upstream/mudlib/adm/etc/preload`
- `source/upstream/mudlib/custom/zhenwu/npc/target_stake.c`
- `source/upstream/mudlib/adm/daemons/combatd.c`
- `source/upstream/mudlib/cmds/std/fight.c`
- `source/upstream/mudlib/cmds/std/kill.c`
- `source/upstream/mudlib/cmds/std/look.c`
- `source/upstream/mudlib/feature/char/skill.c`
- `source/upstream/mudlib/daemon/skill/tiger-blade.c`
- `source/upstream/mudlib/daemon/skill/tiger-force.c`
- `source/upstream/mudlib/daemon/skill/tiger-steps.c`
- `source/upstream/mudlib/daemon/skill/lunmay.c`
- `source/upstream/mudlib/daemon/skill/advance_lunmay.c`
- `source/upstream/mudlib/daemon/skill/hainmay_force.c`
- `source/upstream/mudlib/daemon/skill/sanmeendo.c`

## Archived design and test evidence (5 files)
- `docs/CUSTOM_NPC_POWER.md`
- `docs/NPC_POWER_LIST.md`
- `docs/martial_arts/虎刀門_瘋虎刀法.md`
- `tests/test_npc_power.py`
- `tests/test_v32046_tiger_followup.py`

## Findings and integration status
1. NPC power tiers: custom feature requiring a daemon, NPC initialization changes, a header macro and preload. It also changes many NPC files; no bulk runtime integration performed.
2. Training dummy: changes shared combat messages and `fight`/`kill`/`look` commands; requires KING regression checks.
3. Martial arts: updates Tiger Blade/Tiger Force/Tiger Steps and the existing Lunmay/Sanmeendo set. KING's frozen martial-art settings remain untouched.
4. Skill progression: `feature/char/skill.c` overlaps progression logic and is evidence-only pending diff review.
5. Full upstream delta also contains 87 changed Lee/Oldpine/Snow/Wutang NPC files, mainly tied to NPC power tiers. They have not been copied as a bulk overlay in this selected package; the full upstream compare remains the source of truth for the remaining file list.

## Validation
- Exact source HEAD verified through GitHub.
- Archived files are preserved byte-for-byte as text from that HEAD.
- No KING Runtime PASS or gameplay PASS is claimed.
