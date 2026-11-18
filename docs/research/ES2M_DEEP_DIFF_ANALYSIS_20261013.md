# ES2M vs ES2-KING 深層差異分析（2026-10-13）

## 1. 比對基準與限制

- ES2M 來源：`wolfer168/es2-webmud`，固定 commit `ee12e717e2d3d88728607a01c2c2f1d634bf9616`。
- KING 比對快照：`yilin1201/ES2-KING-MUD`，本次讀取分支 `build/original-es2-races-phase2`，Tree commit `06eae192ada5bd0cb999c5143e57b27ffc4affdf`。
- ES2M 原始 Mudlib 檔案：1482。
- KING 工作快照檔案：1142。
- 方法：先以相對路徑與 Git Blob SHA 做機器比對；SHA 相同可確認內容完全一致；SHA 不同僅能確認內容不同，仍需讀取實際差異判定原因。
- 這份報告是差異分析，不表示全部缺少檔案都應放入 runtime，也不表示不同檔案都應以 ES2M 覆蓋 KING。

## 2. 總體結果

| 分類 | 數量 | 判定 |
|---|---:|---|
| 路徑相同、Blob SHA 相同 | 998 | 已確認內容完全一致 |
| 路徑相同、Blob SHA 不同 | 143 | 有差異，須分類後決定保留哪一版 |
| ES2M 有、KING 快照缺少 | 341 | 原始來源缺項；應先進原始鏡像，是否導入 runtime 另判 |
| KING 快照額外檔案 | 1 | 應確認為來源標記、KING 擴充或暫存檔 |
| 尚待確認的項目總數 | 485 | 143 + 341 + 1 |

## 3. 內容不同檔案：按目錄列出

這一類目前共 143 個。以下目錄分類是依路徑作初步風險分類，不把路徑分類誤稱為已完成語意驗證。

### `adm/daemons/`（1 個）
- `adm/daemons/combatd.c`

### `custom/home/`（2 個）
- `custom/home/npc/butler.c`
- `custom/home/obj/storage_chest.c`

### `custom/taoism/`（4 個）
- `custom/taoism/npc/fire_taoist.c`
- `custom/taoism/npc/freeze_taoist.c`
- `custom/taoism/npc/storm_taoist.c`
- `custom/taoism/npc/thunder_taoist.c`

### `custom/weapon/`（3 個）
- `custom/weapon/staff/long_staff.c`
- `custom/weapon/staff/zenstaff.c`
- `custom/weapon/whip/bamboo_fishing_rod.c`

### `custom/zhenwu/`（6 個）
- `custom/zhenwu/npc/lu_xinien.c`
- `custom/zhenwu/npc/mee_pei.c`
- `custom/zhenwu/npc/soldier.c`
- `custom/zhenwu/npc/target_stake.c`
- `custom/zhenwu/npc/zhenwu_soldier.c`
- `custom/zhenwu/obj/recruit_stone.c`

### `d/lee/`（27 個）
- `d/lee/LEE_TOPOLOGY.json`
- `d/lee/creek.c`
- `d/lee/inn.c`
- `d/lee/npc/child.c`
- `d/lee/npc/farmer.c`
- `d/lee/npc/guard.c`
- `d/lee/npc/hawthorn_seller.c`
- `d/lee/npc/herb_boy.c`
- `d/lee/npc/hunter.c`
- `d/lee/npc/lee_hsu_hsien.c`
- `d/lee/npc/lee_xiao_tian.c`
- `d/lee/npc/lee_yen.c`
- `d/lee/npc/lee_yong.c`
- `d/lee/npc/lee_zhong.c`
- `d/lee/npc/li_ban_xian.c`
- `d/lee/npc/nee_cheng.c`
- `d/lee/npc/teacher.c`
- `d/lee/npc/traveller.c`
- `d/lee/npc/waiter.c`
- `d/lee/npc/woman.c`
- `d/lee/obj/brow_staff.c`
- `d/lee/obj/waterskin.c`
- `d/lee/pawnshop.c`
- `d/lee/square_c.c`
- `d/lee/square_s.c`
- `d/lee/watermelon_n1.c`
- `d/lee/watermelon_s3.c`

### `d/oldpine/`（18 個）
- `d/oldpine/cave_deep.c`
- `d/oldpine/npc/bandit.c`
- `d/oldpine/npc/bandit_minion.c`
- `d/oldpine/npc/big_bear.c`
- `d/oldpine/npc/da_guan.c`
- `d/oldpine/npc/deer.c`
- `d/oldpine/npc/herbalist.c`
- `d/oldpine/npc/injured_traveller.c`
- `d/oldpine/npc/kao_shen.c`
- `d/oldpine/npc/lin_yuchan.c`
- `d/oldpine/npc/little_bear.c`
- `d/oldpine/npc/rat.c`
- `d/oldpine/npc/seller.c`
- `d/oldpine/npc/squirrel.c`
- `d/oldpine/npc/waiter.c`
- `d/oldpine/npc/wild_bear.c`
- `d/oldpine/npc/wolf.c`
- `d/oldpine/npc/xue_biao.c`

### `d/snow/`（24 個）
- `d/snow/inn_hall.c`
- `d/snow/npc/alchemist.c`
- `d/snow/npc/child.c`
- `d/snow/npc/child1.c`
- `d/snow/npc/child2.c`
- `d/snow/npc/child3.c`
- `d/snow/npc/child4.c`
- `d/snow/npc/foreman.c`
- `d/snow/npc/gammer.c`
- `d/snow/npc/garrison.c`
- `d/snow/npc/girl.c`
- `d/snow/npc/guard.c`
- `d/snow/npc/herbalist.c`
- `d/snow/npc/innkeeper.c`
- `d/snow/npc/junkman.c`
- `d/snow/npc/lieutenant.c`
- `d/snow/npc/miller.c`
- `d/snow/npc/oldman.c`
- `d/snow/npc/patrol.c`
- `d/snow/npc/smith.c`
- `d/snow/npc/woman.c`
- `d/snow/npc/yu.c`
- `d/snow/skill/dragon_force.c`
- `d/snow/square_w.c`

