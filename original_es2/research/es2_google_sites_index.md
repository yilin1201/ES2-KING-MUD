# ES2 Historical Google Sites — 全站研究總索引

來源：`https://sites.google.com/site/es2mud`

## 任務定義

本檔不是單純網址收藏，而是 ES2-KING 對 **整個 ES2 歷史 Google Sites 的逐頁盤點／研究驗收表**。

專案要求：

> 讀完整個 ES2 網站；按照網站目錄逐頁盤點。能直接取得的頁面自行讀取、整理並交叉驗證；只有確實無法取得的頁面才列為缺口，不得把「知道網址／看到導覽」寫成「已讀取」。

### 狀態

- `[READ]`：已實際取得頁面正文並整理。
- `[PARTIAL]`：只取得部分正文、搜尋索引、截圖、影片或 archive；仍需補齊。
- `[DISCOVERED]`：已確認頁面／導覽入口存在，但尚未取得正文。
- `[BLOCKED]`：已嘗試讀取但 Google Sites／快取／權限等阻擋；需改用 archive、搜尋索引、使用者史料或 Original Source。
- `[CROSSCHECKED]`：已再與 Original Mudlib 對應程式交叉驗證。

證據標籤：網站設定頁 `[Archived]`；玩家攻略 `[Player Record]`；實機畫面／影片 `[Archived Gameplay Record]`；Original Mudlib 對應程式 `[Confirmed Source]`。

---

## A. 網站目錄盤點

### 天朝帝國
- `[DISCOVERED]` 主線任務

### 主題故事
- `[PARTIAL]` 歷史故事
  - 已取得使用者史料：武貞編年截圖
  - 已取得使用者史料：智賢編年截圖
  - 已取得使用者史料：祐聖編年截圖／webarchive
  - 待辦：抽取完整年號 → 年份 → 事件 → 門派 → 掌門／人物 → 創派／繼位／死亡／戰爭時間軸
- `[READ]` 神話設定
  - 盤古開天地；人界／混沌界
  - 天神、侮天鬼、寒於氏
  - 穿靈、旋芒；十七日夜聖戰
  - 寒於氏死後形成十三靈：金烏、銀蟾、大鵬、天龍、澤獸、鳳凰、赤魈、青蛛、濁魚、旱魃、穹氤、域摩、區冥
  - 人靈區冥百年重生／兩百年長眠；侮天鬼與天神六百年之賭
  - 三百年前皇城古木斷裂、侮天鬼元神出土
- `[DISCOVERED]` 種族設定
  - `[DISCOVERED]` 人類
  - `[DISCOVERED]` 刑天
  - `[DISCOVERED]` 厭火
  - `[DISCOVERED]` 夜叉
  - `[DISCOVERED]` 巫首
  - `[DISCOVERED]` 無腸
  - `[DISCOVERED]` 焦僥
  - `[DISCOVERED]` 釘靈
  - `[DISCOVERED]` 阿修羅
  - `[DISCOVERED]` 雨師妾
  - `[DISCOVERED]` 黑齒
- `[DISCOVERED]` 職業與門派
  - 武者 fighter
  - 道士 taoist
  - 和尚／僧侶 bonze
  - 書生 scholar
  - 小偷／盜賊 thief
  - 軍人 soldier
  - 方士 alchemist
  - 待辦：逐職業 → 門派 → 師父 → advancement → skills → map/enable → perform

### 玩家原創
- `[READ]` 新老玩家 Q&A
  - 悟性練功基數 `int / 7`（玩家紀錄，待 Source 驗證）
  - 七職業升級 Gin/Kee/Sen 除數
  - 死亡／Ghost／復活／2% 損失
  - dodge、parry、unarmed、force 練功方法
  - analyze：攻擊能力、攻勢等級、護甲強度、防禦能力、守勢等級
  - 冷梅／虎刀／封山等武者能力取向
  - 十三靈、四神、四鬼、天地靈、Reset、轉生丹／Seal 等玩家攻略
