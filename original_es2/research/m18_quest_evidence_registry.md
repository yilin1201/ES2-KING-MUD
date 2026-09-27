# M18 任務系統證據登錄表

## 證據分級

- `CONFIRMED_TEXT`（文字證據已確認）：歷史資料支持，但尚未取得完整實機程式鏈。
- `CONFIRMED_RUNTIME`（實機原始碼已確認）：已由乾淨 Original ES2 上游逐檔核對。
- `UNKNOWN`（未知）：證據不足，不補造。

## 系統盤點

| 項目 | 狀態 | 升級條件 |
|---|---|---|
| 任務主控／daemon | `UNKNOWN` | 找到實際 LPC 並確認其任務職責 |
| NPC 任務觸發 | `UNKNOWN` | 核對 NPC path、觸發條件與任務旗標 |
| 任務進度保存 | `UNKNOWN` | 找到玩家資料欄位／save 邏輯 |
| 任務完成判定 | `UNKNOWN` | 核對完整條件判斷 |
| 經驗／金錢／物品獎勵 | `UNKNOWN` | 找到與任務完成直接相連的獎勵程式 |

## 禁止事項

- 不以 ES2-KING Expansion（擴充設定）任務反推 Original。
- 不因檔名含 `quest` 就宣告它是完整任務系統。
- 不自行設定任務經驗值、掉落率、擊殺數或 NPC path。

## 第五階段 5B 外部 Recovery 更新

外部 ES2 保存庫 `mudchina/es2` 與 `MudRen/ES2-utf8` 發現多份實際 `quest/qlist*.c`，其 entry 含 quest、quest_type、time、exp_bonus、pot_bonus、score。因版本 lineage（來源世系）尚未完成，暫列 `CORROBORATED_CANDIDATE`，**不直接把其中數值升級為目標 Original Runtime 真值**。

因此「任務資料表候選」已有程式證據，但任務主控／NPC trigger／progress save／completion/reward 呼叫鏈仍為 `SOURCE_REQUIRED`。下一步追 qlist 呼叫端。

## 第五階段 5C Quest Chain 更新

外部保存 Source 已可串起「殺」型 Quest 候選鏈：`QUEST_D → qlist/query_quest → 朱鴻雪 NPC 派發 → quest/task_time/quest_factor → combatd 擊殺判定 → combat_exp/potential/score reward → quest 清除/tfinished 更新`。

狀態提升為 `CORROBORATED_RUNTIME_CANDIDATE / KILL-QUEST CHAIN CLOSED`，但**不是目標 Original CONFIRMED_RUNTIME**：外部庫版本世系與玩家 quest 欄位 persistence 尚待核對；物品「尋」型分支可見被註解的 accept_object 候選，暫不宣告啟用。

## 第五階段 5D Persistence 更新

外部歷史 Source 的 Quest 狀態使用一般 `set()` 寫入玩家 dbase，而 `feature/dbase.c` 只把 `tmp_dbase` 標為不保存；user 繼承 F_SAVE，F_SAVE 以 save_object/restore_object 保存。taedlar 現行 ES2 仍保留相同一般 dbase／temporary dbase 與 F_SAVE 架構。因此 Quest state persistence architecture 可列 `CORROBORATED_RUNTIME`。

但 taedlar current tree 已不含 qlist/朱鴻雪 Quest content，故外部 qlist 精確數值與正式站版本仍 `VERSION_SOURCE_PENDING`，不得直接採為 Original 真值。

## 第五階段 5E Quest 類型分流

官方 taedlar `docs/legacy/wiz/quest` 將 Quest 描述為區域內一連串事件／故事／解謎，可導向物品、技能、門派或職業；外部 qlist/朱鴻雪則是另一種「隨機任務型 Quest」。因此 M18 後續分兩條：

- **Track A — Random Task Quest**：qlist → NPC → combatd；已有外部 chain-closed candidate。
- **Track B — Story/Area Quest**：官方設計概念 CONFIRMED，但具體歷史任務 Source 仍 SOURCE_REQUIRED。

兩者不互相覆蓋，也不把 qlist 當成 Original Quest 的唯一模型。

## 第五階段 5H Story/Area Quest Source Recovery

外部 ES2 家族 Source 已找到一條可完整追蹤的 Story/Area Quest 候選：**步玄派桃林入門鏈**。

`daemon/class/scholar/master.c`：駱雲舟首次拒絕時設定 `marks/書生=1`，要求玩家先走東邊桃林；`daemon/class/scholar/entrance.c` 只有持有該 mark 才允許向東，並設定 `taolin_steps=3`；`d/choyin/taolin.c` 透過讀 note、依詩句缺字判斷方向，正確路徑逐步降低 steps、錯誤增加 steps，完成後設定 `marks/桃林=1` 並送回 entrance；再次拜師時 master 檢查 `marks/桃林`，成功 recruit、清除兩個 marks。

