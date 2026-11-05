# M18 Evidence-to-Runtime Field Map（證據到實機欄位映射）

> 第五階段 5K。目的：在真正修改 Runtime 前，逐欄標示哪些結構可依證據重建、哪些只是外部版本候選、哪些仍未知。禁止用 Candidate/UNKNOWN 補造目標 Original 數值。

## A. Random Task Quest（隨機任務型）

| Runtime field / behavior | Evidence | Status | ES2-KING action |
|---|---|---|---|
| quest list loader | 外部 ES2 family `QUEST_D → qlist` | CANDIDATE | 只保留介面概念 |
| quest target/type/time | qlist mapping | VERSION_SOURCE_PENDING | 不搬精確內容 |
| exp/pot/score reward | qlist + combatd | VERSION_SOURCE_PENDING | 不搬精確數值 |
| player `quest` state | giver NPC + quest cmd + combatd | CORROBORATED_RUNTIME | 可作欄位模型參考 |
| `task_time` | giver NPC + quest cmd + combatd | CORROBORATED_RUNTIME | 可作限時狀態模型參考 |
| `quest_factor` / `tfinished` | giver/combatd | CORROBORATED_RUNTIME_CANDIDATE | 保留語意，不採精確公式 |
| kill completion | combatd target/name/time check | CHAIN_CLOSED_CANDIDATE | 可重建介面，不複製版本公式 |
| item-search completion | commented accept_object candidate | INACTIVE/UNKNOWN | 禁止宣告啟用 |

## B. Story/Area Quest（區域故事／解謎型）

| Runtime field / behavior | Evidence | Status | ES2-KING action |
|---|---|---|---|
| NPC start mark | Scholar master `marks/書生` | CANDIDATE_CONTENT | 只作事件鏈證據 |
| room entry gate | Scholar entrance | CHAIN_CLOSED_CANDIDATE | 可作 Room Gate 介面參考 |
| puzzle progress state | `taolin_steps` | CHAIN_CLOSED_CANDIDATE | 可作 progress state 介面參考 |
| completion mark | `marks/桃林` | CHAIN_CLOSED_CANDIDATE | 可作 completion flag 介面參考 |
| return-to-NPC completion | master checks mark then recruit | CHAIN_CLOSED_CANDIDATE | 可作 Quest→Apprentice 連接參考 |
| exact poem/path/content | external family source | VERSION_SOURCE_PENDING | 不直接當目標站 Canon |

## C. Persistence（持久化）

- 一般 player `dbase` + F_SAVE：`CORROBORATED_RUNTIME`。
- `tmp_dbase`：temporary/non-save；不可用於需跨登入保存的 Quest 完成旗標。
- 是否每次事件後立即 `save()`：`UNKNOWN`；不可假設 crash-safe 即時保存。

## D. M18 Runtime Gate 升級條件

現有 Gate 只能搜尋關鍵字，不能把「找到 quest 字串」當完整 Runtime PASS。後續真正升級 Gate 時必須分開驗證：
1. Trigger（觸發）
2. Progress state（進度狀態）
3. Completion condition（完成條件）
4. Reward/result（獎勵／結果）
5. Persistence（保存）
6. Evidence status（證據等級）

只有同一條任務鏈 1–5 都有可追證據，且第 6 項允許 Runtime 使用時，才能標示 reconstructed chain PASS。
