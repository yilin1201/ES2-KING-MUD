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
- `look.c` Docker 阻塞：根因已由使用者本機重播 `beb9e673` 確認；Expansion 的 Python replacement 把字面反斜線 n 寫進 LPC 原始碼。已修正為真正換行，加入輸出防呆，並在 Dockerfile 加入 Neolith 實際載入 `/cmds/std/look` 的 gate。狀態：`FIX COMMITTED / RUNTIME PRELOAD PENDING`。第一次完整 Docker builder 驗證 run `38974855888` 在 Docker Step 21/73 因載入測試未回報 PASS 而失敗；該測試未顯示獨立 DebugLogFile，因此無法從 stdout 判定是 app 未啟動或 LPC 載入錯誤。已修正測試設定，使用獨立 `neolith.look-preload.conf`、停用測試 Port，並擷取 stdout 與 `mudlib/log/look-preload-debug.log`。第二次完整 Docker builder 驗證 run `38975123264` 已失敗；獨立 DebugLogFile 證實只有 `Console EOF detected`，未出現 `look.c` 編譯錯誤。根因是 Docker 非互動環境下 console app 的 stdin 立即 EOF，測試在載入檢查前結束。已改用 FIFO writer 在測試期間維持 stdin 開啟，並啟動第三次完整 Docker builder 驗證 run `38975300719`；結果待回報。
- 帳號／中文名稱長度政策：`HOLD / POLICY NOT DECIDED`。使用者提供的版本證據顯示固定原版 `cc45c06a` 僅接受 `a–z`、3–18 位元組；ES2M `71693beb79ced81d51719ea1ccf7c02c641ca9b0` 接受英文字母與數字、1–18 位元組；Phase 2 Runtime 目前仍是僅接受 `a–z`、3–18 位元組。這是兩項玩家可見行為差異，不可只處理數字帳號而忽略中文名稱長度。現有 E2E 的 `7probe` 案例必須保留，並明確標示為政策決策閘門；政策未決前，不得把它改成預期成功、移除案例，或宣稱 ES2M 創角相容性已通過。現有 Runtime 拒絕 `7probe` 僅代表觀察到的基線行為，不等於已核定採用原版政策。
- 低成本整合語法／來源契約閘門：GitHub Actions run `38974801566`（`ES2-KING Integration Look Gate`）已成功；涵蓋 Bash、Python、Node 語法，假人來源契約、12 種族／出生屬性契約與數字帳號拒絕政策。此結果不代表 Docker／Neolith Runtime PASS。
- Docker builder 驗證：已在整合工作流程加入明確 opt-in 的完整 builder job；本次提交會要求執行 `docker build --progress=plain --target builder`，只建置、不推送、不部署。結果待 Actions 回報。
- ES2M 最新來源固定與全量盤點：已將 `wolfer168/es2-webmud@71693beb79ced81d51719ea1ccf7c02c641ca9b0` 固定為 Git submodule（子模組：以固定上游 commit 連結完整來源，不複製或覆蓋 KING Runtime），路徑 `source/es2m_updates/20261017_71693beb/upstream-es2-webmud`；完整 1,678 個 `source/upstream/mudlib` 檔案清單寫入 `docs/status/ES2M_SOURCE_SYNC_MANIFEST_20261017.json`。與現有 `es2m_snapshot/mudlib` 比對：981 個檔案內容相同、160 個檔案不同、537 個上游檔案未出現在目前快照、3 個快照檔案未出現在上游，合計 700 個差異路徑需審核。此統計是「完整上游與目前 ES2M 快照」比較，不等同於先前以不同基準得到的 293 路徑差異。另以固定 Original ES2 `cc45c06af4852380e5148dad3c9d53ff06854f2c` 的 `mudlib/` 為基準比較 1,678 個上游檔案：372 個與原版相同、162 個修改、1,144 個上游路徑在固定原版中不存在、2 個原版檔案在上游不存在。這是另一個獨立基準；「原版不存在」不代表可直接匯入，仍需逐項分類與依賴驗證。非相同檔案全部先標記 `HOLD_REVIEW`；這代表來源證據已固定與清單化，不代表 700 個檔案已寫入正式 Runtime。已另將上游戰鬥流程說明保存至 `docs/es2m_reference/ES2M_戰鬥流程說明_71693beb.md`，並加上外部證據標記。新增 `scripts/test_es2m_source_sync_manifest.py`，由低成本 GitHub Actions 驗證來源 commit、檔案數量、差異統計、HOLD 閘門與 submodule commit。
- PR #13 保持 OPEN / NOT MERGED。