### `d/wutang/`（30 個）
- `d/wutang/npc/apprentice.c`
- `d/wutang/npc/big_boar.c`
- `d/wutang/npc/boar.c`
- `d/wutang/npc/fisher.c`
- `d/wutang/npc/guard.c`
- `d/wutang/npc/guo_boo.c`
- `d/wutang/npc/huang.c`
- `d/wutang/npc/huyen_guan.c`
- `d/wutang/npc/jeweller.c`
- `d/wutang/npc/keeper.c`
- `d/wutang/npc/lee_shan.c`
- `d/wutang/npc/lu_estimator.c`
- `d/wutang/npc/old_fire.c`
- `d/wutang/npc/oldman.c`
- `d/wutang/npc/red_taoist.c`
- `d/wutang/npc/ro.c`
- `d/wutang/npc/royalist.c`
- `d/wutang/npc/seller.c`
- `d/wutang/npc/sheep.c`
- `d/wutang/npc/shepherd.c`
- `d/wutang/npc/smoke_fisher.c`
- `d/wutang/npc/tao.c`
- `d/wutang/npc/waiter.c`
- `d/wutang/npc/white_taoist.c`
- `d/wutang/npc/yaesae.c`
- `d/wutang/npc/yang_zlin.c`
- `d/wutang/npc/young_gentleman.c`
- `d/wutang/npc/young_man.c`
- `d/wutang/npc/young_scholar.c`
- `d/wutang/npc/yung_tai.c`

### `daemon/race/`（3 個）
- `daemon/race/avatar.c`
- `daemon/race/human.c`
- `daemon/race/yenhold/breathe.c`

### `daemon/skill/`（4 個）
- `daemon/skill/sanmeendo.c`
- `daemon/skill/taoism-spells.c`
- `daemon/skill/tiger-blade.c`
- `daemon/skill/tiger-force.c`

### `feature/char/`（1 個）
- `feature/char/combat.c`

### `feature/equip.c/`（1 個）
- `feature/equip.c`

### `feature/study.c/`（1 個）
- `feature/study.c`

### `feature/user/`（2 個）
- `feature/user/edit.c`
- `feature/user/more.c`

### `obj/area/`（14 個）
- `obj/area/obj/bastardsword.c`
- `obj/area/obj/blade.c`
- `obj/area/obj/broadaxe.c`
- `obj/area/obj/broadsword.c`
- `obj/area/obj/cloth.c`
- `obj/area/obj/curved_blade.c`
- `obj/area/obj/dagger.c`
- `obj/area/obj/glaive.c`
- `obj/area/obj/greatsword.c`
- `obj/area/obj/longsword.c`
- `obj/area/obj/pike.c`
- `obj/area/obj/rod.c`
- `obj/area/obj/shortsword.c`
- `obj/area/obj/weirblade.c`

### `std/bboard.c/`（1 個）
- `std/bboard.c`

### `std/item/`（1 個）
- `std/item/container.c`

## 4. 已讀取內容的代表性差異與判定

### 4.1 李家村地圖：存在明確的路徑修復與 NPC 調整

- `d/lee/creek.c`：ES2M 原始出口為 `west → watermelon_n3`，KING 快照改為 `west → watermelon_s3`。這是實際程式差異；是否採用須以已確認的 `LEE_TOPOLOGY.json` 地圖拓樸及對應房間出口交叉驗證，不能單靠 SHA 判定。
- `d/lee/square_s.c`：KING 快照新增 `south → pawnshop`；ES2M 原始檔未含該出口。這屬拓樸修復候選，應保留為 KING 快照修復，不能宣稱原始 ES2M LPC 已經包含它。
- `d/lee/watermelon_n1.c`：KING 快照新增 `west → square_c`；原始 ES2M LPC 未含此出口。應以地圖拓樸驗證後保留修復紀錄。
- `d/lee/LEE_TOPOLOGY.json`：KING 版本新增來源政策、狀態與重建內容；同時包含使用者指定的醫館／通道等 KING 重建資訊，並非原始 ES2M 檔案的逐位複製。此檔應作為「KING 拓樸／重建規格」，另存來源原版，不應用 KING 版本反向覆蓋來源鏡像。
- `d/lee/inn.c`：樣本差異顯示 ES2M 原始檔含 `set("no_fight", 1);`，KING 快照缺少此行。這可能改變房間是否允許戰鬥，屬於必須查明的行為差異。
- 李家村多個 NPC（例如 `child.c`、`farmer.c`、`guard.c`、`herb_boy.c`、`lee_xiao_tian.c`）存在等級、屬性、Stat maximum、技能、職業或力量等設定差異。這些不能直接視為無害格式差異，需用 NPC 定位、任務／戰鬥用途及 runtime 測試逐項決定。

### 4.2 種族與技能：原始設定和 KING 擴充不可混為一談

- `daemon/race/avatar.c`：KING 快照的檔頭明確標註依使用者種族設定表進行 WebMUD 種族重平衡；這是 KING 擴充／重平衡來源標記，不能當成 Original ES2 已確認設定。需要把原始 ES2M 版保存在來源鏡像，KING 版另作差異版本。
- `daemon/skill/sanmeendo.c`：ES2M 原始版本標頭描述新版武功寫法，快照卻呈現舊式 `inherit SKILL;` 與招式 mapping，行數也明顯不同。這是高風險的實作世代差異；應先確認 KING 目前技能 runtime 所期待的介面，再決定採用原版或保留相容轉接，不可直接覆蓋。
- `custom/zhenwu/npc/lu_xinien.c`：差異涉及等級設定及後續程式區段，需逐段確認是否為 KING 行為修正或不慎遺失。
- `custom/taoism/npc/fire_taoist.c`：KING 快照加入屬性及最大數值設定，改變 NPC 數值配置；需以 KING 的角色數值規則及測試決定是否保留。

### 4.3 輸入處理：可能是功能／安全相容差異

- `feature/user/edit.c`：ES2M 原始版本有 `line == "webhud"` 的特別處理；KING 快照的對應區段不同。這可能影響 WebHUD 背景狀態訊息是否被誤寫進玩家編輯內容，應優先確認呼叫端與測試覆蓋。

## 5. ES2M 有、KING 快照缺少的檔案（341 個）

