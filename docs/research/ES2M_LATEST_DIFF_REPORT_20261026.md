# ES2M latest source vs KING saved snapshot — diff baseline (2026-10-26)

## Fixed evidence

- ES2M upstream repository: `wolfer168/es2-webmud`
- Upstream commit: `88e23bfde225d4d27904533ee606da9b5b20aabb`
- KING branch: `build/original-es2-races-phase2`
- Branch HEAD used for this report: `28d4a0443643ef2472352f9f7e2e802781b4066e`
- Source mirror: `es2m_source_mirror/mudlib/` (1791 files)
- Existing saved snapshot: `es2m_snapshot/mudlib/` (1142 files)
- KING overlay inventory: `es2_king_expansion/runtime/mudlib/` (100 files)

## Mirror ↔ snapshot comparison

| Result | Count |
|---|---:|
| Same relative path and same Git blob SHA | 940 |
| Same path, different content SHA | 184 |
| Present in latest mirror, absent from saved snapshot | 667 |
| Present in saved snapshot, absent from latest mirror | 18 |

### Same-path content conflicts by category

```json
{
  "Shared/Core": 20,
  "Items/Equipment": 29,
  "Other": 12,
  "World/NPC/Quest": 109,
  "Classes": 2,
  "Races": 6,
  "Skills": 6
}
```

### Latest mirror-only files by category (not automatically importable)

```json
{
  "Other": 214,
  "Shared/Core": 258,
  "Items/Equipment": 76,
  "World/NPC/Quest": 86,
  "Races": 5,
  "Skills": 28
}
```

### Snapshot-only files by category (potential KING/legacy additions; do not delete)

```json
{
  "World/NPC/Quest": 4,
  "Skills": 2,
  "Items/Equipment": 12
}
```

## Same-path content conflicts — review queue

