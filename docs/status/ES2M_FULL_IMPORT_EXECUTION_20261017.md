# ES2M → ES2-KING 全量整合執行帳（2026-10-17）

## 授權與保護原則

- 使用者已授權將固定 ES2M 更新來源 `71693beb79ced81d51719ea1ccf7c02c641ca9b0` 全面整合至 KING。
- 這代表開始執行完整分批移植，不代表允許整目錄覆蓋或略過相容性測試。
- 所有工作只在 `integration/es2m-audit-import-20261017` 進行；PR #13 必須保持 OPEN / NOT MERGED；Phase 2 固定基線不修改。
- 固定 Original ES2、ES2M 更新證據、KING 原有內容與 KING Expansion 分層保存。
- 同名衝突不得靜默覆蓋；玩家可見政策差異須列入正式移植批次，無證據的內容標記 HOLD，不宣稱完成。

## 來源盤點基準

來源：`wolfer168/es2-webmud@71693beb79ced81d51719ea1ccf7c02c641ca9b0`

依 `docs/status/ES2M_SOURCE_SYNC_MANIFEST_20261017.json`：

- 上游檔案：1,678
- 與既有 ES2M 快照相同：981
- 相對既有快照修改：160
- 相對既有快照新增：537
- KING 快照獨有、需審查：3
- 需相容性審查：700

以上是來源差異統計，不是已移植檔案數。

## 分批執行紀錄

| 批次 | 範圍 | 執行方式 | 狀態 |
|---|---|---|---|
| 0 | 固定來源與差異清冊 | 固定 submodule、三方 manifest 與來源契約檢查 | 已建立；不代表內容已移植 |
| 1 | 最新 ES2M 的 `d/qiaoyin` 橋隱區域 | 固定 submodule 來源；只補 Runtime 缺檔、追蹤字面依賴、同名衝突即停止 | 首次建置因 Actions 尚未遞迴 checkout submodule，來源目錄不存在而 FAIL；已修正 workflow 的 `submodules: recursive`；再由上游 Git tree 確認實際來源位於 `source/upstream/mudlib`（不是 repo root 的 `mudlib`），並修正 Docker 來源路徑後重新觸發建置，待結果 |
| 1A | 固定來源中所有缺少於 Runtime 的 ES2M 檔案 | 新增 `import_es2m_latest_missing_files.py`；逐檔 SHA-256 驗證，只補缺檔、不覆蓋既有 KING；排除 `data/`、`log/`、編譯物件及時間戳備份，衝突輸出 JSON | 已加入 Docker builder 與單元測試；等待最新建置結果；不是全部移植完成 |
| 2 | 最新來源的戰鬥核心、技能與職業成長 | 逐檔比較 Original／ES2M／KING，檢查呼叫鏈、存檔與數值回歸 | HOLD，待分批執行 |
| 3 | 其他新增地圖、NPC、物品與任務 | 依區域及依賴分批匯入；每批需出口／依賴／Runtime Journey 驗證 | 待執行 |
| 4 | 其餘 537 新增、160 修改及 3 KING-only 路徑 | 依分類逐批處理；新增不等於安全，修改不得直接覆蓋 | 待逐項核銷 |
| 5 | 帳號字元與長度、中文名稱長度等玩家可見政策 | 將來源規則、KING 行為、E2E 預期一併核對 | HOLD，需列入正式政策移植批次 |

## 第一批完成條件

- Actions checkout 必須遞迴取回固定 ES2M submodule。
- Docker builder 確認最新來源的 `mudlib/d/qiaoyin` 存在。
- `import_es2m_world_zones_safe.py` 對該來源區域執行缺檔補入與字面依賴檢查。
- `import_es2m_latest_missing_files.py` 依 1,678 筆固定 manifest SHA 逐檔驗證，將來源中缺少於 Runtime 的檔案加入生成 Runtime，保留所有同名 KING 衝突並輸出清冊。
- 任一同名異內容或未解依賴都必須讓建置失敗，不可默默略過。
- 即使 Docker PASS，也只代表檔案階段通過；出口連通、NPC／商店／任務與實際玩家路徑仍需另行驗證。

## 目前未完成項目

全量整合尚未完成。第一個 Docker 嘗試 `39026936503` 因當時 workflow 未設定遞迴 checkout submodule，在第 58/75 步找不到最新來源目錄而失敗；不是 LPC 或地圖內容測試失敗。已把 `submodules: recursive` 加入 workflow，並新增完整缺檔加法匯入流程後重新觸發建置。後續檢查上游 Git tree 又確認來源實際路徑為 `source/upstream/mudlib`，先前 Dockerfile 使用錯誤的 `.../mudlib` 路徑；已修正全部 4 個引用並再次觸發完整建置。最新實際複製數、衝突數與建置結果仍待 Actions 回報。不可將來源 submodule、差異清冊、檔案補入或 Docker 建置成功單獨視為「所有 ES2M 更新已寫入 KING」。每批通過後更新本紀錄與相容性矩陣，直至每一個來源差異都有可追溯的移植結果或明確 HOLD 理由。