這些檔案尚未出現在 `es2m_snapshot/mudlib/`。**對「完整搬移原始資料」而言，應先逐位複製到獨立的 `es2m_source_mirror/mudlib/`；對遊戲 runtime 而言，不能不經依賴與相容性分析就全部啟用。**

### `adm/daemons/`（19 個）
- `adm/daemons/README`
- `adm/daemons/aliasd.c`
- `adm/daemons/channeld.c`
- `adm/daemons/chard.c`
- `adm/daemons/chinesed.c`
- `adm/daemons/cmd_d.c`
- `adm/daemons/daemond.c`
- `adm/daemons/emoted.c`
- `adm/daemons/enhanced.c`
- `adm/daemons/enterd.c`
- `adm/daemons/fingerd.c`
- `adm/daemons/httpd.c`
- `adm/daemons/logind.c`
- `adm/daemons/natured.c`
- `adm/daemons/profiled.c`
- `adm/daemons/securityd.c`
- `adm/daemons/smtpd.c`
- `adm/daemons/userid.c`
- `adm/daemons/virtuald.c`

### `adm/etc/`（4 個）
- `adm/etc/motd`
- `adm/etc/nature/day_phase`
- `adm/etc/preload`
- `adm/etc/welcome`

### `adm/guild/`（4 個）
- `adm/guild/academy.c`
- `adm/guild/guildhall.c`
- `adm/guild/meetingroom.c`
- `adm/guild/portal.c`

### `adm/intermud/`（4 個）
- `adm/intermud/_gchannel.c`
- `adm/intermud/_mudlist.c`
- `adm/intermud/_ping.c`
- `adm/intermud/i2d.c`

### `adm/obj/`（3 個）
- `adm/obj/mailbox.c`
- `adm/obj/master.c`
- `adm/obj/simul_efun.c`

### `adm/README.md/`（1 個）
- `adm/README.md`

### `adm/simul_efun/`（9 個）
- `adm/simul_efun/atoi.c`
- `adm/simul_efun/chinese.c`
- `adm/simul_efun/cursor.c`
- `adm/simul_efun/file.c`
- `adm/simul_efun/gender.c`
- `adm/simul_efun/message.c`
- `adm/simul_efun/object.c`
- `adm/simul_efun/path.c`
- `adm/simul_efun/wizard.c`

### `AGENTS.md/`（1 個）
- `AGENTS.md`

### `cmds/adm/`（9 個）
- `cmds/adm/chpass.c`
- `cmds/adm/disassemble.c`
- `cmds/adm/dump.c`
- `cmds/adm/profile.c`
- `cmds/adm/renew.c`
- `cmds/adm/restart.c`
- `cmds/adm/resurrect.c`
- `cmds/adm/shutdown.c`
- `cmds/adm/socket.c`

### `cmds/arch/`（15 個）
- `cmds/arch/callouts.c`
- `cmds/arch/chinese.c`
- `cmds/arch/cleanup.c`
- `cmds/arch/force.c`
- `cmds/arch/heal.c`
- `cmds/arch/overview.c`
- `cmds/arch/possess.c`
- `cmds/arch/promote.c`
- `cmds/arch/purge.c`
- `cmds/arch/reboot.c`
- `cmds/arch/reclaim.c`
- `cmds/arch/rehash.c`
- `cmds/arch/reset_okip.c`
- `cmds/arch/restore.c`
- `cmds/arch/wizlock.c`

### `cmds/imm/`（11 個）
- `cmds/imm/cd.c`
- `cmds/imm/delink.c`
- `cmds/imm/edemote.c`
- `cmds/imm/goto.c`
- `cmds/imm/ls.c`
- `cmds/imm/mem.c`
- `cmds/imm/more.c`
- `cmds/imm/pwd.c`
- `cmds/imm/status.c`
- `cmds/imm/where.c`
- `cmds/imm/which.c`

### `cmds/README.md/`（1 個）
- `cmds/README.md`

### `cmds/std/`（54 個）
- `cmds/std/README`
- `cmds/std/acquire.c`
- `cmds/std/acupuncture.c`
- `cmds/std/apprentice.c`
- `cmds/std/ask.c`
- `cmds/std/backstab.c`
- `cmds/std/balance.c`
- `cmds/std/berserk.c`
- `cmds/std/cast.c`
- `cmds/std/ccmd.c`
- `cmds/std/cestablish.c`
- `cmds/std/charge.c`
- `cmds/std/close.c`
- `cmds/std/conjure.c`
- `cmds/std/convert.c`
- `cmds/std/deposit.c`
- `cmds/std/drink.c`
- `cmds/std/drop.c`
- `cmds/std/eat.c`
- `cmds/std/emote.c`
- `cmds/std/enter.c`
- `cmds/std/exert.c`
- `cmds/std/fight.c`
- `cmds/std/fill.c`
- `cmds/std/follow.c`
- `cmds/std/get.c`
- `cmds/std/give.c`
- `cmds/std/go.c`
- `cmds/std/guard.c`
- `cmds/std/halt.c`
- `cmds/std/identify.c`
- `cmds/std/ignore.c`
- `cmds/std/kill.c`
- `cmds/std/lock.c`
- `cmds/std/look.c`
- `cmds/std/open.c`
- `cmds/std/perform.c`
- `cmds/std/put.c`
- `cmds/std/remove.c`
- `cmds/std/reply.c`
- `cmds/std/say.c`
- `cmds/std/search.c`
- `cmds/std/shout.c`
- `cmds/std/steal.c`
- `cmds/std/study.c`
- `cmds/std/suicide.c`
- `cmds/std/team.c`
- `cmds/std/tell.c`
- `cmds/std/unlock.c`
- `cmds/std/unwield.c`
- `cmds/std/wear.c`
- `cmds/std/whisper.c`
- `cmds/std/wield.c`
- `cmds/std/withdraw.c`

