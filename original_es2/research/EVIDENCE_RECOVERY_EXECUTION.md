# Original ES2 Evidence Recovery Execution Register（證據補完執行登錄）

> 第五階段 5A。依 4F Backlog 實際開始 Recovery（補完考證），先使用 Repository 現存 Original／legacy 證據，不以 Reconstruction 填補未知。

## P0 執行結果

### R-001 Quest 完整鏈

- 現存 M18 Registry、Plan、Closure 一致：quest daemon、NPC trigger、progress save、completion、reward 仍為 `UNKNOWN`。
- Repository 目前只有搜尋 Gate／研究文件，沒有可直接升級成完整 Original Quest Runtime 的 LPC 證據。
- 結論：`SOURCE_REQUIRED`，維持 M18 `PARTIAL`；不得因檔名或關鍵字存在而宣告任務已恢復。

### R-002 人類族 Original ID

- 現存歷史 race registry 有 `human`，但沒有可直接支持「人類族」第二個 Original ID 的 Source。
- `human_clan` 仍只可視為 Reconstruction ID（重建識別碼）。
- 結論：`SOURCE_PENDING`，禁止升級為 Original ID。

### R-003 遺失 Race initializer

- `original_race_reconstruction_phase2.md` 明確記錄：目前可執行基線只確認 `human`、`avatar`；歷史種族缺少 daemon／birth initializer 公式。
- 歷史角色 Score 不能反推出生公式，因等級、技能、裝備等會改變屬性。
- 結論：`PARTIAL_IMPLEMENTABLE`；不得建立猜測的 `headless.c` 或其他種族 initializer。

## P1 第一輪結果

### R-004 冷梅莊／梅影風

- `original_es2/characters/mei_yingfeng.md` 已保存人物、門派、裝備、武學與任務文字證據。
- 但文件本身明確標記：Original NPC LPC path、HP、技能等級、完整 `set_skill/map_skill` 仍待考證。
- M15 Runtime Plan 同樣要求找到直接 LPC 後才能建立真實 NPC Runtime。
- 結論：人物內容可作 `ARCHIVED_SOURCE/PLAYER_RECORD` 交叉參考；NPC Runtime 仍 `SOURCE_REQUIRED`。

## 本輪沒有升級的項目

Quest、人類族 Original ID、歷史 Race initializer、梅影風 NPC Runtime 都沒有足夠新 Source，因此本輪**零項目由 UNKNOWN/SOURCE_PENDING 升級為 CONFIRMED_RUNTIME**。這是有效 Recovery 結果：確認 Repository 現有資料邊界，避免重複搜尋後誤把 Reconstruction 當 Original。

## 下一步

5B 轉向 Repository 之外的既知 Original Source／Archive 線索，優先追 Quest、Race daemon、冷梅莊 NPC；若仍找不到，保持 UNKNOWN，並改處理 P1 可交叉驗證的 Class Daemon／World path。


## 第五階段 5C — Quest Source Chain Recovery

外部 ES2 保存庫已找到可連接的 Quest 程式鏈候選（版本世系仍待鎖定，因此以下先列 `CORROBORATED_RUNTIME_CANDIDATE`）：

1. `include/globals.h` 定義 `QUEST_D(x) = /quest/qlist + x`。
2. `u/cloud/npc/god.c` 的朱鴻雪 NPC 以玩家 `combat_exp`、`tfinished` 選擇 qlist 等級，呼叫 `QUEST_D(tag)->query_quest()` 取得任務。
3. 派任務時把 mapping 寫入玩家 `quest`，並寫入 `task_time = time() + quest["time"]` 與 `quest_factor`。
4. `cmds/usr/quest.c` 讀取玩家 `quest` 與 `task_time`，顯示任務目標及剩餘時間。
5. `adm/daemons/combatd.c` 在 NPC 死亡時檢查：killer 有 quest、victim 名稱符合 quest 目標、task_time 尚未過期。
6. 條件成立後，以 qlist 的 `exp_bonus/pot_bonus/score` 為基礎計算獎勵，更新 `combat_exp/potential/score`，清除 `quest`，並更新 `tfinished`。

### 已閉合範圍

對「殺」型 Quest，外部候選 Source 已形成：

`qlist → NPC 派任務 → 玩家 quest/task_time 狀態 → combatd 擊殺完成判定 → exp/pot/score reward → quest 清除/tfinished 更新`

這已不是單一 qlist 檔，而是一條可追的 Runtime 候選鏈。

### 尚未閉合

- 目標天朝帝國 Original 正式站與該外部保存庫的**版本世系**尚未證明一致，因此數值不得直接搬入目前 Original Runtime。
- `尋`（物品交付）分支在 `god.c` 中存在舊 `accept_object` 邏輯，但該區塊被註解，不能宣告當時正式 Runtime 必然啟用。
- 玩家 `quest/task_time/tfinished/quest_factor` 是否全部經一般 Save 系統持久化，仍需下一輪直接追 F_SAVE / dbase 保存範圍。

### 5C 判定

M18 從「只有 Quest 資料表候選」提升為 **`CORROBORATED_RUNTIME_CANDIDATE / KILL-QUEST CHAIN CLOSED`**。仍不升級為目標 Original `CONFIRMED_RUNTIME`，直到版本世系與 persistence（持久化保存）完成核對。
