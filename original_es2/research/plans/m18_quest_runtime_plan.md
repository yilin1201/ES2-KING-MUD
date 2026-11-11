# M18 任務系統 Runtime 重建計畫

> Quest Runtime（任務實機系統）：由 Original ES2 程式真正控制任務觸發、進度、完成條件與獎勵的執行邏輯。

## 目標

在不補造 Original ES2 任務內容的前提下，盤點公開上游中的 quest／task／mission 類程式、NPC 對話觸發、物品交付、擊殺條件、獎勵與玩家進度保存機制，建立可追溯的任務系統基線。

## 證據原則

1. 只以乾淨 Original ES2 Runtime tree（實機程式樹）作為 `CONFIRMED_RUNTIME`（實機原始碼已確認）來源。
2. 歷史聊天、攻略、模擬內容可列為 `CONFIRMED_TEXT`（文字證據已確認），不可直接生成 Runtime 數值。
3. 任務名稱、NPC、需求物品、擊殺數、經驗／金錢／物品獎勵均需逐項有證據。
4. 找不到時保持 `UNKNOWN`（未知）。

## 第一階段搜尋面

- `quest`、`task`、`mission` 關鍵字與 daemon（常駐系統程式）。
- NPC（Non-Player Character，非玩家角色）中的 ask／talk／give／kill 類觸發。
- 玩家資料中的 quest flag（任務旗標，用來記錄任務是否觸發或完成）。
- reward（獎勵）、experience／exp（經驗值）、money（貨幣）與 clone_object（建立物件）線索。

## 完成條件

建立可重現 Runtime Gate（實機證據閘門）與 Evidence Registry（證據登錄表），並由 GitHub Actions（GitHub 自動測試流程）自動執行。找到候選程式不等於任務已重建；必須核對完整觸發→進度→完成→獎勵鏈後才能升級。


## 第五階段 5L — Reconstruction Spec 更新

M18 後續 Runtime 重建分成兩種模型：

### Model A — Random Task Quest

giver/daemon 取得任務資料 → 寫入 persistent player state → 顯示目標／時間 → gameplay completion hook（例如 combat kill）→ reward/result → 清除／更新完成狀態。

### Model B — Story/Area Quest

NPC/room 觸發 → persistent mark/flag → room/action gate → puzzle/event progress → completion flag → 返回 NPC/下一事件 → class/item/skill/story result。

### 安全實作規則

1. Engine interface（引擎介面）可依已交叉支持的 Source 模型重建。
2. Quest content（任務內容）逐欄依 `M18_EVIDENCE_TO_RUNTIME_FIELD_MAP.md` 決定是否可用。
3. `VERSION_SOURCE_PENDING`、`UNKNOWN` 不進正式 Original Runtime。
4. Candidate 可用於測試 fixture（測試樣本）時，必須清楚標示 Reconstruction/Test，不得冒充 Original Canon。
5. Runtime Gate 不再以「搜尋到 quest 關鍵字」作完整鏈 PASS；後續 Gate 應驗證 trigger/progress/completion/result/persistence 五段。