### `cmds/usr/`（34 個）
- `cmds/usr/alias.c`
- `cmds/usr/backup.c`
- `cmds/usr/chfn.c`
- `cmds/usr/describe.c`
- `cmds/usr/estimate.c`
- `cmds/usr/finger.c`
- `cmds/usr/help.c`
- `cmds/usr/hp.c`
- `cmds/usr/id.c`
- `cmds/usr/inventory.c`
- `cmds/usr/keep.c`
- `cmds/usr/localtime.c`
- `cmds/usr/nick.c`
- `cmds/usr/okip.c`
- `cmds/usr/option.c`
- `cmds/usr/order.c`
- `cmds/usr/passwd.c`
- `cmds/usr/praise.c`
- `cmds/usr/quit.c`
- `cmds/usr/recall.c`
- `cmds/usr/save.c`
- `cmds/usr/semote.c`
- `cmds/usr/skills.c`
- `cmds/usr/time.c`
- `cmds/usr/to.c`
- `cmds/usr/tune.c`
- `cmds/usr/undescribe.c`
- `cmds/usr/uptime.c`
- `cmds/usr/version.c`
- `cmds/usr/visitor.c`
- `cmds/usr/webhud.c`
- `cmds/usr/who.c`
- `cmds/usr/wimpy.c`
- `cmds/usr/wizlist.c`

### `cmds/wiz/`（33 個）
- `cmds/wiz/analyze.c`
- `cmds/wiz/arrest.c`
- `cmds/wiz/call.c`
- `cmds/wiz/cat.c`
- `cmds/wiz/clone.c`
- `cmds/wiz/cost.c`
- `cmds/wiz/cp.c`
- `cmds/wiz/daemon.c`
- `cmds/wiz/dest.c`
- `cmds/wiz/edit.c`
- `cmds/wiz/ff.c`
- `cmds/wiz/home.c`
- `cmds/wiz/ilist.c`
- `cmds/wiz/info.c`
- `cmds/wiz/invis.c`
- `cmds/wiz/link.c`
- `cmds/wiz/localcmds.c`
- `cmds/wiz/log.c`
- `cmds/wiz/mkdir.c`
- `cmds/wiz/mudlist.c`
- `cmds/wiz/mv.c`
- `cmds/wiz/ping.c`
- `cmds/wiz/qload.c`
- `cmds/wiz/quiet.c`
- `cmds/wiz/rm.c`
- `cmds/wiz/rmdir.c`
- `cmds/wiz/snoop.c`
- `cmds/wiz/summon.c`
- `cmds/wiz/tail.c`
- `cmds/wiz/ulist.c`
- `cmds/wiz/update.c`
- `cmds/wiz/userid.c`
- `cmds/wiz/whoami.c`

### `custom/condition/`（1 個）
- `custom/condition/weapon_poison.c`

### `custom/test/`（1 個）
- `custom/test/obj/infinite_100_gold.c`

### `custom/wizroom/`（7 個）
- `custom/wizroom/j/juys/aera/workroom.c.1789329689`
- `custom/wizroom/j/juys/aera/workroom.c.1789352435`
- `custom/wizroom/j/juys/aera/workroom.c.1789356197`
- `custom/wizroom/w/windstory/npc/gammer.c`
- `custom/wizroom/w/windstory/room/dragon_inn.c`
- `custom/wizroom/w/windstory/room/home.c`
- `custom/wizroom/w/windstory/room/inn_w.c`

### `daemon/board/`（3 個）
- `daemon/board/bug_board.c`
- `daemon/board/celestial_board.c`
- `daemon/board/snow_board.c`

### `daemon/condition/`（10 個）
- `daemon/condition/blue_venom.c`
- `daemon/condition/drunk.c`
- `daemon/condition/hundred_poison.c`
- `daemon/condition/maggot_poison.c`
- `daemon/condition/phoenix_poison.c`
- `daemon/condition/poison.c`
- `daemon/condition/rain_blessing.c`
- `daemon/condition/rain_poison.c`
- `daemon/condition/skull_heart_poison.c`
- `daemon/condition/wraith_poison.c`

### `daemon/misc/`（1 個）
- `daemon/misc/traveler.c`

### `daemon/race/`（3 個）
- `daemon/race/avatar/radiate.c`
- `daemon/race/beast.c`
- `daemon/race/human/resurge.c`

### `daemon/README.md/`（1 個）
- `daemon/README.md`

### `daemon/skill/`（3 個）
- `daemon/skill/berserk.c`
- `daemon/skill/heavy_parry.c`
- `daemon/skill/powerblow.c`

### `daemon/virtual/`（1 個）
- `daemon/virtual/field.c`

### `data/chinese.o/`（1 個）
- `data/chinese.o`

### `data/emoted.o/`（1 個）
- `data/emoted.o`

### `data/mail/`（1 個）
- `data/mail/.keep`

### `data/README.md/`（1 個）
- `data/README.md`

### `docs/help/`（22 個）
- `docs/help/character.txt`
- `docs/help/combat.txt`
- `docs/help/combat_cmds.txt`
- `docs/help/commands.txt`
- `docs/help/communication.txt`
- `docs/help/death.txt`
- `docs/help/home_help.txt`
- `docs/help/inn.txt`
- `docs/help/items.txt`
- `docs/help/master.txt`
- `docs/help/movement.txt`
- `docs/help/newbie.txt`
- `docs/help/recall.txt`
- `docs/help/rules.txt`
- `docs/help/skill_help.txt`
- `docs/help/snowkeep.txt`
- `docs/help/tiger.txt`
- `docs/help/topics.txt`
- `docs/help/web.txt`
- `docs/help/wizard_help.txt`
- `docs/help/world.txt`
- `docs/help/zmud.txt`

### `feature/README.md/`（1 個）
- `feature/README.md`

### `include/action.h/`（1 個）
- `include/action.h`

### `include/ansi.h/`（1 個）
- `include/ansi.h`

### `include/armor.h/`（1 個）
- `include/armor.h`

### `include/attack.h/`（1 個）
- `include/attack.h`

### `include/attribute.h/`（1 個）
- `include/attribute.h`

### `include/char.h/`（1 個）
- `include/char.h`

### `include/combat.h/`（1 個）
- `include/combat.h`

### `include/command.h/`（1 個）
- `include/command.h`

### `include/condition.h/`（1 個）
- `include/condition.h`

### `include/dbase_security.h/`（1 個）
- `include/dbase_security.h`

### `include/dbase.h/`（1 個）
- `include/dbase.h`

### `include/explore.h/`（1 個）
- `include/explore.h`

### `include/function.h/`（1 個）
- `include/function.h`

### `include/globals.h/`（1 個）
- `include/globals.h`

### `include/help.h/`（1 個）
- `include/help.h`

