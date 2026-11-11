# ES2M 地圖來源優先與舊資料修復規則

## 目的

ES2-KING 的地圖開發以 ES2M 主來源為優先，先複製、保存並核對 ES2M 地圖，再在 KING 工作快照上修復舊資料；不得以 ES2-KDS 或未驗證推測取代 ES2M。

## 固定來源

- 主 Repository：`https://github.com/wolfer168/es2-webmud`
- 主分支：`main`
- 本次已核對 HEAD：`ee12e717e2d3d88728607a01c2c2f1d634bf9616`
- 李家村拓樸：`source/upstream/mudlib/d/lee/LEE_TOPOLOGY.json`
- 該拓樸檔 Blob SHA：`22589002f4bfc18ed86381a1bf52f3533823471e`
- ES2-KING 工作快照：`es2m_snapshot/mudlib/d/lee/`

ES2M 主來源目前包含 81 個 Lee 地圖、NPC、物件與拓樸檔案；ES2-KING 工作快照也有對應的 81 個檔案。檔案數相同不代表內容逐位元一致，需以逐檔 SHA／差異比對確認。

## 來源衝突處理優先序

1. **ES2M 拓樸明確登錄**：用來判定預期地圖出口與房間之間的地圖連接。
2. **ES2M 原始 LPC 房間程式**：用來保留房間描述、NPC、物件、互動及其他遊戲邏輯；若靜態出口與 ES2M 拓樸不一致，記錄為舊資料／實作差異。
3. **ES2-KDS**：只作輔助交叉核對；不得在沒有 ES2M 證據時直接覆蓋主來源。
4. **ES2-KING 重建或擴充**：為遊戲可達性新增的路線、房間或機制，必須標示為 `ES2-KING Reconstruction/Expansion`，不得標成 ES2M 原始內容。

## 複製與開發規則

- 先保存來源版本與 Commit SHA，再將 ES2M 地圖複製到 KING 工作快照。
- 只在 KING 工作快照修復舊房間出口；不修改 ES2M 上游 Repository。
- 不得因房間檔案缺少出口就直接刪除拓樸登錄；先核對 ES2M 拓樸、相鄰房間、反向出口及實際測試。
- 不得只為讓測試通過而改測試預期。每條修復連接需有來源證據。
- 靜態拓樸 PASS、檔案同步 PASS、Driver Runtime PASS、實際遊戲可走通是不同層級，不可互相代替。
- 任何 ES2M 更新先做逐檔差異報告，再選擇性更新 KING；禁止整目錄覆蓋 KING 專屬修改。

## 本次 Lee 出口修復

ES2M 拓樸明確列出的以下連接，已用於修復 KING 工作快照中相應的舊房間出口：

- `square_s.south -> pawnshop`
- `square_c.east -> watermelon_n1`
- `watermelon_n1.west -> square_c`
- `pawnshop.north -> square_s`
- `watermelon_s3.east -> creek`
- `creek.west -> watermelon_s3`

ES2M 上游目前的部分 LPC 房間檔案仍與拓樸登錄不一致；因此這些修改應解讀為「依 ES2M 主拓樸修復 KING 工作快照」，而不是宣稱上游 LPC 原檔已包含相同出口。Runtime 尚須獨立驗證。

## 更新責任

每次同步需更新本文件或相應核對紀錄中的上游 HEAD、拓樸檔 SHA、檔案數、差異清單、採用／保留／拒絕原因與測試結果。PR #13 必須保持 OPEN / NOT MERGED；未經明確授權不得部署 Oracle。
