# ES2M → ES2-KING 相容性分批閘門（2026-10-17）

## 目的與硬性規則

- 本文件屬於 ES2M 證據線；只記錄分析與驗證規則，不直接改寫正式 Runtime。
- 每一批在任何程式移植前，必須先完成逐檔差異、相依性盤點、相容性分類、驗證計畫及回復計畫。
- 允許分類僅有 `COMPATIBLE`、`ADAPTER_REQUIRED`、`CONFLICT`、`UNKNOWN`。未取得證據時一律 `UNKNOWN`，不得推定相容。
- `71693beb79ced81d51719ea1ccf7c02c641ca9b0` 是本輪待分析的 ES2M 來源版本；來源差異不等於可以直接移植。
- 不整目錄覆蓋；不因測試未跑、日誌缺失或 Actions pre-step failure 而宣稱 PASS。
- 每批只處理該批允許的檔案；完成驗證後才決定下一批。回復時撤回該批專用 commit／patch，不能以回復方式覆蓋其他批次成果。

## 分批與閘門

| 批次 | 初始分類 | 範圍與限制 | 驗證方式 | 回復方式 |
|---|---|---|---|---|
| 1. 戰鬥核心 | `UNKNOWN`（逐檔分析後更新） | 先分析 `combatd.c`、`feature/char/combat.c`、`feature/char/skill.c` 及呼叫端；先不移植。 | 來源差異／呼叫圖、API／參數契約、相關靜態測試；之後才做最小 Docker 建置及 Runtime 戰鬥情境驗證。 | 以該批獨立 commit 還原；確認 Runtime 回到移植前雜湊／測試基線。 |
| 2. 職業經驗／等級 | `UNKNOWN`（HOLD，禁止開始移植） | 71693beb 的書生、和尚、道士、方士經驗／升級變更，涉及 `score.c`、職業 daemon、經驗門檻及角色保存；必須先完成差異分析及與 KING 現有規則的相容性確認。 | 對照來源版本與 KING／Original 的 `score.c`、職業經驗函式、等級門檻、儲存／讀取生命週期；建立數值邊界案例與角色存檔回歸測試。未完成不得標 PASS。 | 不先改正式檔；若試驗分支已改動，整批回退專用 commit，確認等級、經驗、存檔與登入結果恢復。 |
| 3. 技能成長 | `UNKNOWN`（逐檔分析後更新） | 職業經驗批次解除 HOLD 前，不把共用等級／經驗依賴一起帶入；先辨識技能成長與戰鬥成長的獨立範圍。 | 技能 API／經驗來源契約、技能等級邊界測試、學習／啟用／停用及存檔回歸。 | 回退該批獨立 commit，重跑本批指定測試並與基線比對。 |
| 4. 其他內容 | `UNKNOWN`（逐檔分析後更新） | 地圖、NPC、物品、任務、文件等按依賴分群；逐檔決定是否候選匯入，不以整目錄替換。 | 路徑／引用完整性、出口／目的地檢查、NPC／物品依賴檢查及對應靜態或 Runtime Journey。 | 回退該分群專用 commit；確認不刪除 KING 原有內容且路徑／引用恢復。 |

## 開工前必填欄位

每一批開始前，須在稽核記錄填寫：

1. 上游 commit、原始路徑、KING 對應路徑及 SHA-256。
2. 變更類型（新增／修改／刪除／重新命名）與差異摘要。
3. 相容性分類：`COMPATIBLE`／`ADAPTER_REQUIRED`／`CONFLICT`／`UNKNOWN`，附證據與理由。
4. 受影響 API、資料結構、呼叫端、角色資料與 Runtime 生命週期。
5. 可重現的驗證命令、預期結果、實際結果與證據位置。
6. 回復 commit／patch、回復後的檢查命令及基線。
7. 明確的 GO／HOLD 決策與審查結果。

## 本輪現況

- 上游目標：`71693beb79ced81d51719ea1ccf7c02c641ca9b0`。
- 293 路徑差異的逐檔清單與稽核報告保留在整合分支；不留在 PR #13 phase2 分支。
- 職業經驗／等級批次：`HOLD`，等待差異分析，特別是 `score.c` 及四類職業的經驗規則。
- `look.c` Docker 阻塞：根因已由使用者本機重播 `beb9e673` 確認；Expansion 的 Python replacement 把字面反斜線 n 寫進 LPC 原始碼。已修正為真正換行，加入輸出防呆，並在 Dockerfile 加入 Neolith 實際載入 `/cmds/std/look` 的 gate。狀態：`FIX COMMITTED / RUNTIME PRELOAD PENDING`。第一次完整 Docker builder 驗證 run `38974855888` 在 Docker Step 21/73 因載入測試未回報 PASS 而失敗；該測試未顯示獨立 DebugLogFile，因此無法從 stdout 判定是 app 未啟動或 LPC 載入錯誤。已修正測試設定，使用獨立 `neolith.look-preload.conf`、停用測試 Port，並擷取 stdout 與 `mudlib/log/look-preload-debug.log`。第二次完整 Docker builder 驗證 run `38975123264` 正在執行；未取得結果前不得標記 PASS。
- 數字開頭帳號：Pinned Original ES2 `logind.c` 的 `check_legal_id()` 明確只接受 3–12 個小寫英文字母，數字會被拒絕。依 preserve Original ES2 原則，保留登入規則；E2E 改為驗證數字開頭 ID 被拒絕且不產生存檔，不修改 `logind.c`。
- 低成本整合語法／來源契約閘門：GitHub Actions run `38974801566`（`ES2-KING Integration Look Gate`）已成功；涵蓋 Bash、Python、Node 語法，假人來源契約、12 種族／出生屬性契約與數字帳號拒絕政策。此結果不代表 Docker／Neolith Runtime PASS。
- Docker builder 驗證：已在整合工作流程加入明確 opt-in 的完整 builder job；本次提交會要求執行 `docker build --progress=plain --target builder`，只建置、不推送、不部署。結果待 Actions 回報。
- 全量／範圍式來源盤點：程式與唯讀工作流程已放入整合分支，但尚未有成功執行產生的 `UPSTREAM_HEAD.txt`、`IMPORT_PLAN.json` 證據。
- PR #13 保持 OPEN / NOT MERGED。
