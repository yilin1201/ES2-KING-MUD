> [ORIGINAL BASELINE CLOSURE]
> 本文件保存 Original ES2 對應里程碑的結案／證據邊界，仍可作 Original 基線參考；**不代表目前 M30 Public Acceptance 狀態**。目前狀態以 `docs/status/CURRENT_M30_STATUS.md` 為準。

# M18 Original ES2 Quest 證據收斂紀錄

稽核基準：`build/original-es2-races-phase2` 最新 Head `f5f325706ac3645ede7828798ae2008d873c8a56`。

## 已完成

- `original_es2/research/m18_quest_evidence_registry.md` 建立證據分級：`CONFIRMED_TEXT`、`CONFIRMED_RUNTIME`、`UNKNOWN`。
- `original_es2/research/m18_quest_runtime_plan.md` 定義從觸發、進度、完成條件到獎勵的完整鏈核對方法。
- `scripts/test_m18_quest_runtime_gate.sh` 可對乾淨 Original Runtime 搜尋任務、NPC 觸發、旗標、進度與獎勵候選，不因找到關鍵字就宣告完整任務。
- 本機 M18 Gate 實際執行後，候選結果仍依證據登錄表逐項判定，不生成任務數值或流程。

## 尚缺與分類

| 缺口 | 類型 | 狀態 | 可否直接完成 |
|---|---|---|---|
| 任務主控／daemon 的可靠 Original LPC 證據 | Original 歷史證據／Runtime | `UNKNOWN` | 否，需取得並核對原始程式 |
| NPC 任務觸發、條件與任務旗標 | Runtime／Evidence | `UNKNOWN` | 否，禁止推測 NPC path 或旗標 |
| 玩家任務進度保存 | Runtime／Persistence | `UNKNOWN` | 否，需直接證據連結 save 欄位 |
| 完成判定與經驗／金錢／物品獎勵 | Runtime／Regression | `UNKNOWN` | 否，禁止補造數值或流程 |
| 搜尋 Gate 與證據一致性自動檢查 | Static／Regression | 已補測試 | 是 |

## 結論

M18 維持 `PARTIAL`。可重現的搜尋 Gate、證據分級與禁止補造規則已完成；完整 Original 任務鏈沒有可靠證據，相關項目保持 `UNKNOWN`。