- `adm/daemons/combatd.c` — Shared/Core
- `adm/simul_efun/utf8.c` — Shared/Core
- `cmds/usr/score.c` — Shared/Core
- `custom/armor/armor/ring_armor.c` — Items/Equipment
- `custom/armor/feet/spider_boots.c` — Items/Equipment
- `custom/armor/head/iron_helmet.c` — Items/Equipment
- `custom/armor/waist/iron_girth.c` — Items/Equipment
- `custom/home/npc/butler.c` — Other
- `custom/home/obj/storage_chest.c` — Other
- `custom/taoism/npc/fire_taoist.c` — Other
- `custom/taoism/npc/freeze_taoist.c` — Other
- `custom/taoism/npc/storm_taoist.c` — Other
- `custom/taoism/npc/thunder_taoist.c` — Other
- `custom/weapon/blade/green_blade.c` — Items/Equipment
- `custom/weapon/blade/large_blade.c` — Items/Equipment
- `custom/weapon/blade/steelblade.c` — Items/Equipment
- `custom/weapon/staff/long_staff.c` — Items/Equipment
- `custom/weapon/staff/zenstaff.c` — Items/Equipment
- `custom/weapon/whip/bamboo_fishing_rod.c` — Items/Equipment
- `custom/zhenwu/npc/lu_xinien.c` — Other
- `custom/zhenwu/npc/mee_pei.c` — Other
- `custom/zhenwu/npc/soldier.c` — Other
- `custom/zhenwu/npc/target_stake.c` — Other
- `custom/zhenwu/npc/zhenwu_soldier.c` — Other
- `custom/zhenwu/obj/recruit_stone.c` — Other
- `d/lee/LEE_TOPOLOGY.json` — World/NPC/Quest
- `d/lee/creek.c` — World/NPC/Quest
- `d/lee/herb_shop.c` — World/NPC/Quest
- `d/lee/inn.c` — World/NPC/Quest
- `d/lee/npc/child.c` — World/NPC/Quest
- `d/lee/npc/farmer.c` — World/NPC/Quest
- `d/lee/npc/guard.c` — World/NPC/Quest
- `d/lee/npc/hawthorn_seller.c` — World/NPC/Quest
- `d/lee/npc/herb_boy.c` — World/NPC/Quest
- `d/lee/npc/hunter.c` — World/NPC/Quest
- `d/lee/npc/lee_hsu_hsien.c` — World/NPC/Quest
- `d/lee/npc/lee_xiao_tian.c` — World/NPC/Quest
- `d/lee/npc/lee_yen.c` — World/NPC/Quest
- `d/lee/npc/lee_yong.c` — World/NPC/Quest
- `d/lee/npc/lee_zhong.c` — World/NPC/Quest
- `d/lee/npc/li_ban_xian.c` — World/NPC/Quest
- `d/lee/npc/nee_cheng.c` — World/NPC/Quest
- `d/lee/npc/teacher.c` — World/NPC/Quest
- `d/lee/npc/traveller.c` — World/NPC/Quest
- `d/lee/npc/waiter.c` — World/NPC/Quest
- `d/lee/npc/woman.c` — World/NPC/Quest
- `d/lee/obj/brow_staff.c` — World/NPC/Quest
- `d/lee/obj/heaven_dew.c` — World/NPC/Quest
- `d/lee/obj/waterskin.c` — World/NPC/Quest
- `d/lee/pawnshop.c` — World/NPC/Quest
- `d/lee/square_c.c` — World/NPC/Quest
- `d/lee/square_s.c` — World/NPC/Quest
- `d/lee/watermelon_n1.c` — World/NPC/Quest
- `d/lee/watermelon_s3.c` — World/NPC/Quest
- `d/oldpine/cave_deep.c` — World/NPC/Quest
- `d/oldpine/grass1.c` — World/NPC/Quest
- `d/oldpine/grass2.c` — World/NPC/Quest
- `d/oldpine/highway.c` — World/NPC/Quest
- `d/oldpine/npc/bandit.c` — World/NPC/Quest
- `d/oldpine/npc/bandit_minion.c` — World/NPC/Quest
- `d/oldpine/npc/big_bear.c` — World/NPC/Quest
- `d/oldpine/npc/da_guan.c` — World/NPC/Quest
- `d/oldpine/npc/deer.c` — World/NPC/Quest
- `d/oldpine/npc/herbalist.c` — World/NPC/Quest
- `d/oldpine/npc/injured_traveller.c` — World/NPC/Quest
- `d/oldpine/npc/kao_shen.c` — World/NPC/Quest
- `d/oldpine/npc/lin_yuchan.c` — World/NPC/Quest
- `d/oldpine/npc/little_bear.c` — World/NPC/Quest
- `d/oldpine/npc/rat.c` — World/NPC/Quest
- `d/oldpine/npc/seller.c` — World/NPC/Quest
- `d/oldpine/npc/squirrel.c` — World/NPC/Quest
- `d/oldpine/npc/waiter.c` — World/NPC/Quest
- `d/oldpine/npc/wild_bear.c` — World/NPC/Quest
- `d/oldpine/npc/wolf.c` — World/NPC/Quest
- `d/oldpine/npc/xue_biao.c` — World/NPC/Quest
- `d/snow/herb_shop.c` — World/NPC/Quest
- `d/snow/inn_hall.c` — World/NPC/Quest
- `d/snow/npc/alchemist.c` — World/NPC/Quest
- `d/snow/npc/child.c` — World/NPC/Quest
- `d/snow/npc/child1.c` — World/NPC/Quest
- `d/snow/npc/child2.c` — World/NPC/Quest
- `d/snow/npc/child3.c` — World/NPC/Quest
- `d/snow/npc/child4.c` — World/NPC/Quest
- `d/snow/npc/foreman.c` — World/NPC/Quest
- `d/snow/npc/gammer.c` — World/NPC/Quest
- `d/snow/npc/garrison.c` — World/NPC/Quest
- `d/snow/npc/girl.c` — World/NPC/Quest
- `d/snow/npc/guard.c` — World/NPC/Quest
- `d/snow/npc/herbalist.c` — World/NPC/Quest
- `d/snow/npc/innkeeper.c` — World/NPC/Quest
- `d/snow/npc/junkman.c` — World/NPC/Quest
- `d/snow/npc/lieutenant.c` — World/NPC/Quest
- `d/snow/npc/miller.c` — World/NPC/Quest
- `d/snow/npc/oldman.c` — World/NPC/Quest
- `d/snow/npc/patrol.c` — World/NPC/Quest
- `d/snow/npc/smith.c` — World/NPC/Quest
- `d/snow/npc/teacher.c` — World/NPC/Quest
- `d/snow/npc/woman.c` — World/NPC/Quest
- `d/snow/npc/yu.c` — World/NPC/Quest
- `d/snow/skill/dragon_force.c` — World/NPC/Quest
- `d/snow/square_w.c` — World/NPC/Quest
- `d/wutang/npc/apprentice.c` — World/NPC/Quest
- `d/wutang/npc/big_boar.c` — World/NPC/Quest
- `d/wutang/npc/boar.c` — World/NPC/Quest
- `d/wutang/npc/fisher.c` — World/NPC/Quest
- `d/wutang/npc/guard.c` — World/NPC/Quest
- `d/wutang/npc/guo_boo.c` — World/NPC/Quest
- `d/wutang/npc/huang.c` — World/NPC/Quest
- `d/wutang/npc/huyen_guan.c` — World/NPC/Quest
- `d/wutang/npc/jeweller.c` — World/NPC/Quest
- `d/wutang/npc/keeper.c` — World/NPC/Quest
- `d/wutang/npc/lee_shan.c` — World/NPC/Quest
- `d/wutang/npc/lu_estimator.c` — World/NPC/Quest
- `d/wutang/npc/may_yin_fong.c` — World/NPC/Quest
- `d/wutang/npc/old_fire.c` — World/NPC/Quest
- `d/wutang/npc/oldman.c` — World/NPC/Quest
- `d/wutang/npc/red_taoist.c` — World/NPC/Quest
- `d/wutang/npc/ro.c` — World/NPC/Quest
- `d/wutang/npc/royalist.c` — World/NPC/Quest
- `d/wutang/npc/seller.c` — World/NPC/Quest
- `d/wutang/npc/sheep.c` — World/NPC/Quest
- `d/wutang/npc/shepherd.c` — World/NPC/Quest
- `d/wutang/npc/smoke_fisher.c` — World/NPC/Quest
- `d/wutang/npc/tao.c` — World/NPC/Quest
- `d/wutang/npc/town_god.c` — World/NPC/Quest
- `d/wutang/npc/waiter.c` — World/NPC/Quest
- `d/wutang/npc/white_taoist.c` — World/NPC/Quest
- `d/wutang/npc/yaesae.c` — World/NPC/Quest
- `d/wutang/npc/yang_zlin.c` — World/NPC/Quest
- `d/wutang/npc/young_gentleman.c` — World/NPC/Quest
- `d/wutang/npc/young_man.c` — World/NPC/Quest
- `d/wutang/npc/young_scholar.c` — World/NPC/Quest
- `d/wutang/npc/yung_tai.c` — World/NPC/Quest
- `d/wutang/three_way.c` — World/NPC/Quest
- `daemon/class/commoner.c` — Classes
- `daemon/class/taoist.c` — Classes
- `daemon/race/ashura.c` — Races
- `daemon/race/avatar.c` — Races
- `daemon/race/headless/dance.c` — Races
- `daemon/race/human.c` — Races
- `daemon/race/yaksa/devour.c` — Races
- `daemon/race/yenhold/breathe.c` — Races
- `daemon/skill/archaic_attainment.c` — Skills
- `daemon/skill/hainmay_force.c` — Skills
- `daemon/skill/literate.c` — Skills
- `daemon/skill/seven.c` — Skills
- `daemon/skill/taoism-spells.c` — Skills
- `daemon/skill/tiger-blade.c` — Skills
- `feature/char/combat.c` — Shared/Core
- `feature/char/message.c` — Shared/Core
- `feature/char/score.c` — Shared/Core
- `feature/char/skill.c` — Shared/Core
- `feature/equip.c` — Shared/Core
- `feature/npc/vendor.c` — Shared/Core
- `feature/save.c` — Shared/Core
- `feature/study.c` — Shared/Core
- `feature/user/edit.c` — Shared/Core
- `feature/user/input.c` — Shared/Core
- `feature/user/more.c` — Shared/Core
- `include/daemon.h` — Shared/Core
- `obj/area/obj/bastardsword.c` — Items/Equipment
- `obj/area/obj/blade.c` — Items/Equipment
- `obj/area/obj/broadaxe.c` — Items/Equipment
- `obj/area/obj/broadsword.c` — Items/Equipment
- `obj/area/obj/cloth.c` — Items/Equipment
- `obj/area/obj/curved_blade.c` — Items/Equipment
- `obj/area/obj/dagger.c` — Items/Equipment
- `obj/area/obj/glaive.c` — Items/Equipment
- `obj/area/obj/greatsword.c` — Items/Equipment
- `obj/area/obj/longsword.c` — Items/Equipment
- `obj/area/obj/pike.c` — Items/Equipment
- `obj/area/obj/rod.c` — Items/Equipment
- `obj/area/obj/shortsword.c` — Items/Equipment
- `obj/area/obj/weirblade.c` — Items/Equipment
- `obj/books/compendium_of_translations.c` — Items/Equipment
- `obj/books/simple_guide_to_words.c` — Items/Equipment
- `obj/books/treatise_on_words.c` — Items/Equipment
- `obj/books/verses_of_the_thirteen_spirits.c` — Items/Equipment
- `obj/books/yin_yang_canon.c` — Items/Equipment
- `std/bboard.c` — Shared/Core
- `std/char/npc.c` — Shared/Core
- `std/item/container.c` — Shared/Core
- `std/martial_art.c` — Shared/Core
- `std/room/hockshop.c` — Shared/Core

