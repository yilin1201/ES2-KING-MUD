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