### `include/html.h/`（1 個）
- `include/html.h`

### `include/http.h/`（1 個）
- `include/http.h`

### `include/intermud.h/`（1 個）
- `include/intermud.h`

### `include/localtime.h/`（1 個）
- `include/localtime.h`

### `include/login.h/`（1 個）
- `include/login.h`

### `include/move.h/`（1 個）
- `include/move.h`

### `include/mudlib.h/`（1 個）
- `include/mudlib.h`

### `include/name.h/`（1 個）
- `include/name.h`

### `include/npc.h/`（1 個）
- `include/npc.h`

### `include/obj.h/`（1 個）
- `include/obj.h`

### `include/origin.h/`（1 個）
- `include/origin.h`

### `include/race.h/`（1 個）
- `include/race.h`

### `include/reboot.h/`（1 個）
- `include/reboot.h`

### `include/room.h/`（1 個）
- `include/room.h`

### `include/runtime_config.h/`（1 個）
- `include/runtime_config.h`

### `include/score.h/`（1 個）
- `include/score.h`

### `include/skill.h/`（1 個）
- `include/skill.h`

### `include/socket_err.h/`（1 個）
- `include/socket_err.h`

### `include/statistic.h/`（1 個）
- `include/statistic.h`

### `include/team.h/`（1 個）
- `include/team.h`

### `include/type.h/`（1 個）
- `include/type.h`

### `include/user.h/`（1 個）
- `include/user.h`

### `include/weapon.h/`（1 個）
- `include/weapon.h`

### `obj/armor/`（2 個）
- `obj/armor/cloth.c`
- `obj/armor/fur_hat.c`

### `obj/bankbond.c/`（1 個）
- `obj/bankbond.c`

### `obj/block_robot.c/`（1 個）
- `obj/block_robot.c`

### `obj/block.c/`（1 個）
- `obj/block.c`

### `obj/bottle.c/`（1 個）
- `obj/bottle.c`

### `obj/clan_symbol.c/`（1 個）
- `obj/clan_symbol.c`

### `obj/cloth.c/`（1 個）
- `obj/cloth.c`

### `obj/corpse.c/`（1 個）
- `obj/corpse.c`

### `obj/dust.c/`（1 個）
- `obj/dust.c`

### `obj/example/`（6 個）
- `obj/example/README`
- `obj/example/army.c`
- `obj/example/daemon/README`
- `obj/example/es2_bottle.c`
- `obj/example/infantry.c`
- `obj/example/weapon/shortsword.c`

### `obj/http.c/`（1 個）
- `obj/http.c`

### `obj/login.c/`（1 個）
- `obj/login.c`

### `obj/magic.c/`（1 個）
- `obj/magic.c`

### `obj/map.c/`（1 個）
- `obj/map.c`

### `obj/obj/`（2 個）
- `obj/obj/firework.c`
- `obj/obj/ghostbaby.c`

### `obj/README.md/`（1 個）
- `obj/README.md`

### `obj/roommaker.c/`（1 個）
- `obj/roommaker.c`

### `obj/spirit.c/`（1 個）
- `obj/spirit.c`

### `obj/user.c/`（1 個）
- `obj/user.c`

### `obj/void.c/`（1 個）
- `obj/void.c`

### `obj/water.c/`（1 個）
- `obj/water.c`

### `README.md/`（1 個）
- `README.md`

### `std/char.c/`（1 個）
- `std/char.c`

### `std/condition.c/`（1 個）
- `std/condition.c`

### `std/item.c/`（1 個）
- `std/item.c`

### `std/money.c/`（1 個）
- `std/money.c`

### `std/race/`（2 個）
- `std/race/README`
- `std/race/humanoid.c`

### `std/README.md/`（1 個）
- `std/README.md`

### `std/room/`（6 個）
- `std/room/bank.c`
- `std/room/hockshop_storage.c`
- `std/room/inn.c`
- `std/room/journey.c`
- `std/room/obj/pawn_stamp.c`
- `std/room/temple.c`

### `std/skill.c/`（1 個）
- `std/skill.c`

## 6. KING 快照額外檔案

- `d/lee/ES2M_SOURCE_MANIFEST.json`：不在來源相同相對路徑清單；需判斷它是 KING 的來源清冊／標記，還是應搬至鏡像之外的專案管理資料。

## 7. 優先處理順序

1. **P0 原始鏡像完整性**：以固定 ES2M commit 將全部來源檔案放入獨立鏡像，逐檔驗證 SHA-256；不將來源鏡像直接作為 runtime overlay。
2. **P1 地圖連通性**：先完成 `d/lee` 的拓樸與每個 LPC 房間出口對照，對每項修復留下來源出口、拓樸預期、KING 修正及測試證據。
3. **P1 runtime／技能介面**：優先確認 `feature/user/edit.c`、`daemon/skill/sanmeendo.c`、`daemon/race/*` 的差異，避免功能退化或錯誤覆蓋。
4. **P2 NPC 與地圖區域數值**：逐檔審查 `d/lee`、`d/snow`、`d/wutang`、`d/oldpine`、`obj/area` 的數值、出口、任務與物件行為。
5. **P3 其餘差異**：完成所有 143 個檔案的語意差異審查；對沒有證據可判斷的檔案明確標記 UNKNOWN，不以猜測判定。

## 8. 尚未完成／不得宣稱的事項

- 目前完成的是全路徑與 Blob SHA 初比對，以及本報告列出的代表性內容抽查；143 個差異尚未逐一完成語意審查。
- 341 個缺少檔案尚未全部搬入原始鏡像。
- 目前鏡像只有已提交的少量檔案，不能宣稱 1,482 個檔案已完整鏡像。
- 本階段沒有執行完整 runtime 或遊戲 E2E 測試；不宣稱地圖、技能或任務已 PASS。
- 來源固定 commit 為 `ee12e717e2d3d88728607a01c2c2f1d634bf9616`；後續如 ES2M 上游更新，應另開新的比對批次，不能靜默改變本次基準。


## 9. 第二輪逐檔內容抽查（2026-10-13）

本輪直接讀取來源 Blob 與 KING 快照 Blob 內容，以下結論只適用於列出的檔案；其他同目錄檔案仍需逐檔檢查。

