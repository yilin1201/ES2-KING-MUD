# ES2M → KING 匯入核對紀錄（2026-10-21）

## 本次核對結論

**結果：已存在的 ES2M 匯入成果經 Repository 靜態核對；本次未重新執行 Runtime 匯入，也未宣稱 Runtime／GitHub Actions PASS。**

- ES2M 固定來源版本：`71693beb79ced81d51719ea1ccf7c02c641ca9b0`
- 固定 Original ES2 基線：`cc45c06af4852380e5148dad3c9d53ff06854f2c`
- 持久化 Overlay：`es2m_snapshot/latest_import_overlay/71693beb/`
- Overlay manifest：`es2m_snapshot/latest_import_overlay/71693beb/manifest.json`
- Manifest 狀態：`CONFLICT_FREE_IMPORTS_ONLY`
- Manifest 宣告筆數：389；`files` 實際項目數：389
- Manifest 中三個延期檔案均不在匯入清單，且均有明確排除理由。

## Route B：登入 UI 協定延期清單

下列檔案保留在 ES2M 來源證據，不進入本批 KING Runtime Overlay；不刪除來源快照：

| 路徑 | 排除理由 |
|---|---|
| `feature/user/input.c` | 登入提示、性別選單與輸入行尾協定需另批完整適配 |
| `adm/simul_efun/cursor.c` | 與 input.c 配對的數字選單映射，避免新舊協定混搭 |
| `feature/user/more.c` | HELP 翻頁鍵行為改變，需另批測試 |

共用設定檔：`scripts/es2m_ui_protocol_exclusions.json`。三方合併程式 `scripts/merge_es2m_latest_changes_safe.py` 與持久化 Overlay 程式 `scripts/sync_es2m_latest_import_overlay.py` 均讀取此設定。

## 保護與核對規則

1. 以固定 Original ES2／已存 ES2M snapshot 作三方合併基線；衝突保留 KING 版本，不強行覆蓋。
2. 匯入 Overlay 只保存成功匯入的加法檔與無衝突合併檔；manifest 記錄每個檔案 SHA-256。
3. 三個延期檔案不得出現在 Overlay `files` 清單；必須保留在 `excluded` 清單，分類為「登入 UI 協定批次」。
4. 帳號／顯示名稱政策適配器與既有測試仍保留；本次未將來源契約測試當成實際創角 E2E。
5. 不修改 `build/original-es2-races-phase2`，不合併 PR，不部署 Render；凍結武學、Score UI 與 `admin.c` 不在本次修改範圍。

## 驗證狀態

| 項目 | 狀態 | 證據／限制 |
|---|---|---|
| 固定 ES2M 來源版本 | PASS（靜態） | manifest 的 `source_commit` 與固定版本一致 |
| Overlay manifest 數量 | PASS（靜態） | `file_count=389` 且 `len(files)=389` |
| 三個 UI 協定檔排除 | PASS（靜態） | `excluded` 有三筆；`files` 不包含這三個路徑 |
| 共用排除設定 | PASS（靜態） | 三方合併與 Overlay 程式均讀取同一 JSON 設定 |
| 389 個檔案逐一 SHA-256 | NOT RUN（本次未執行測試程式） | 現有測試 `scripts/test_sync_es2m_latest_import_overlay.py` 會逐一檢查，但本紀錄不把未執行的測試寫成 PASS |
| 登入政策單元測試 | NOT RUN | `scripts/test_apply_es2m_login_policy_runtime.py` 尚需在該 HEAD 的 CI／runner 實際執行 |
| 生成 Runtime 登入政策契約 | NOT RUN | `scripts/test_numeric_id_policy_runtime.py --runtime <generated-runtime>` 尚需實際執行 |
| 數字帳號、單字中文名稱與既有帳號 E2E | NOT RUN | 必須用實際 Runtime 驗證；靜態檔案核對不等於遊戲通過 |
| 此分支 HEAD 的 GitHub Actions | NOT VERIFIED | 目前沒有可引用的該 HEAD Actions 步驟結果；不得宣稱 PASS |

## 下一步

1. 在 GitHub Actions／實際建置環境執行 `scripts/test_sync_es2m_latest_import_overlay.py`，確認 389 個持久化檔案逐一符合 SHA-256。
2. 實際執行 `scripts/test_apply_es2m_login_policy_runtime.py` 與 `scripts/test_numeric_id_policy_runtime.py --runtime <generated-runtime>`。
3. 以 Runtime E2E 測試帳號 `7probe`、單字顯示名稱「熊」，並執行既有英文字母帳號回歸測試。
4. 確認 Runtime 的三個排除檔案 SHA-256 均與固定 Original ES2 基線一致；確認原始確認提示與性別選單仍為 Original 格式，且瀏覽器相容補丁不會誤觸發。
5. 所有必要 Gate 通過後，才進行隔離的 liuh-ken 載入測試；以 `debug.log` 的 `preloaded` 且無 `failed to preload` 作為載入證據。

**本文件是核對紀錄，不代表本次重新匯入或任何尚未執行的測試已通過。**
