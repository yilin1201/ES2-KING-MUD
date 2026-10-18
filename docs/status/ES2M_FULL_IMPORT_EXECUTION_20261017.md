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
| 1A | 固定來源中所有缺少於 Runtime 的 ES2M 檔案 | 新增 `import_es2m_latest_missing_files.py`；逐檔驗證 Git blob SHA-1，只補缺檔、不覆蓋既有 KING；排除 `data/`、`log/`、編譯物件及時間戳備份，衝突輸出 JSON | 已加入 Docker builder 與單元測試；等待最新建置結果；不是全部移植完成 |
| 1B | 相對固定 Original ES2 已修改的 162 個來源路徑 | 新增 `merge_es2m_latest_changes_safe.py`；以 Original 為三方合併基底，先驗證 Original／ES2M blob ID；非重疊修改寫入生成 Runtime，衝突保留 KING 並輸出 HOLD 清冊 | 已加入 Docker builder 與單元測試；等待完整建置；衝突仍需逐檔適配 |
| 2 | 最新來源的戰鬥核心、技能與職業成長 | 逐檔比較 Original／ES2M／KING，檢查呼叫鏈、存檔與數值回歸 | HOLD，待分批執行 |
| 3 | 其他新增地圖、NPC、物品與任務 | 依區域及依賴分批匯入；每批需出口／依賴／Runtime Journey 驗證 | 待執行 |
| 4 | 其餘 537 新增、160 修改及 3 KING-only 路徑 | 依分類逐批處理；新增不等於安全，修改不得直接覆蓋 | 待逐項核銷 |
| 5 | 帳號字元與長度、中文名稱長度等玩家可見政策 | 將來源規則、KING 行為、E2E 預期一併核對 | HOLD，需列入正式政策移植批次 |

## 第一批完成條件

- Actions checkout 必須遞迴取回固定 ES2M submodule。
- Docker builder 確認最新來源的 `mudlib/d/qiaoyin` 存在。
- `import_es2m_world_zones_safe.py` 對該來源區域執行缺檔補入與字面依賴檢查。
- `import_es2m_latest_missing_files.py` 依 1,678 筆固定 manifest Git blob ID 逐檔驗證，將來源中缺少於 Runtime 的檔案加入生成 Runtime，保留所有同名 KING 衝突並輸出清冊。
- `merge_es2m_latest_changes_safe.py` 針對 `original_status=CHANGED_FROM_PINNED_ORIGINAL` 的路徑進行三方合併；只有無衝突結果會寫入生成 Runtime，衝突一律保留 KING 現有版本。這不是直接修改保存的 Original ES2，也不會把衝突當成已完成。
- 任一同名異內容或未解依賴都必須讓建置失敗，不可默默略過。
- 完整 builder 成功時，workflow 會擷取橋隱、加法補檔與三方合併 JSON 報告，附加到 Actions Summary 並上傳 14 天 artifact，供後續逐檔處理衝突。
- 即使 Docker PASS，也只代表已執行的檔案／合併與既有回歸閘門通過；出口連通、NPC／商店／任務與實際玩家路徑仍需另行驗證。

## 目前未完成項目

全量整合尚未完成。第一個 Docker 嘗試 `39026936503` 因當時 workflow 未設定遞迴 checkout submodule，在第 58/75 步找不到最新來源目錄而失敗；不是 LPC 或地圖內容測試失敗。已把 `submodules: recursive` 加入 workflow，並新增完整缺檔加法匯入流程後重新觸發建置。後續檢查上游 Git tree 又確認來源實際路徑為 `source/upstream/mudlib`，先前 Dockerfile 使用錯誤的 `.../mudlib` 路徑；已修正全部 4 個引用並再次觸發完整建置。最新實際複製數、三方合併數、衝突數與建置結果仍待 Actions 回報。不可將來源 submodule、差異清冊、檔案補入或 Docker 建置成功單獨視為「所有 ES2M 更新已寫入 KING」。每批通過後更新本紀錄與相容性矩陣，直至每一個來源差異都有可追溯的移植結果或明確 HOLD 理由。

## 實際匯入結果更新（GitHub Actions Run 39039333422）

來源固定為 `71693beb79ced81d51719ea1ccf7c02c641ca9b0`；本節是 Actions 真實輸出，不是估算。

