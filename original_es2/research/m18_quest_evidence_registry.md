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