- `[DISCOVERED]` 各門派簡介
- `[DISCOVERED]` ES2 裝備列表
- `[DISCOVERED]` 裝備與升級計算
- `[DISCOVERED]` Yew 煉丹手記
- `[DISCOVERED]` 龍圖方士煉丹流程
- `[DISCOVERED]` 天靈／地靈任務
- `[DISCOVERED]` 玩家幫會紀錄

### 遊戲「截字」／實機紀錄
- `[PARTIAL]` 新手任務 1/2 — 使用者已提供影片
- `[PARTIAL]` 新手任務 2/2 — 使用者已提供影片
- `[PARTIAL]` 柳東蘆對戰景愈濤 — 使用者已提供影片
- `[PARTIAL]` 梅影風對戰劉乙忘玄 — 使用者已提供影片
- `[PARTIAL]` 梅影風對戰柳東蘆 — 使用者已提供影片
- `[PARTIAL]` 韓笑對戰劉乙忘玄 — 使用者已提供影片

影片研究目標：Combat Message、武學名稱、實際招式名稱、武器、Perform、內功效果、格擋／閃避、戰鬥節奏；逐項與 Original LPC source 交叉。

---

## B. Original ES2 核心欄位校正

八 Attribute 正式玩家顯示：

- `str` 臂力
- `cor` 膽識
- `int` 悟性
- `spi` 靈性
- `cps` 定力
- `dex` 機敏
- `con` 根骨
- `wis` 慧根

注意：早期索引曾把 `cor` / `cps` 中文對應寫反；本檔依專案已確認的 Original 顯示校正為 `cor=膽識`、`cps=定力`。`str=臂力` 為專案擁有者實機畫面確認；若上游 source 顯示「膂力」，保留版本文字差異。

---

## C. 歷史編年專項

建立 Original ES2 歷史鏈：

`年號 → 年份 → 朝廷事件 → 武林事件 → 門派創立／滅亡 → 掌門繼承 → NPC 生卒／關係 → Quest 時代背景`

目前史料至少涵蓋：`武貞`、`智賢`、`祐聖`。年號先後不得依截圖上傳順序猜測，必須由正文交接事件／其他 Original 證據確認。

門派創立年份只有在歷史頁正文或 Original Source 明確支持時才標為確定。

---

## D. 逐頁研究規則

1. 網站導覽出現 ≠ 已讀取。
2. 搜尋引擎 snippet 只能支持 snippet 實際包含的內容。
3. Google Sites 子頁抓取失敗時，依序嘗試：頁面 URL／搜尋索引 → webarchive／使用者已提供史料 → Original Mudlib 對應 source。
4. 不要求使用者替專案逐頁人工截圖；只有所有可自行取得途徑均失敗且該頁對還原重要時，才明確列出缺口。
5. 網站與 Source Code 衝突時兩者都保留，記錄版本差異；不得偷偷融合。
6. Original 與 ES2-KING Expansion 永遠分離。
7. 每次研究都更新本索引狀態，避免再次遺忘哪些頁面真正讀過。

---

## E. 下一批盤點順序

1. 歷史故事：補齊武貞／智賢／祐聖及其他可發現年號，建立 `original_es2/history/timeline.md`。
2. 職業與門派：七職業全頁，建立門派／師父／武學樹。
3. 種族設定：11 Race 全欄位逐頁建檔並與 race LPC 交叉。
4. 主線任務：Quest 流程、NPC、物品、地點、前置條件。
5. 玩家原創：攻略逐頁抽取，但保持 `[Player Record]`。
6. 遊戲截字／影片：逐場抽取 Original 戰鬥招式與 Combat Message。
7. 世界／天朝地圖：房間與道路索引，與 `/d` world source 交叉。

完成標準不是「找到網址」，而是每一頁都有 `[READ] / [PARTIAL] / [BLOCKED]` 狀態、來源證據與可用於 Original ES2 重建的結構化摘要。