### 9.1 雪亭鎮（`d/snow`）

| 檔案 | 已觀察差異 | 初步風險／處理 |
|---|---|---|
| `d/snow/inn_hall.c` | ES2M 原始版載入 `/daemon/board/celestial_board`（天朝公告）；KING 快照對應位置沒有該載入呼叫。 | **功能差異，待驗證**：確認公告板是否由其他路徑載入；不能當成單純格式差異。 |
| `d/snow/npc/garrison.c` | 原始版設為 `soldier`、Lv.15；KING 快照改成 `commoner`、Lv.17，並加入不同屬性設定。 | **NPC 行為／平衡差異**：職業和等級已改，需檢查戰鬥行為、技能與區域定位。 |
| `d/snow/npc/innkeeper.c` | `set_class("commoner")` 在快照中缺少；周邊營業時間、移動邏輯仍存在，但程式行位移。 | **角色分類差異**：應確認類別是否影響對話、技能或 NPC AI。 |
| `d/snow/skill/dragon_force.c` | 原始版具有 `query_entry_level()`、`query_threshold_percent()`、`skill_completed()` 等介面；快照在相同位置出現 `skill_improved()` 與直接檢查技能／學習點數的邏輯。 | **高風險技能升級差異**：兩版的學習門檻／完成條件介面不同，需與技能 daemon 呼叫端及測試交叉比對，不能直接以檔案長度或行號決定新舊優劣。 |

### 9.2 武當區域（`d/wutang`）

| 檔案 | 已觀察差異 | 初步風險／處理 |
|---|---|---|
| `d/wutang/npc/apprentice.c` | 原始版有 `set_power("B")`；快照未見該設定，並加入 gin 的 maximum/effective/current 明確數值。 | **數值模型差異**：須確認 KING 的角色初始化是否以這些欄位取代 power 等級機制，避免生命／精力重複或互相覆蓋。 |
| `d/wutang/npc/guard.c` | 原始版 Lv.5，快照改 Lv.20；原始版有 blade 技能，快照改用其他技能並加入明確 stat 設定。 | **高風險戰鬥平衡差異**：不是註解或格式變動；需要以原始用途與 KING 目前區域難度標準確認。 |
| `d/wutang/npc/red_taoist.c` | 快照加入 gin/kee 的最大值、有效值及當前值；原始版主要依既有角色能力／power 設定。 | **角色數值初始化差異**：檢查這些欄位是否在 `setup()` 前後正確生效，並與現行 stat API 相容。 |

### 9.3 老松林區域（`d/oldpine`）

| 檔案 | 已觀察差異 | 初步風險／處理 |
|---|---|---|
| `d/oldpine/npc/bandit.c` | 原始版在初始化後裝備刀、皮背心並攜帶 5 枚銀幣；KING 快照相應位置加入 gin/kee 的 maximum/effective/current 設定。 | **裝備／掉落／數值風險**：需檢查裝備與銀幣程式是否仍存在於快照其他位置；若已移除，可能改變戰鬥與掉落行為。 |

### 9.4 通用區域武器／衣物物件（`obj/area/obj`）

| 檔案 | 已觀察差異 | 初步風險／處理 |
|---|---|---|
| `obj/area/obj/blade.c` | 原始版在物件 clone 時呼叫 `ENHANCE_D->roll_affix(this_object())`；快照改用 `varify_template(owner)` 內的 `ENHANCE_D->enhance_weapon(...)`，以 owner 等級計算強化值。 | **武器附加屬性系統差異**：兩版觸發時機與參數模型不同；須確認 daemon API、NPC 配裝及玩家取得武器路徑，不應覆蓋任一版。 |
| `obj/area/obj/longsword.c` | 與 `blade.c` 類似，原始版 clone 時擲附加屬性；快照依 owner 等級呼叫武器強化。 | **同類型系統差異**：需確認兩種流程是否重複強化或造成玩家／NPC 武器結果不一致。 |
| `obj/area/obj/cloth.c` | 原始版 `value=200`，KING 快照改成 `value=0`。 | **經濟行為差異**：可能影響出售價格／回收價值，需確認是否為 KING 的刻意平衡。 |

### 9.5 本輪判定摘要

- 本輪讀取 11 個檔案的來源版與快照版內容。
- 觀察到的差異不只文字格式；涵蓋公告板載入、NPC 職業／等級／技能、技能升級 API、角色 stat 初始化、武器附加屬性流程及物件價值。
- 上述內容全部先標記為 **DIFF CONFIRMED / SEMANTIC REVIEW REQUIRED**；沒有足夠 runtime 證據時，不將其升級為已確認缺陷，也不自動覆蓋。
- 下一輪建議優先核對 `ENHANCE_D` 呼叫端與 weapon lifecycle、`dragon_force` 的技能升級呼叫端、以及 NPC 初始化 API；這些屬於共用機制，風險高於單一房間文案差異。


## 10. 第三輪：共用戰鬥／裝備／學習核心檔案（2026-10-13）

本輪抽查 4 個共用核心檔案。因為這些檔案會影響多個區域或所有角色，應優先於單一 NPC 的數值差異處理。

### 10.1 `adm/daemons/combatd.c` — 招架經驗機制

來源版與快照版在 `restored_parry_gain()` 周邊的註解和程式段落不同；原始版保留「強力格擋額外取得招架點數」的說明，KING 快照此處換成 `defense_combat_gain()` 與 `improve_skill_exact("parry", ...)` 的邏輯。

- **差異確認：** 戰鬥經驗分配機制的實作不同。
- **風險：高。** 可能影響格擋／招架技能成長及既有玩家進度。
- **後續驗證：** 對照 `parry_gains_exp()`、`restored_defense_exp()`、`defense_combat_gain()` 的所有呼叫端及相關單元測試；以可重現戰鬥情境比較經驗增量。未驗證前不覆蓋。

### 10.2 `feature/char/combat.c` — 角色戰鬥核心

來源版與快照版在 `absorb()` 等戰鬥函式附近有明顯段落差異，快照檔案比來源版少 45 行。

- **差異確認：** 不是單純檔頭／註解變動，戰鬥函式的程式結構有變化。
- **風險：高。** 涉及攻擊吸收、鬼魂狀態與戰鬥訊息等共用行為。
- **後續驗證：** 需使用結構化 diff 逐函式對照，檢查宣告、回傳路徑、生命型態判定、攻防結算及訊息回呼，並跑相關戰鬥測試。