## Snapshot-only paths — preserve and review

- `d/lee/ES2M_SOURCE_MANIFEST.json` — World/NPC/Quest
- `d/lee/obj/bronze_furnace.c` — World/NPC/Quest
- `d/lee/obj/bronze_reactor.c` — World/NPC/Quest
- `d/lee/obj/firewood.c` — World/NPC/Quest
- `daemon/skill/sanmeendo.c` — Skills
- `daemon/skill/tiger-force.c` — Skills
- `obj/drug/black_pill.c` — Items/Equipment
- `obj/medication/alchemist/aquapill.c` — Items/Equipment
- `obj/medication/alchemist/black_pill.c` — Items/Equipment
- `obj/medication/alchemist/green_pill.c` — Items/Equipment
- `obj/medication/alchemist/major_heal_pill.c` — Items/Equipment
- `obj/medication/alchemist/minor_heal_pill.c` — Items/Equipment
- `obj/medication/alchemist/mix_recipe.c` — Items/Equipment
- `obj/medication/alchemist/mjp_1.c` — Items/Equipment
- `obj/medication/alchemist/mjp_2.c` — Items/Equipment
- `obj/medication/alchemist/mjp_3.c` — Items/Equipment
- `obj/medication/alchemist/refresh_pill.c` — Items/Equipment
- `obj/medication/black_pill.c` — Items/Equipment

