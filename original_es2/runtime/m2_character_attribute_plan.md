# M2 — Original ES2 人物基礎系統與八大屬性實機驗證

狀態：IN PROGRESS

## 原則

M2 只重建與驗證 Original ES2 已有行為，不以 ES2-KING Expansion 覆蓋 Original。

## 已由 Original ES2 Source 確認

### 人類初始八大屬性

`mudlib/daemon/race/human.c` 在 Human 初始化時建立八個 attribute：

- `str` — 專案正式玩家標示：臂力；目前 upstream `score.c` 顯示「膂力」
- `cor` — 膽識
- `int` — 悟性
- `spi` — 靈性
- `cps` — 定力
- `dex` — 機敏
- `con` — 根骨
- `wis` — 慧根

Human 每項初始 raw value = `13 + random(6)`，因此正常範圍為 13–18。

### 初始 Statistic

Human 初始化：

- `gin` = 30
- `kee` = 30
- `sen` = 30

HP 與 Kee 為不同資料，不得合併。

### Attribute base / effective

`query_attr(name, 1)` 讀取 raw/base value；`query_attr(name)` 會加上暫時性的 `apply/<name>` 修正值。因此 M2 必須能分辨「基礎值」與「有效值」。

### score 顯示條件

目前 upstream `mudlib/cmds/usr/score.c` 只有在：

- 查看者為 wizard；或
- 玩家 level > 1

時才顯示八大屬性。

因此 M1 的 Lv.1 玩家 `score` 沒有八大屬性是 Original ES2 現行程式的預期行為，不應誤判為資料未初始化。

## M2 實機驗證目標

1. 真實建立 Human / Commoner / Lv.1。
2. 驗證八個 raw attributes 都已實際初始化，而不是只存在於文件。
3. 驗證 Human 八項 raw value 各自介於 13–18。
4. 驗證 gin / kee / sen 初始值為 30，且 HP 與 Kee 分離。
5. 驗證 Lv.1 `score` 依 Original 規則不顯示八大屬性。
6. 以不竄改 Original 規則的測試方式取得八大屬性實際值，並核對 `score.c` 的顯示順序與中文名稱。
7. 驗證 base value 與 effective value 的差異機制。
8. 把實機結果寫入 M2 evidence，作為後續人物系統重建基準。

## M2 PASS 條件

- 八大屬性全部有 live runtime evidence。
- Human 初始值範圍符合 Original Source。
- Human/Commoner/Lv.1 身分與 M1 一致。
- HP、Gin、Kee、Sen 的資料模型被實機確認。
- `score` 顯示條件與實機結果一致。
- 沒有為了讓測試通過而改寫 Original ES2 的遊戲規則。
