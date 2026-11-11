# ES2-KING 遠端自主開發代理工作指引

本文件由專案擁有者授權的 GitHub Actions 遠端工作流程使用。所有修改只在指定開發分支進行。

## 任務開始前
1. 讀取 `AGENTS.md`、`docs/status/CURRENT_M30_STATUS.md`、`ROADMAP_M31.md`，並查閱相關最新狀態、Evidence、Roadmap、測試與程式。
2. 以目前 checkout 的分支 HEAD 為唯一程式事實來源。不可相信舊對話或舊 SHA 代表目前版本。
3. 對照已完成項目，只選擇 1～3 個最小、明確、可驗證且尚未完成的工作項目。先做最高優先、風險最低的一項，再依序繼續。
4. 如果沒有可安全確認的下一項、需要使用者決策、缺少必要證據或缺少安全測試，停止修改並記錄 BLOCKED／UNKNOWN，不可自行補造。

## 不可違反的邊界
- 不得修改 `original_es2/**`、`source/**`、`legacy_sources/**`、`king_library/**`、`.github/workflows/**`、`AGENTS.md` 或任何未明確列入允許範圍的路徑。
- 可修改的範圍僅限 `es2_king_expansion/**`、`scripts/**`、`tests/**`、`docs/status/**` 與本工作流程專用的 `docs/automation/last-run-report.md`、`docs/automation/selected-tests.txt`。
- 不可 Merge 任何 PR，尤其 PR #13 必須保持 OPEN／NOT MERGED。
- 不得跳過測試、偽造 PASS、把靜態檢查說成 Runtime PASS，或把推論當成已確認事實。
- 不得改動測試來掩蓋產品程式失敗。測試清單只能列出已存在、且本輪未修改的測試檔。
- 不可執行部署、刪除大量資料、存取／輸出秘密、讀取或寫入 API Key、token 或憑證。
- 新增／修改的 ES2-KING 程式與工程腳本需有清楚的繁體中文註解；不可為了註解而污染 Original ES2 原始碼。
- 採增量修改與最小必要測試；不可重做已完成工作，不可為了讓測試變綠而跳過或降低測試標準。

## 修改與修復循環
1. 先閱讀相關實作、既有測試、錯誤記錄與來源證據。
2. 提出並實作最小修正；每個任務都要指出修改目的與風險。
3. 選擇與本輪變更直接相關的既有測試，最多列 5 個。每一行只能是以下格式之一：
   - `scripts/test_<名稱>.sh`
   - `scripts/test_<名稱>.py`
   - `scripts/test_<名稱>.mjs`
   清單放在 `docs/automation/selected-tests.txt`。不可加參數、shell 語法、絕對路徑或任意命令。
4. 在工作環境中實際執行所選測試；FAIL 時先讀完整錯誤、修正後重測。最多 2 次修復循環；仍 FAIL 就停止並寫清楚阻塞，不可宣稱完成。
5. 不可把尚未執行的測試列為 PASS。若沒有可用且相關的既有測試，停止該任務並說明缺少哪一個測試，不得以空測試清單通過。
6. 不要自行 git commit 或 git push；由工作流程在獨立驗證通過後處理。

## 報告格式
每輪必須建立或更新 `docs/automation/last-run-report.md`，使用繁體中文並包含：
- 執行日期／分支
- 本輪選定任務與選擇理由
- 修改檔案與實際變更
- 測試指令及每項真實結果
- 尚未驗證的部分、風險或阻塞
- 下一個待辦項目
- `AGENT_RESULT: PASS` 或 `AGENT_RESULT: BLOCKED`
只有確實完成修改並且測試在代理執行環境中通過，才可使用 PASS；最終 GitHub Actions 還會獨立重跑清單中的測試。

## 收尾
完成 1～3 個小項後即停止，將剩餘待辦寫入報告。不要擴大範圍、不要改工作流程本身、不要 Merge PR。