| 階段 | 實際結果 | 解讀 |
|---|---:|---|
| 橋隱區域依賴檢查 | staged 61、resolved dependencies 170、unresolved 0 | 檔案階段通過，不代表遊戲任務已通關 |
| 全來源加法補檔 | copied 186、identical 1,135、preserved conflicts 350、excluded 7 | 只補缺檔；同名不同內容不覆蓋 |
| Original／KING／ES2M 三方合併 | source replaced 102、already source 23、merged 6、preserved conflicts 29、excluded 2 | 29 個真正三方合併衝突仍保留 KING |
| 持久化匯入 overlay | 294 個無衝突檔案 | 已寫入 `es2m_snapshot/latest_import_overlay/71693beb/`，並驗證 SHA-256 |
| Runtime 套用驗證 | `ES2M_OVERLAY_APPLY_PASS 294` | 生成 Runtime 與已持久化的 294 個檔案逐檔一致 |

注意：加法補檔的 350 個衝突與三方合併的 29 個衝突有路徑重疊，不能直接相加當成 379 個獨立檔案。已新增衝突分類器，將交叉核對清單區分為「已由三方流程處理」、「ES2M 與 Original 相同但 KING 有自訂差異」及「仍需適配的來源變更」。

### 建置阻塞與目前狀態

Run `39039333422` 的來源匯入階段、overlay 持久化及靜態檢查均成功；完整 Runtime 建置仍因創角 E2E 未收到「您的使用者代號」提示而失敗。Bridge 日誌顯示 WebSocket 已開啟、TCP 曾連上 MUD listener，但連線隨即被關閉，尚未取得登入提示。這是 Runtime E2E 阻塞，不能視為 ES2M 匯入失敗，也不能宣稱完整遊戲驗證通過。

後續工作：
1. 讀取衝突分類器報告，先處理真正有 ES2M／Original 差異且尚未合併的項目。
2. 針對 29 個三方衝突逐檔比對來源、KING 改動與呼叫鏈，按批次安全適配。
3. 追查創角 E2E 的 MUD 連線立即關閉問題；不以跳過 E2E 或放寬成功條件掩蓋錯誤。
4. ES2M 帳號英數字與 1 字元顯示名稱政策已建立獨立 Runtime adapter 及測試；仍須以實際創角／存檔／重新登入 E2E 證實。
5. PR #13 維持 OPEN / NOT MERGED；Phase 2 固定基線不修改。



## ES2M 上游更新候選快照（2026-10-19）

本次重新檢查上游 `wolfer168/es2-webmud`，最新 HEAD 為 `8baf4c9d39feafd56804194b282cea60e3f166ac`，相對原固定來源 `71693beb79ced81d51719ea1ccf7c02c641ca9b0` 前進 40 個提交、82 個差異路徑（28 modified、39 added、9 removed、6 renamed）。

最新上游的 73 個現行檔案已逐檔保存到獨立候選快照 `es2m_snapshot/latest_source_candidate/8baf4c9d/`，並以 Git blob SHA 對照上游 tree；核對結果為 73/73 一致，SHA mismatch = 0。9 個上游刪除路徑只記錄在 manifest，沒有刪除 KING 檔案。

完整稽核：`docs/status/ES2M_UPDATE_20261019_AUDIT.md`。
逐檔清冊：`es2m_snapshot/latest_source_candidate/8baf4c9d/manifest.json`。

本次只建立可追溯來源候選快照，**不等於已套用到生成 Runtime，也不代表遊戲驗證通過**。分類結果：
- 39 個煉丹／藥草相關來源：候選審查，未套用 Runtime。
- 4 個新增技能：HOLD，依既定順序逐項驗證。
- 2 個戰鬥核心檔案：HOLD。
- `d/snow/npc/teacher.c`：保留 KING 自訂版本。
- 15 個其他修改檔：相容性審查 HOLD。
- 9 個上游刪除路徑：只記錄，不對 KING 執行刪除。

下一步應先檢查候選檔案的依賴與 KING 同名衝突，再將可獨立驗證的新增內容分批匯入；Docker、E2E 與相關回歸閘門未通過前，不移植戰鬥核心或技能。PR #13 維持 OPEN / NOT MERGED；Original ES2 Phase 2 分支未修改；Render 未部署。
