# Original ES2 Recovery Architecture Map（補完架構圖）

> 第五階段 5J。目的不是新增 Canon，而是把目前已回收的 Source 關係整理成可重建邊界。

## 已確認／已交叉支持的層級

| Layer | Source evidence | Recovery status |
|---|---|---|
| Persistence Engine | DBASE + F_SAVE + user save/restore | CORROBORATED_RUNTIME |
| Class Engine | official taedlar fighter daemon + external family class source | CONFIRMED_CORE / CANDIDATE_CONTENT |
| Apprentice Engine | F_MASTER / recruit + NPC attempt_apprentice patterns | CORROBORATED_RUNTIME_CANDIDATE |
| Random Task Quest | qlist → giver NPC → player state → combatd reward | CHAIN_CLOSED_CANDIDATE |
| Story/Area Quest | NPC mark → room gate → puzzle → completion mark → recruit | CHAIN_CLOSED_CANDIDATE |
| World Event Room | room action/state transition | CORROBORATED_RUNTIME_CANDIDATE |
| School Content | master NPC / family / skills / equipment | VERSION_SOURCE_PENDING |
| Historical races | archived registry + partial framework | PARTIAL / SOURCE_PENDING |

## 目前可安全重建的「介面」，不可直接採用的「內容」

可以依證據重建的介面概念：
- 玩家一般 dbase 狀態可持久保存。
- Class 與 School 分層。
- NPC 可透過 attempt/recruit 與 marks/temp state 驅動拜師。
- Room 可以承載 Quest state transition，不只是出口。
- Random Task 與 Story Quest 是不同模型。

仍不可直接採用為目標 Original 真值：
- 外部 qlist 的精確 exp/pot/score。
- 外部 NPC 的 HP、技能等級與裝備數值。
- 未被 official/target archive 鎖定的門派名稱與版本內容。
- headless/yaksa 等遺失 Race initializer。
- 人類族第二 Original ID。

## 後續 Recovery 順序

1. 以 Story/Area Quest 的已閉合鏈作為 M18 Reconstruction Spec 的「介面參考」，不複製未鎖版本內容。
2. 繼續搜尋目標歷史站／Archive 是否能對應外部 Class/School NPC 名稱，只有對應後才提升內容可信度。
3. Race initializer 與 human-clan ID 保持 P0，不因 Class/Quest 有進展而降級。
4. Runtime 實作前先建立 Evidence-to-Runtime 欄位表，逐欄標記 CONFIRMED/CANDIDATE/UNKNOWN，避免猜值。
