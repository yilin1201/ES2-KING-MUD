# M19 角色生命週期證據登錄表

> Lifecycle（角色生命週期）：角色從存活、昏迷、甦醒、死亡、鬼魂到復活，以及在線年齡累計的 Original ES2 執行流程。

## 證據來源

- 上游：`taedlar/es2_mudlib`
- 本階段只登錄上游實際存在的 LPC（Lars Pensjö C，傳統 MUD 程式語言）程式。
- 未在上游確認的死亡懲罰、輪迴、轉生與壽命上限一律標示 `UNKNOWN`（未知）。

## 已確認 Runtime 證據

| 項目 | 狀態 | Original 路徑 | 已確認行為 |
|---|---|---|---|
| 昏迷 | `CONFIRMED_RUNTIME` | `mudlib/std/char.c` | `unconcious()` 停止戰鬥、中斷動作、停用玩家輸入，並在 60 秒後呼叫 `revive()`。 |
| 昏迷甦醒 | `CONFIRMED_RUNTIME` | `mudlib/std/char.c` | `revive()` 恢復玩家輸入並解除全訊息封鎖；此函式名稱不等同寺廟的鬼魂復活。 |
| 死亡 | `CONFIRMED_RUNTIME` | `mudlib/std/char.c` | `die()` 清除戰鬥、護衛、蓄力、隊伍、動作與 condition（狀態效果），再由 `make_corpse()` 建立屍體。 |
| 鬼魂再次死亡 | `CONFIRMED_RUNTIME` | `mudlib/std/char.c` | `life_form == "ghost"` 時顯示魂飛魄散訊息，不建立第二具屍體。 |
| 鬼魂復活入口 | `CONFIRMED_RUNTIME` | `mudlib/std/room/temple.c` | 只有鬼魂可看見寺廟紅色漩渦；輸入 `enter` 後呼叫 `CHAR_D->make_living()`。 |
| 年齡累計 | `CONFIRMED_RUNTIME` | `mudlib/obj/user.c` | 在線時間累計到 86400 秒後，`age` 增加 1，並清除本輪 `time_aged`。 |
| 登入死亡補查 | `CONFIRMED_RUNTIME` | `mudlib/obj/user.c` | `setup()` 對 gin／kee／sen／HP 呼叫零傷害檢查，處理死亡前離線的情況。 |

## 仍為 UNKNOWN

- 玩家死亡後變成鬼魂的完整 `CHAR_D` 呼叫鏈與實際移動位置。
- 死亡後經驗、能力、物品或金錢是否扣除及其公式。
- 輪迴、轉生、壽命上限與永久死亡規則。
- 寺廟復活是否另有費用、冷卻或前置條件。

以上內容在取得完整 Original Runtime 證據前不得補造，也不得由 ES2-KING Expansion（擴充內容）反推。


## Vovo2000 歷史 Lifecycle 補強（2026-09-25）

Archived Source 的城隍爺人物資料明確描述：陽間人物死亡成為鬼魂後，需向城隍爺執行 `register` 才能繼續往生／輪迴，否則成為孤魂野鬼；另有地府鬼卒與鬼城地氣塔守將左國益的歷史人物資料。

這使「死亡→鬼魂→陰間→城隍爺／register→輪迴」提升為 `CONFIRMED_TEXT` 的歷史流程概念，補足現有 Runtime 只確認到鬼魂／寺廟復活入口的缺口。但 `register` LPC、城隍爺 path、移動位置、旗標、費用、輪迴公式與永久效果仍為 `SOURCE_REQUIRED`，不得用文字描述反推實作。
