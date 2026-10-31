# Target Lost Source / Lifecycle Recovery — 2026-09-29

> Target baseline：`taedlar/es2_mudlib@cc45c06af4852380e5148dad3c9d53ff06854f2c`。外部 ES2-family Source 只作 lineage／compatibility cross-check；沒有閉合 Target dependency 的項目不得 Restoration。

## Recovery 結論

| Target | Direct Target evidence | External family evidence | Dependency / compatibility | Status |
|---|---|---|---|---|
| Taoist player class | `docs/legacy/wiz/taoist-plan`、`taoism-spells`；無 player `set_class("taoist")`、root class daemon、entry LPC | MudRen／mudchina 有 `daemon/class/taoist/taolord.c` 與 skills，但該 path 是目錄，使用 family/master protocol | 缺 Target entry、recruit、daemon、`initialize`、`advance_level`；外部 `F_MASTER/create_family` 不等於 Target class API | `PARTIAL / SOURCE_REQUIRED` |
| Bonze player class | `docs/legacy/wiz/bonze`；無 player `set_class("bonze")`、root class daemon、entry LPC | MudRen／mudchina 有山煙寺與 `daemon/class/bonze/master.c`，但仍是 family/master 系統 | 缺 Target entry、recruit、daemon、rank/progression；API 與 Target 不閉合 | `PARTIAL / SOURCE_REQUIRED` |
| Soldier player class | `feature/npc/soldier.c` 是 NPC 行為；`obj/npc/death_black.c`／`death_white.c` 使用 soldier ID | 無 Target-compatible player-class chain | 公開精確搜尋的 `set_class("soldier")` 只回到黑白無常 NPC；缺 player entry、daemon、progression | `CONFIRMED_SOURCE / SOURCE_REQUIRED` |
| Random Task Quest | Target 只有 `doc/wiz/quest` 的 Story／Area Quest 模型 | MudRen／mudchina `u/cloud/npc/god.c` + `QUEST_D(tag)` + `quest/qlist*.c` 保存 assignment／kill completion／reward／clear 候選鏈 | 外部鏈位於 wizard-home content，schema／daemon path／save boundary 未與 Target 對應 | `HISTORICAL / SOURCE_REQUIRED` |
| Snowkeep | `girl.c → invitation.c → guard.c → /d/snowkeep/entrance`；`ebridge.c` 亦引用入口 | 公開精確 Code Search 只找到 Target 的 guard／ebridge 引用 | 缺 `/d/snowkeep/entrance.c` 及後續 Room／NPC／Object／Quest tree | `CONFIRMED_SOURCE / SOURCE_REQUIRED` |
| `red_wine` | `wine_pot.c` 直接建立 `/d/choyin/npc/obj/red_wine` | 公開精確 Code Search 只找到 Target caller | callee LPC 未保存；不能用其他酒物件替代 | `CONFIRMED_SOURCE / SOURCE_REQUIRED` |
| Original 冷梅世界 | Target 沒有可驗證的 Original 冷梅莊 Room／NPC LPC | Historical gameplay 只確認名稱／人物／武學表現 | Arena Expansion 不得倒灌；room path、exit、clone location 皆未閉合 | `HISTORICAL / SOURCE_REQUIRED` |

MudRen/ES2-utf8 與 mudchina/es2 的上述 class／quest 內容在結構與內容上屬同一外部 family，不視為兩份獨立證據。Target reachable Git history／tags 亦未保存缺失 class daemon、Snowkeep tree 或 `red_wine.c`。

## Historical Race：Target 直接行為片段

下列是 Target Original LPC 的直接片段，可確認 ID 或局部行為；它們**不是** initializer 公式。

| Source | Directly confirmed | Boundary |
|---|---|---|
| `cmds/usr/who.c` | `blackteeth`、`woochan`、`jiaojao`、`yenhold`、`rainnar`、`ashura`、`headless`、`yaksa`、`malik` 是歷史 race filter ID | 不含 daemon／出生值 |
| `cmds/std/steal.c` | `jiaojao` 有明確偷竊行為分支；`rainnar` 作為 victim 時有蛇物件相關防竊分支 | 不可反推八屬性、karma、age 或 `initialize()` |
| `adm/daemons/combatd.c` | `ashura/aggressive` 參與 Target combat aggression 判斷 | 只確認局部 combat hook，不等於 race daemon |
| `d/snow/npc/teacher.c` | Scholar 候選種族直接列 `human`、`woochan`、`jiaojao`、`rainnar` | 只確認 scholar eligibility 片段 |
| `obj/area/traveller.c` | NPC 直接使用 `set_race("jiaojao")` | NPC 使用不證明玩家 initializer |

因此 Human／Avatar 以外 historical race 統一為 `PARTIAL / SOURCE_REQUIRED`。缺少各自 `daemon/race/<id>.c`、`initialize()`、birth formula、gin／kee／sen、armor、age／lifespan、weight、special effect 與 `advance_level()` 時，不得把 ES2-KING temporary baseline 當 Original。

## Reincarnation / 城隍 Lifecycle

### Target direct Source

- `adm/daemons/chard.c::make_mist()` 直接呼叫 `LOGIN_D->reincarnate(victim)`。
- `adm/daemons/logind.c::reincarnate()` 保存 link、移除舊 body save、destruct body，然後重新進入 `user_race → get_race` character-creation pipeline。
- 這證明 Target 的 reincarnation core 是「刪除舊 body 後重選 race／重建 body」，不是單純解除 ghost。
- Target tree／reachable history 未保存可達的城隍 NPC、`register` command 或 `/d/death/` world entry。

### External family conflict

- MudRen／mudchina `feature/damage.c::reincarnate()` 只清除 ghost 並回復 effective gin／kee／sen。
- 同 family 的 `d/death/inn1.c` 與黑白無常 NPC 呼叫該 object method 後移往雪亭鎮／revive room；`d/snow/temple.c` 保存城隍廟 Room。
- 這套 lifecycle 與 Target `LOGIN_D->reincarnate()` 的 body recreation API／語意不同，不能直接拼接。

**Status：Target core `CONFIRMED_SOURCE`；城隍 register／Room／NPC／費用／flags／save boundary `SOURCE_REQUIRED`；外部 lifecycle `CONFLICT`；`IMPLEMENTATION READY = NO`。**

## Dependency Gate

本輪沒有任何新 Target 達成 `RECONSTRUCTION_READY`。精確公開搜尋只重現既有 caller／reference，未取得缺失 callee LPC。所有缺核心 daemon、entry、Room 或 object 的項目保持 `SOURCE_REQUIRED`；沒有建立 Runtime Source。
