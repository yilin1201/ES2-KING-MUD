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