候選鏈因此閉合為：
`NPC 提示/mark → Room gate → 桃林解謎 → completion mark → 回 NPC → recruit/class`。

判定：`CORROBORATED_RUNTIME_CANDIDATE / STORY-QUEST CHAIN CLOSED`。這與 taedlar legacy Quest 文件所描述「事件／故事／提示／動作／職業相關 Quest」的設計原則相符，但外部 content 的精確版本仍未升級為目標正式站 Canon。

## 2026-09-27 目標 Branch Snow Quest Audit

本次直接在目標 Branch 找到：

- `d/snow/npc/child.c`：阿寶依 `try/fon` 進行對話、食物／梳子交換、破布交付與 follow。
- `d/snow/npc/gammer.c`：瞎眼老太婆依 `try/fon` 進行對話、NPC relay 與部分旗標轉移。

這證明 Snow 保存區確有 Story/Area Quest 的殘存 Original Runtime Source，但現存 Repository 沒有保存所有狀態轉移的呼叫端。可見狀態之間存在斷點，且尚無法由入口連續驗證到 completion／reward；`try/fon` 又是 temporary dbase，不能推定完整進度 persistence。

## 2026-09-27 Phase 2 Content Inventory 更新

擴大掃描 Snow NPC／item 後，另找到一條先前未列入 Quest inventory、但可由目標 pinned Source 完整追蹤的區域進階鏈：

`店小二食物 → 阿寶 accept_object → 紅木梳子 → 瞎眼老太婆 accept_object → thief_qualified → say 祖奶奶 → class=thief → sneak/stealing learning progress`

隔離 `thiefprobe` 已在真實 Neolith Driver 以玩家指令完成上述流程，並通過 `save → quit → relogin → class/learned restore`；正式 marker 為 `ORIGINAL_THIEF_PROGRESSION_RUNTIME_PASS`。這個結論只提升**目標 Snow 盜賊入門鏈**為 `COMPLETE / RUNTIME PASS`，不會補齊 `try/fon`、隨機任務 daemon 或其他歷史 Quest。

另確認髮簪→英雄帖鏈可走至青衣漢子，但交付後 active move 指向缺少的 `/d/snowkeep/entrance`，故分類 `BROKEN / UNREACHABLE`，不從版本未鎖定的外部保存庫搬入。

因此 Quest 全域狀態由 `UNKNOWN` 更新為 `PARTIAL`：至少一條目標版本 Story／Area progression 已閉合；其餘斷鏈與缺檔仍維持 PARTIAL／BROKEN／UNKNOWN。完整清冊見 `game_content_inventory_phase2.md`。

`try/fon` 子鏈的判定仍為 `UNKNOWN / INCOMPLETE TARGET-SOURCE CHAIN`。不以外部候選補入遺失 NPC、地圖、條件、獎勵或數值；此邊界不否定已獨立閉合的 Snow 盜賊入門鏈。

## 2026-09-27 Phase 3 Deep Recovery / Runtime 更新

已完成目標 upstream 全 history／tag、兩個公開 ES2 family mirror、封存 Evidence 與公開精確搜尋。`Snowkeep`、`try/fon` 缺失轉移及 `__ID_CHALLIE__` 物件來源均未找到同版本決定性 Source，正式記錄為 `EVIDENCE EXHAUSTED / UNKNOWN`；`__ID_CHALLIE__` 是 `id()` 字串，不是 missing macro，禁止以 `#define` 偽修復。詳見 `original_content_deep_recovery_phase3.md`。

新增兩條隔離真 Driver 證據：

- **貨棧工錢**：Original exits 到貨棧，完成 `crate → wagon → wage_deserved → say 工錢 → 25 coin → save/quit/relogin`。修復 Original combined money 讓工頭 220 文與 reward 25 文誤合併成 245 文的 Runtime bug；marker `ORIGINAL_WAGE_RUNTIME_PASS`。
- **Snow 私塾 Scholar entry**：以 `literate=5` 明示前置 fixture 完成 `sit → learning progress → offer → say 想 → class=scholar → save/quit/relogin`。修復 Big5 `msg[0..1]` 在 UTF-8 下無法匹配「想／是／好」的 compatibility bug；marker `ORIGINAL_SCHOLAR_RUNTIME_PASS`。

兩條狀態升級為 `RUNTIME PASS`（Scholar 為 BOUNDED：排除 random scheduling，且不宣稱外部桃林／Scholar daemon 全內容）。Quest 全域仍是 `PARTIAL`，因 Snowkeep 與 `try/fon` 的缺失內容未被補造。
