# ES2M → KING Route B 整合核對紀錄（2026-10-21）

## 範圍與安全界線

- Repository：`yilin1201/ES2-KING-MUD`
- 工作分支：`integration/es2m-audit-import-20261017`
- 核對時分支 HEAD：`1e05b94419a8d1985b7af0fb8775ceee0300edac`
- ES2M 固定來源 commit：`71693beb79ced81d51719ea1ccf7c02c641ca9b0`
- 本次只記錄已核對結果；不合併 PR、不部署 Render、不修改 `build/original-es2-races-phase2`，不刪除 ES2M 原始來源或快照。

## 已核對結果

| 項目 | 結果 | 證據／限制 |
|---|---|---|
| 匯入清冊 | PASS（清冊結構） | `es2m_snapshot/latest_import_overlay/71693beb/manifest.json`：`file_count=389`，實際 `files` 項目數亦為 389；來源 commit 與固定 pin 相符。 |
| 三項 UI 協定排除 | PASS（清冊） | `feature/user/input.c`、`adm/simul_efun/cursor.c`、`feature/user/more.c` 均未列入 389 個匯入檔；`excluded` 保留三筆路徑、原因及「登入 UI 協定批次」分類。 |
| 共享排除設定 | PASS（原始碼檢查） | `scripts/merge_es2m_latest_changes_safe.py` 與 `scripts/sync_es2m_latest_import_overlay.py` 都讀取 `scripts/es2m_ui_protocol_exclusions.json`。 |
| Overlay 檔案集合 | PASS（GitHub 檔案查核） | 三項排除路徑在持久化 overlay 的 `mudlib/` 下查無檔案；`feature/user/edit.c` 仍存在，未被誤列排除。 |
| 測試覆蓋 | PASS（測試程式存在） | `scripts/test_merge_es2m_latest_changes_safe.py` 含三項排除與 KING 保留測試；`scripts/test_sync_es2m_latest_import_overlay.py` 含 389 檔 manifest、排除清單及逐檔 SHA-256 檢查。 |
| Docker 結構 | PASS（文字計數） | 目前 `Dockerfile` 共 3 個 `FROM`，其中 1 個 `AS builder`。這是結構檢查，不代表映像已成功建置。 |
| 數字帳號／單字顯示名稱 | SOURCE CHECK ONLY | `scripts/test_numeric_id_policy_runtime.py` 檢查生成 Runtime 的 `logind.c/.lpc` 規則；本次沒有實際建立 Runtime 執行該測試。 |
| WebTelnet 創角提示相容 | SOURCE CHECK ONLY | `webtelnet/public/character-input.mjs` 仍保留 Original ES2 與 ES2M 提示相容邏輯；本次未執行瀏覽器 E2E。 |
| GitHub Actions | NOT VERIFIED | 本次對該 HEAD 查詢到的 PR-triggered workflow runs 與 commit status 清單為空；不能據此宣稱 Actions PASS。 |
| Runtime／實際登入 E2E | NOT RUN | 尚未證明數字帳號、單字中文名稱、既有字母帳號回歸在實際遊戲中通過。 |
| 原始檔 SHA-256 對照 | NOT RUN | 尚未提供生成 Runtime 中三個排除檔與固定 Original baseline `cc45c06a` 的實際 SHA-256 證據。 |

## 實際查核到的檔案識別碼

- `es2m_snapshot/latest_import_overlay/71693beb/manifest.json` blob：`1bfaca11cacc931c8fb3e6afd20d1f488904fc96`
- `scripts/es2m_ui_protocol_exclusions.json` blob：`8bb5df7bac5bbb50b528c8e2f01c680b704ae883`
- `scripts/merge_es2m_latest_changes_safe.py` blob：`9edf1d5e749939641537f75e470c4036663998a2`
- `scripts/sync_es2m_latest_import_overlay.py` blob：`fad14578d045319d2c256937dff8098b3f8c0a02`
- `Dockerfile` blob：`b53d727cda5dec9fcfe554a852a97f8d635c32b8`
- `webtelnet/public/character-input.mjs` blob：`fd631edaf50d250f4bcd0c07e29f423795150c5f`

## 下一個執行順序

1. 讓 GitHub Actions 在此工作分支的最新 HEAD 實際執行 overlay／merge／登入政策相關測試，讀取每個 job 與 step 的結果及 logs。
2. 若 Actions 通過，才在生成 Runtime 上執行 `scripts/test_numeric_id_policy_runtime.py`，並核對三個排除檔案的 Runtime SHA-256。
3. 執行登入 E2E：數字帳號 `7probe`、單字顯示名稱「熊」、既有字母帳號回歸；確認 Original ES2 的確認提示與性別選單不被 WebTelnet 相容邏輯誤觸發。
4. 全部必要 gate 通過後，才進入獨立的 liuh-ken preload/load 驗證；否則依實際錯誤修正，不放寬測試或逾時設定。

**狀態聲明：** 本紀錄是 GitHub 來源與清冊核對結果，不等同於測試已執行、Runtime PASS、遊戲可玩或正式部署完成。