### 10.3 `feature/equip.c` — 裝備傷害與重擊術經驗

來源版包含新增的重擊術經驗公式與繁體中文註解，使用 `random(1 + max_bonus)`、重擊術等級與膂力計算經驗；快照版對應位置是一般傷害計算流程，未見相同的公式區塊。

- **差異確認：** 兩版裝備／傷害路徑不一致。
- **風險：高。** 可能影響重擊術技能成長、武器傷害、雙持時的經驗判定。
- **後續驗證：** 先確認這段是否屬使用者近期已定案的 KING 規則，再以單手、雙持、不同重擊術等級與膂力測試經驗及傷害；不可用 Original ES2 覆蓋 KING 的已確認新增規則。

### 10.4 `feature/study.c` — 技能學習門檻

來源版的學習限制條件同時檢查技能等級及 `query_learn(skill) >= skill_threshold(skill, limit)`；快照版對應條件只看技能等級上限。

- **差異確認：** 學習停止／門檻條件不同。
- **風險：高。** 可能造成角色已累積學習點數達門檻時，仍可繼續學習，或造成學習流程與技能 daemon 規則不一致。
- **後續驗證：** 檢查 `skill_threshold()`、`query_learn()` 及學習流程的呼叫關係；測試技能上限、學習點數門檻、初學／高階技能及停止學習邊界。

### 10.5 本輪處置原則

這四個檔案屬於共用核心，不能直接以「來源版較原始」作為覆蓋依據。應保留來源原始鏡像與 KING 工作版本，逐函式建立差異、確認 KING 已定案功能，再以最小測試驗證。沒有測試證據前一律標記為 **DIFF CONFIRMED / RUNTIME VALIDATION PENDING**。


## 11. 第四輪：技能成長介面與依賴檔案交叉驗證（2026-10-13）

本輪不只比較單檔文字，而是將技能檔與角色技能核心的實際介面對照。檢查依據為固定 ES2M 來源 commit `ee12e717e2d3d88728607a01c2c2f1d634bf9616` 的 Blob，以及目前分支 `es2m_snapshot/mudlib/` 的實際檔案。

### 11.1 `d/snow/skill/dragon_force.c` 與 `feature/char/skill.c` — 技能升級介面不相容風險

- ES2M 來源版 `dragon_force.c` 提供 `query_entry_level()`、`query_threshold_percent()`、`skill_completed()`；KING 快照版則保留 `skill_improved()`，並自行檢查 `query_skill()`、`query_learn()` 及直接呼叫 `advance_skill()`。
- KING 快照的 `feature/char/skill.c` 已實作 `skill_entry_level()`，會透過 `SKILL_D(skill)` 查詢 `query_entry_level()`；`skill_threshold()` 會查詢 `query_threshold_percent()`；技能從 0 級學成時，升級核心會呼叫 `skill_completed()`（若技能檔有此函式）。
- **已確認的介面事實：** 快照版 `dragon_force.c` 未提供技能核心查詢的前兩個介面，也未提供學成回呼；因此龍圖心經不會透過這些介面宣告原始設定的學成等級／門檻，且無法由技能核心觸發原始版學成回呼。
- **風險：高。** 技能可能使用通用預設學成等級／門檻，與技能檔自行處理的舊式學習點數邏輯不一致；單靠檔案能編譯不能證明升級流程正確。
- **處置：** 不直接覆蓋技能檔。先決定 KING 要採用共用技能核心的新式介面，或保留舊式專用升級邏輯；若採新介面，需以最小修改補齊必要介面並移除重複升級路徑，再測試 0 級學成、學成門檻、40 級入門、120 級上限及精／氣／神上限獎勵。

### 11.2 `feature/study.c` — 已確認快照缺少共用技能門檻檢查

- KING 快照 `feature/char/skill.c` 有 `skill_threshold(skill, level)`，而且 `skill_threshold()` 會套用個別技能的門檻百分比與入門門檻；這證實技能學習點數門檻是目前角色技能系統的一部分，不是不存在的舊 API。
- 固定來源版 `feature/study.c` 的 `study_capped()` 會同時檢查 `query_skill(skill, 1) >= limit` 與 `query_learn(skill) >= skill_threshold(skill, limit)`；KING 快照版只檢查技能等級。
- **已確認的功能差異：** 讀書停止條件未與角色技能核心共用門檻保持一致。
- **風險：高。** 當技能等級尚未升到書本上限，但累積學習點數已達該上限門檻時，讀書流程可能繼續消耗神並增加學習點數，造成超額累積或延後停止。
- **處置：** 建議將此列為待修正候選，先新增邊界測試：技能等級低於上限且學習點數低於門檻、等於門檻、超過門檻，以及指定入門等級／折扣門檻的技能。測試通過後再以最小差異恢復雙條件。

### 11.3 `adm/daemons/combatd.c` 與缺少的技能 daemon — 強力格擋成長路徑

- 固定來源版 `combatd.c` 的 `restored_parry_gain()` 在基本招架經驗外，若角色學過 `heavy_parry`，會按定力與隨機比例另給 `heavy_parry` 經驗。
- KING 快照版的相同函式沒有這段額外經驗分配；目前快照清冊也沒有 `daemon/skill/heavy_parry.c`，而該檔列在 ES2M 有、快照缺少的檔案清單中。
- **已確認的差異：** 不只戰鬥 daemon 的經驗分配不同，技能 daemon 也缺檔；因此目前快照無法單靠原始來源所示路徑完整重現強力格擋成長機制。
- **風險：高。** 可能使角色已學得或預期可學的強力格擋無法按來源規則成長；是否在 KING 設計中刻意移除，仍待產品規則確認。
- **處置：** 先將來源 `heavy_parry.c` 放入隔離原始鏡像（不直接啟用），再確認技能註冊、可學習途徑、招架成功呼叫點與 KING 是否保留該技能。只有決定保留後，才做最小相容整合與實戰經驗測試。

### 11.4 `feature/equip.c`／`obj/area/obj/blade.c` — 必須保護已定案的 KING 重擊術與武器流程