## 71693beb 變更範圍的初步相容性判定（只盤點，不代表已移植）

來源 commit：`wolfer168/es2-webmud@71693beb79ced81d51719ea1ccf7c02c641ca9b0`，merge PR #48「職業經驗補齊（書生、和尚、道士、方士）、閃躲招架修正、戰鬥流程文件」。本輪 293 個路徑差異中，以下是需優先處理的共用核心／成長檔案。

| 來源檔案 | 初步分類 | 已看到的差異與風險 | 下一個必要驗證 |
|---|---|---|---|
| `adm/daemons/combatd.c` | `ADAPTER_REQUIRED` | 新增特殊內功設定下空手命中後的 `force` 精確經驗，並修正未格擋時的訊息。KING overlay 已有 `improve_skill_exact()` 與 `restored_force_tick_exp()`；觸發時機與累計量不同，不能直接疊加。 | 比較命中事件、每回合內功成長與存檔後技能進度；確認不重複發放，再加空手／持武器／無特殊內功三組 Runtime 案例。 |
| `feature/char/combat.c` | `ADAPTER_REQUIRED` | 玩家停用 dodge 時直接跳過閃躲判定，並調整招架失敗敘述。這會改變目前「未映射身法仍使用基本 dodge 能力」的行為。 | 驗證玩家停用／啟用 dodge、NPC 防守、招架減傷與招架訊息；只改玩家指定狀態，不影響 NPC。 |
| `feature/char/skill.c` | `ADAPTER_REQUIRED` | 新增舊技能 ID 遷移（`sanmeendo` → `ksanmando`、`tiger-force` → `tiger force`），並新增特殊法術技能升級時的 magic mastery。KING overlay 已有精確成長與存檔恢復相容層，但尚未看到相同的 ID 遷移函式。 | 追查 `feature/save.c` restore 呼叫鏈、技能／學習進度／旗標與映射表遷移；測試新舊存檔與一次升多級情境，避免丟失或重複累積。 |
| `adm/daemons/chard.c` | `CONFLICT / POLICY HOLD` | 移除擊殺時扣除 reputation 與 martial fame 的規則。來源註解寫有「使用者定案」，但不把另一條來源分支的註解自動當成 KING 正式政策。 | 比較 KING 目前擊殺／聲望／黑道聲望規則；在 KING 政策確認前不移植。 |
| `cmds/std/conjure.c`、`cmds/usr/praise.c`、`daemon/class/taoist.c`、`daemon/skill/absorption.c`、`archaic_attainment.c`、`literate.c`、`taoism-spells.c` | `PROGRESSION BATCH HOLD` | 涉及 magic、alchemy、martial fame、negative fame、buddhology、literature mastery、literature、spell mastery 等累計公式與觸發條件；新舊等級補發可能造成重複計分。 | 逐一核對 KING score 儲存／顯示鍵、既有升級回呼、舊角色補差額邏輯與數值邊界測試。此來源差異清單中沒有 `score.c` 變更，不代表 KING 的 score 顯示與存檔相容性已驗證。 |

以上均為來源差異盤點與初步分類，不是 Runtime 移植。職業經驗／等級批次仍維持 HOLD；所有程式變更必須在本次 look.c/Docker 閘門與既有回歸驗證完成後，另以獨立批次執行。


## 創角政策決策閘門（新增，2026-10-17）

目前不選擇 A 或 B；兩項差異均維持 `HOLD`，避免把 Runtime 既有行為誤認成正式政策。

| 項目 | 固定原版 `cc45c06a` | ES2M `71693beb` | Phase 2 Runtime 現況 | 決策狀態 |
|---|---|---|---|---|
| 帳號字元 | 僅 `a–z` | 英文字母及 `0–9` | 僅 `a–z` | `HOLD` |
| 帳號長度 | 3–18 位元組 | 1–18 位元組 | 3–18 位元組 | `HOLD` |
| 中文名稱長度 | 3–18 位元組 | 1–18 位元組 | 尚待 Runtime 實測確認 | `HOLD` |
| `7probe` 測試 | 預期拒絕 | 預期允許 | 目前觀察為拒絕 | 保留案例，不先裁定預期 |