## Runtime overlay boundary

The path `es2_king_expansion/runtime/mudlib/` is the KING overlay, **not the assembled Docker runtime**. It has 100 files; 34 paths overlap the latest source mirror, with 23 same-path content conflicts and 66 overlay-only paths. This inventory alone cannot establish final runtime completeness or compatibility.

## Import decision

- **PASS — source mirror exists:** manifest pins upstream commit above and declares 1791 source files.
- **PASS — structural diff calculated:** 940 identical paths, 184 content conflicts, 667 latest-source-only paths, 18 snapshot-only paths.
- **BLOCKED — blanket runtime overwrite:** no direct bulk overwrite of the KING overlay or assembled runtime. This report is a file-level triage inventory; each candidate still needs dependency closure, target-source compatibility, and the targeted test specified in `docs/migration/ES2M_CONTENT_IMPORT_GATE_20261001.md`.
- **NOT RUN — LPC Driver/E2E:** no claim of game-runtime pass.
- **NOT RUN — deployment:** no Render/Docker production deploy was initiated.
- PR #13 remains OPEN / NOT MERGED.

## Next batch order

1. Review the 109 world/NPC/quest same-path conflicts first; prioritize zones with complete room-exit and NPC dependency closure.
2. Review the 86 latest-source-only world/NPC/quest paths for candidates that are absent from the existing snapshot.
3. Then evaluate items/equipment and skills; keep shared/core, race, and class conflicts blocked until dependency and Original ES2/KING overlay impact are checked.
4. Produce candidate CSV with the required gate fields, classify each as `IMPORT`, `REFERENCE_ONLY`, `BLOCKED`, or `ALREADY_PRESENT`, then import only rows that pass the gate.

*Blob SHA comparison is structural Git tree evidence. It is not an independently recomputed SHA-256 verification of all source bytes and is not a gameplay test.*
