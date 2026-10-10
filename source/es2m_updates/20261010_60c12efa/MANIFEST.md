# ES2M Update Snapshot 2026-10-10

- Source repository: wolfer168/es2-webmud
- Source branch: main
- Source HEAD: 60c12efac447d63730f953ac83ef47fdc62f7368
- Prior snapshot: source/es2m_updates/20261007_424c10c8/ (HEAD 424c10c8533a7b9f575c43d2da2f3b1627bff205)
- Evidence policy: this folder preserves exact ES2M source files; it does not overwrite Original ES2 source.
- Latest source commits reviewed:
  - 9a3ae930eb9eddbee9bcb1e64a095c626745eca6 — NPC power system, NPC/skill content, martial arts and world data.
  - a4cbb2aca25dd328ca46929f5d5a0f6cf04fa1bf — abandon/disable/enable skill command behavior.
  - 2408f56046574a3c0a62d4bb09e28aaa8155f4e7 — training dummy behavior for combat, fight/kill/look and martial-art messages.
  - da0a1d77a2c7627b53c40cae2523554858d73cda — Mayin/Seven martial arts and entry-level reward behavior.
  - 64914ac8e74f7f588443e35512af27dffd50d788 — May Yin Fong NPC.
  - 60c12efac447d63730f953ac83ef47fdc62f7368 — current main HEAD merge commit.
- This snapshot stores the ES2M source evidence most directly needed to finish training-dummy and scholar/teacher integration.

## Preserved exact ES2M source files

- source/upstream/mudlib/adm/daemons/combatd.c
- source/upstream/mudlib/cmds/std/fight.c
- source/upstream/mudlib/cmds/std/kill.c
- source/upstream/mudlib/cmds/std/look.c
- source/upstream/mudlib/custom/zhenwu/npc/target_stake.c
- source/upstream/mudlib/d/snow/npc/teacher.c

## King integration audit

- Already matching current ES2M source in the Expansion overlay: cmds/usr/abandon.c, cmds/usr/disable.c, cmds/usr/enable.c, daemon/skill/mayin.c, daemon/skill/seven.c, std/martial_art.c, daemon/misc/npc_power.c, std/char/npc.c, include/daemon.h, d/wutang/crossroad.c.
- Intentional King-specific differences retained: feature/char/skill.c keeps KING-only Lv.300 skill-cap and King progression compatibility; d/wutang/npc/may_yin_fong.c keeps the Original ES2 race identifier "rainnar" and the King skill-entry-level mechanism.
- Pending integration from this snapshot: training-dummy combat behavior and related commands, plus the remaining ES2M teacher updates. All integration must occur in the Expansion/runtime patch layer, not by rewriting Original ES2 evidence.