政策選擇前的必做事項：

1. 保留 `7probe` E2E 案例，不刪除、不改成成功預期；將其視為待核定政策的差異案例，而非一般測試故障。
2. 查明 E2M 來源 `logind.c` 中帳號檢查與中文名稱檢查的完整呼叫鏈，並與 KING 創角補丁比較；不得整檔覆蓋。
3. 在生成後的實際 Runtime 中確認兩項檢查的最短／最長長度、字元集、提示文字、登入／註冊流程與存檔副作用。
4. 由專案政策明確選定：A 採 ES2M 兩項規則並走正式相容性移植；或 B 保留原版規則並將兩項差異記錄為刻意偏離。選定前禁止改動正式行為。
5. 政策決定後，同步更新 Runtime、E2E 預期、提示文字、相容性文件與回歸案例；通過實際登入／創角測試後才可解除 HOLD。


## ES2M 最新來源全量匯入進度（2026-10-17）

### 已完成

- 上游來源固定：`wolfer168/es2-webmud@71693beb79ced81d51719ea1ccf7c02c641ca9b0`，透過 `.gitmodules` 與 gitlink 固定；來源可由 Git 子模組取回，沒有把上游內容誤當成 Original ES2。
- 全量清單：`docs/status/ES2M_SOURCE_SYNC_MANIFEST_20261017.json`，逐檔記錄路徑、上游 blob SHA、大小、目前快照 SHA、差異狀態與匯入狀態。
- 上游參考文件：`docs/es2m_reference/ES2M_戰鬥流程說明_71693beb.md`，標記為 ES2M 外部證據，不是 KING 正式 Runtime 規格。
- 驗證腳本：`scripts/test_es2m_source_sync_manifest.py`，並已加入低成本整合閘門。

### 全量比較結果

| 狀態 | 數量 | 處理規則 |
|---|---:|---|
| 與目前快照逐字相同 | 981 | 保留現有資料；相同不代表已完成 Runtime 相容性測試 |
| 上游有修改 | 160 | `HOLD_REVIEW`，逐檔分析後才可移植 |
| 上游新增／目前快照缺少 | 537 | `HOLD_REVIEW`，先檢查路徑、依賴、出口／呼叫端與衝突 |
| KING 快照獨有 | 3 | `KING_SNAPSHOT_ONLY_REVIEW`，不得因上游不存在而刪除 |

以上共 700 個差異路徑。此為來源快照比對數量，不是已匯入 Runtime 的數量。

### Runtime 匯入限制

- 不整目錄覆蓋、不刪除 KING 獨有檔案、不將 700 個差異直接複製到正式 Runtime。
- 逐檔分類為 `COMPATIBLE`、`ADAPTER_REQUIRED`、`CONFLICT` 或 `UNKNOWN`，記錄依賴、驗證、回復方式；只有取得證據並通過對應測試後才匯入。
- 創角帳號字元／長度及中文名稱最短長度仍為 `HOLD / POLICY NOT DECIDED`；不能用整批同步繞過政策閘門。
- 職業經驗／等級與技能成長仍為 `HOLD`；戰鬥核心須分批做 API／數值／存檔與 Runtime 驗證。
- PR #13 保持 OPEN / NOT MERGED；Phase 2 固定基線不變。


### 與固定 Original ES2 的獨立比較

基準：`taedlar/es2_mudlib@cc45c06af4852380e5148dad3c9d53ff06854f2c` 的 `mudlib/`。

| 狀態 | 數量 | 意義 |
|---|---:|---|
| 上游與 Original 內容相同 | 372 | 內容雜湊一致；仍需依 KING 現況判斷是否已存在 |
| 上游修改 Original 檔案 | 162 | 修改既有原版行為，必須做三方差異與相容性審核 |
| 上游有、Original 無 | 1,144 | 可能是新增系統、內容或上游專用檔案；不得直接整批複製到 Runtime |
| Original 有、上游無 | 2 | 保留原版檔案，不因上游缺少而刪除 |

注意：以上比較只用於辨識來源差異，不是 1,144 個檔案都屬於「新功能」，也不是 162 個修改都應採用。需要依檔案功能、呼叫關係、依賴與實際 Runtime 行為再分類。
