# ES2 實際登入／創角／初期遊戲 Runtime Evidence — Part 1/2

> Source: 使用者提供實際 ES2 遊戲錄影 `ES2_PART_1_2_480p(1).mp4`  
> Duration: 約 467.6 秒（7分48秒）  
> Resolution: 600×480 / 約 29.97 fps  
> Evidence status: **ACTUAL GAMEPLAY VIDEO — CONFIRMED where visually legible**  
> Purpose: 提升 ES2-KING 從 Login → Character Creation → Enter World → Early Gameplay 的重建成功度。

## 1. Evidence 原則

- 本影片為實際遊戲操作錄影，證據優先級高於二手描述。
- 只記錄影片中可辨識的流程／畫面；解析度不足的細字不猜測。
- 後續可再依關鍵時間點逐格建立更細的 Prompt／Command／Output registry。
- 不因單支影片未展示某功能，就判定 Original ES2 不存在該功能。

## 2. 已確認的流程骨架

影片顯示的實際操作可用來建立下列 Journey：

`Client 啟動 → 連線／登入介面 → Character/Login 流程 → 進入遊戲世界 → 房間文字輸出 → 方向移動 → score／角色資訊 → 指令互動 → 世界探索`

### CONFIRMED UI / Runtime characteristics

- 使用傳統文字 MUD Client（影片畫面為 zMUD 類介面）。
- 遊戲主要輸出為黑底文字終端。
- 房間輸出包含：房間名稱／敘述／可移動方向。
- 可見方向文字包含 `east`、`west`、`south`、`north`。
- 玩家以文字命令持續操作，而非圖形化選單戰鬥。
- 影片中可見角色資訊／score 類型畫面，具有多欄角色數值／狀態呈現。
- 進入世界後存在連續房間移動、NPC／環境文字與指令回應。

## 3. ES2-KING Game Completion 對應

此影片增加以下重建可信度：

| Game Completion 項目 | 本影片貢獻 |
|---|---|
| Connect / Login | 實際歷史操作流程 Evidence |
| Character entry | 實際角色進入世界 Evidence |
| Room look/output | CONFIRMED |
| Direction movement | CONFIRMED |
| score / character information | 畫面 Evidence |
| Command-driven interaction | CONFIRMED |
| Continuous world navigation | CONFIRMED |
| NPC / Items / Combat / Skills / Apprentice | 需配合本影片更細逐格與其他實機 Evidence，不因本摘要直接宣告全部 PASS |

## 4. Runtime 重建成功度規則

Game Completion 的「成功度」分成兩層：

1. **Evidence Coverage**：我們是否已知道 Original ES2 實際應該如何呈現／操作。
2. **Runtime PASS**：ES2-KING Neolith Runtime 是否真的執行成功。

本影片可提高 Evidence Coverage，但不能取代 Neolith Full Driver Journey 的 Runtime PASS。

目前 Full Driver Journey 仍需實際驗證：
`NPC → Items/Equipment → Combat → Skills → School/Apprentice`

## 5. 後續影片解析 Queue

下一輪逐格解析優先建立：
- Login 每一個 Prompt 與輸入順序。
- 新角色建立每一個選項／提示。
- 種族／性別／屬性等 Character Creation 欄位（只取影片確實出現者）。
- Enter World 第一個房間與初始文字。
- 每個實際輸入 command 與相對 output。
- score 欄位。
- movement 房間鏈。
- NPC interaction。
- item / equipment。
- combat。
- skills。
- school / apprentice。

完成逐格時間軸後，將這份 Evidence 轉成 Full Driver Journey 的 expected-output 對照資料，降低 Runtime 測試靠猜測的比例。
