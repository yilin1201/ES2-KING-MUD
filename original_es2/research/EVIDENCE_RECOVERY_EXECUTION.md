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


## 第五階段 5D — Quest Persistence + Version Lineage

### Persistence（持久化保存）

外部歷史保存庫的 `feature/dbase.c` 明確區分：一般 `mapping dbase` 與 `nosave mapping tmp_dbase`；Quest 鏈使用 `me->set("quest")`、`set("task_time")`、`set("quest_factor")`、`set("tfinished")`，均寫入一般 dbase，而不是 temp dbase。

`obj/user.c` 繼承 `F_SAVE`，`feature/save.c` 以 `save_object()` 保存 user object；`cmds/usr/save.c` 會呼叫 `me->save()`。因此在這個歷史 Source lineage 中，上述 Quest 欄位具備隨一般玩家 dbase 存檔／restore 的結構條件。

現行 Annihilator/taedlar ES2 Source 仍保留相同核心模型：user 繼承 `F_SAVE`、一般 `dbase` 可保存、`tmp_dbase` 為 static temporary mapping、F_SAVE 使用 `save_object/restore_object`。這是跨版本的 Persistence 架構佐證。

判定：**Quest state persistence mechanism = CORROBORATED_RUNTIME**；但某一歷史正式站是否對每次 Quest 操作立即呼叫 save，與 server crash 前最後狀態，不能由此推成自動即時保存。

### Version Lineage（版本世系）

Annihilator/taedlar 官方 Repository README 明確說明：GitHub initial commit 基於 ES2 Mudlib v1.3b；目前 main 已是 v1.5+，另有 v1.4 legacy branch。現行 taedlar tree 已不含歷史 `quest/qlist*.c` 與朱鴻雪 Quest NPC，因此外部 MudRen/mudchina Quest content 不能直接宣稱等於 taedlar current Original Source。

然而 Quest 保存庫的核心 F_SAVE/DBASE/User 結構與 taedlar 現行 lineage 高度一致，支持它們源自同一 ES2 Mudlib 家族；這只能建立 **family lineage corroboration（同源家族佐證）**，不能證明目標天朝帝國正式站的精確版本與 Quest 數值。

### 5D 結論

- Kill Quest chain：`CORROBORATED_RUNTIME_CANDIDATE / CHAIN CLOSED`。
- Quest persistence architecture：`CORROBORATED_RUNTIME`。
- Exact qlist values / 朱鴻雪 content version：仍 `VERSION_SOURCE_PENDING`。
- M18 仍不直接升級為目標 Original `CONFIRMED_RUNTIME`。


## 第五階段 5F — Class / Lengmei Boundary Recovery

直接檢查 taedlar official `v1.4` tree：`mudlib/daemon/class/fighter.c` 存在，但內容只提供武者 rank／稱謂（武者、在下、英雄、傢伙），沒有冷梅莊、梅影風、拜師條件或技能公式。tree 未找到 lunmay/lengmei/mei/may 對應區域或 NPC Source。

因此可確認：
- Fighter Class 基礎 Daemon：`CONFIRMED_SOURCE`。
- 冷梅莊／梅影風作為 Fighter 師門：仍由外部歷史玩家／人物資料交叉支持，official v1.4 tree 未提供 Runtime Source。
- 不得把 `fighter.c` 的存在解讀成冷梅莊 Runtime 已保存。

這使 M15/M11 的邊界更清楚：Class Engine 與 School Content 是不同層；可先維持 Fighter Class Engine，不必等待冷梅莊 Source，但 School/NPC 不補造。