- KING 快照 `feature/equip.c` 的重擊術觸發率以技能等級計算，並在觸發時呼叫 `improve_skill("powerblow", 1 + bonus/5)`；來源版則使用使用者已定案的公式：`random(1 + max_bonus) × (1 + powerblow 等級/20) × 膂力/5`，另有新版武功傷害百分比與免除防具計算的路徑。
- KING 快照 `blade.c` 在 `varify_template(owner)` 中依持有者等級呼叫 `ENHANCE_D->enhance_weapon(...)`；來源版在每次 clone 時呼叫 `ENHANCE_D->roll_affix(...)`，並明確註明 NPC 持有時不再另行強化。
- **判定：** 這些差異會影響 KING 的傷害、重擊術成長、武器詞綴產生時機及 NPC／玩家武器一致性；它們不是可以直接按原始版本回退的單純缺陷。依專案規則，保留已定案 KING 重擊術規則，另行比較詞綴系統的 API 與生命週期。
- **待驗證：** 單手與雙持觸發次數、重擊術 0／中／高等級、膂力低／高、玩家取得武器、NPC 配裝及重新載入／複製武器後是否重複強化。沒有測試結果前不標記 PASS。

### 11.5 本輪結論

- 技能核心交叉比對已將 `dragon_force.c` 與 `feature/study.c` 的差異由「檔案不同」提升為「與現行技能門檻／回呼介面存在具體不一致」。
- `heavy_parry` 是戰鬥呼叫邏輯與缺失技能檔的雙重缺項，應先隔離保存，再決定是否採用。
- `powerblow` 與武器詞綴流程涉及 KING 已定案規則，不做原始版直接覆蓋。
- 本輪為靜態原始碼交叉驗證，尚未執行 MUD runtime；以上不宣稱執行期 PASS。


## 12. 第五輪：玩家輸入、容器初始化與公告板差異（2026-10-13）

本輪檢查 `feature/user/edit.c`、`feature/user/more.c`、`std/item/container.c`、`std/bboard.c`。四個檔案都存在實際內容差異，以下依可從程式直接確認的行為描述，不把靜態分析當成 runtime 測試結果。

### 12.1 `feature/user/edit.c` — WebHUD 背景指令可能混入編輯內容

- 來源版對輸入行 `webhud` 有特別分支：不把它追加到編輯文字，註解明確指出它是網頁背景狀態查詢，不是玩家輸入的文章／信件內容。
- KING 快照沒有該分支，會走一般輸入處理並將該行追加到文字。
- **已確認的行為差異：** WebHUD 背景狀態查詢字串在編輯器等待輸入時，可能被寫入文章／信件內容。
- **風險：中高。** 影響編輯器資料品質，尤其是 WebMUD 背景輪詢與玩家同時編輯時。
- **建議：** 恢復來源版對 `webhud` 的排除邏輯，或以 KING 現行 WebHUD 協定實作等效的命令識別；新增測試確認普通文字仍可輸入、背景指令不會進入儲存內容。

### 12.2 `feature/user/more.c` — 分頁器對 WebHUD 指令的處理不同

- 來源版對 `webhud` 使用獨立分支：執行狀態查詢後再次註冊 `input_to("more", text, line)`，讓分頁停留在原處。
- KING 快照移除該分支，改為一般預設分支：先處理非空指令，再返回；不再重新註冊分頁輸入。
- **已確認的差異：** 背景狀態查詢期間，來源版會保留分頁等待狀態，KING 版則可能結束／解除目前分頁輸入。
- **風險：中。** 可能造成長文字分頁被背景查詢打斷，或改變後續按鍵的派送行為。
- **建議：** 與目前 WebMUD 的輪詢與 pager 輸入協定一起驗證；測試分頁中執行 `webhud`、一般命令、空輸入及下一頁操作，確認沒有命令遺失或重複派送。

### 12.3 `std/item/container.c` — 容器未呼叫父類別 `setup()`

- 來源版在設定預設出口前先呼叫 `::setup()`，並以繁體中文註解說明：必須先執行 ITEM 的 `setup()`，複製出的容器物件才能取得原型設定的單位、價值與說明；否則可能變成單位／價值為 0，丟在地上時被視為不值錢而消失。
- KING 快照在相同初始化區段只處理預設出口，未呼叫 `::setup()`。
- **已確認的初始化差異：** 容器複製物件沒有在此處執行來源版的父類別初始化。
- **風險：高。** 可能使容器物品的單位、價值、說明或其他 ITEM 原型設定未被正確初始化，並影響丟棄／物件清理行為。
- **建議：** 先檢查繼承鏈與所有呼叫 `setup()` 的時機，確認沒有其他等效初始化路徑；若無，恢復父類別初始化並增加 clone 測試，核對原型／複製物件的 unit、value、long 及丟棄後存活情況。此項應列入高優先修正候選，但在測試前不宣稱已修復。

### 12.4 `std/bboard.c` — 公告板「沒有未讀留言」訊息差異

- 來源版在玩家已讀完所有留言時，回覆「目前沒有新的留言，要重讀請用 read <編號>」；KING 快照改為「沒有未讀的留言了」。
- 兩版都保留留言編號解析、範圍檢查及留言內容顯示流程；此抽查可見的差異主要是已讀完時的提示文案與周邊顯示格式。
- **初步風險：低。** 目前沒有證據顯示這個差異改變公告板資料寫入或讀取索引；仍需確認使用者體驗是否符合 KING 的繁體中文文案標準。
- **處置：** 暫列為文案／互動差異，不因原始版不同就回退。若公告板自動化測試依賴固定訊息，應同步更新測試期望值或明確保留來源文案。

### 12.5 本輪結論與優先順序

1. **高優先：** `std/item/container.c` 父類別初始化缺失，先確認是否有其他等效初始化路徑。
2. **中高優先：** `feature/user/edit.c` 的 `webhud` 排除邏輯，避免背景命令污染玩家編輯內容。
3. **中優先：** `feature/user/more.c` 的分頁輸入保持行為，需以 WebMUD 輪詢情境驗證。
4. **低優先：** `std/bboard.c` 已讀完提示文案，確認互動與測試期望即可。

本輪只完成靜態來源／快照對照，未執行 MUD runtime；上述項目不標記為 Runtime PASS。
