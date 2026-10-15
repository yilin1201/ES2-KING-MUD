# KING 種族 Runtime 三方盤點清冊（2026-10-15）

## 目的與限制

本文件是本輪重新整合工作的盤點基線，不是「已通過實機測試」的宣告。只記錄來源、既有套用規則、目前已知差異及待補證據；本階段不修改遊戲邏輯、不覆蓋任何 Runtime 原始檔、不部署 Render。

- Repository：`yilin1201/ES2-KING-MUD`
- 基準分支：`build/original-es2-races-phase2`
- 本次盤點基準 HEAD：`25f5f2ac2daaa4e5ad130d0f3f79abccc1dea7a9`
- 本文件分支：`audit/king-race-runtime-inventory-20261015`
- Docker 固定 Original ES2 commit：`cc45c06af4852380e5148dad3c9d53ff06854f2c`（取自基準分支 Dockerfile）
- ES2M 最新來源 commit：`f21f59cecb55e5c3e31d2e97a7ef6d43783ecdcb`（依本輪提供的差異盤點紀錄；本文件尚未獨立重新抓取該上游 commit 驗證）
- Render：暫停
- PR #13：本輪查詢結果為 OPEN / NOT MERGED；基底分支 main，HEAD 為上述基準 HEAD。

## 狀態定義

- `COMPATIBLE`：已有證據支持相容；仍須依影響範圍決定是否需 Runtime 驗證。
- `ADAPTER_REQUIRED`：來源行為可保留，但需要明確接線或轉接層。
- `CONFLICT`：存在已確認的不相容或相互矛盾內容。
- `UNKNOWN`：證據不足，不能判定。
- `STATIC_PASS`：靜態檢查通過，不代表遊戲實際執行通過。
- `LOCAL_PASS`：本機測試實際通過，需附命令與紀錄。
- `RUNTIME_UNKNOWN`：尚無足夠的實際遊戲 Runtime 證據。
- `BLOCKED`：受環境、權限、網路或其他可重現阻礙限制。
- `FAIL`：有可重現證據確認失敗。

## 三方定義

1. **Pinned Original**：Dockerfile 所固定的 Original ES2 上游 commit；不可將第三方 ES2M 差異直接改稱 Original ES2。
2. **ES2M Snapshot**：Repository 中 `es2m_snapshot/mudlib/` 的保存快照。
3. **Generated Runtime**：Docker 流程先 bootstrap 固定 Original，再執行 `scripts/apply_race_phase2_runtime.sh`，之後執行 `scripts/apply_es2_king_expansion.sh` 所生成的測試環境。Runtime 檔案必須從實際生成目錄讀取雜湊；不得用 snapshot 雜湊冒充 Runtime 雜湊。

## 已確認的既有整合規則

`scripts/apply_race_phase2_runtime.sh` 會把 ES2M snapshot 的 12 個 race daemon 複製至 Generated Runtime，並將 `es2m_snapshot/mudlib/feature/char/score.c` 複製到 Runtime 的 `mudlib/feature/char/score.c`。因此：

- `feature/char/score.c` 是 phase2 **既有整合項目**，不是等待首次整合的檔案。
- 針對另一個外部 ZIP 的「不批准直接整合」，不代表撤銷 phase2 目前既有套用行為。
- Score UI 顯示層仍依凍結規則保護；`feature/char/score.c` 是角色成長核心邏輯，任何變更都要做相容性與回歸驗證。
- 靜態回歸腳本 `scripts/test_race_phase2_regression.sh` 會比較 12 個 Runtime race daemon 與 snapshot 檔案，並檢查登入種族清單與接受邏輯；其輸出明確不是 LPC 編譯或 Runtime E2E 通過證據。

## 12 個種族檔案清冊

下列 SHA 是 Git tree 中 snapshot 檔案的 Git blob SHA，不是 SHA-256。Generated Runtime 的 SHA-256 尚待 Docker Runtime 建成後實際計算。

| 種族 | Snapshot 路徑 | Snapshot Git blob SHA | 套用規則 | 目前證據狀態 |
|---|---|---|---|---|
| human | `es2m_snapshot/mudlib/daemon/race/human.c` | `1e339ef44e23ea5b360a8a51ba16827b88cc6b7e` | 直接複製至 Runtime race daemon | `RUNTIME_UNKNOWN`：需 12 種族實機創角證據 |
| avatar | `es2m_snapshot/mudlib/daemon/race/avatar.c` | `41de6963abc2d779798138f06328853a77c8ae06` | 直接複製至 Runtime race daemon | `RUNTIME_UNKNOWN` |
| blackteeth | `es2m_snapshot/mudlib/daemon/race/blackteeth.c` | `e401307026485eb8228353929a80215b6cf71b4a` | 直接複製；另接 gnaw 指令 | `RUNTIME_UNKNOWN` |
| yenhold | `es2m_snapshot/mudlib/daemon/race/yenhold.c` | `10678bf657204fbc46029ee47ca767daf6e275b7` | 直接複製；另接 breathe 指令 | `RUNTIME_UNKNOWN`；breathe 已同步 f21f59c 上游差異，仍待 Runtime 驗證 |
| woochan | `es2m_snapshot/mudlib/daemon/race/woochan.c` | `b0091a7812cd20f6af8793635b589c5a766bfe12` | 直接複製；另接 replete 指令 | `RUNTIME_UNKNOWN` |
| dingling | `es2m_snapshot/mudlib/daemon/race/dingling.c` | `9a9069ed650e981ffb80efb6682024a6293d148a` | 直接複製；另接 hoof 指令 | `RUNTIME_UNKNOWN` |
| jiaojao | `es2m_snapshot/mudlib/daemon/race/jiaojao.c` | `f97688a52c7cdb539713daa6eccfddcc64789158` | 直接複製；另接 hide 指令 | `RUNTIME_UNKNOWN` |
| rainner | `es2m_snapshot/mudlib/daemon/race/rainner.c` | `681631b7d2dbf5ea4477312c86cfbe54d4ff7f48` | 直接複製；另接 feed 指令 | `RUNTIME_UNKNOWN` |
| ashura | `es2m_snapshot/mudlib/daemon/race/ashura.c` | `4decb2973565079b3ef1c2172ff7b47fc22ff590` | 直接複製 | `RUNTIME_UNKNOWN` |
| headless | `es2m_snapshot/mudlib/daemon/race/headless.c` | `34d5ac7ce204d542ee0957c39b5f1704e565f935` | 直接複製；另接 dance 指令 | `RUNTIME_UNKNOWN` |
| yaksa | `es2m_snapshot/mudlib/daemon/race/yaksa.c` | `187218cb5cf36d4c1a5cf920d5a8a583b9a90501` | 直接複製；另接 devour 指令 | `RUNTIME_UNKNOWN` |
| malik | `es2m_snapshot/mudlib/daemon/race/malik.c` | `c8d1234c2a0eea649c30d9cdb5d75cd4c8414142` | 直接複製 | `RUNTIME_UNKNOWN` |

## 種族與職業關聯核心檔案

| 檔案 | Snapshot Git blob SHA | phase2 套用／使用方式 | 初始分類 | 後續驗證 |
|---|---|---|---|---|
| `es2m_snapshot/mudlib/feature/char/score.c` | `80c1f7d211e65f6b88917b9a1938b474e8d67900` | 複製至 Generated Runtime 的 `mudlib/feature/char/score.c` | 既有整合；角色成長核心邏輯，不等同 UI | 比對生成 Runtime 的實際 SHA-256；測職業／等級／經驗與種族等級限制 |
| `es2m_snapshot/mudlib/daemon/class/commoner.c` | `4cbea60f4098de60961b8e32f5de9d56eeb248ad` | 8 個職業 daemon 由 snapshot 複製 | 既有整合 | 角色創建、升級、職業切換與儲存／重登 |
| `es2m_snapshot/mudlib/daemon/class/fighter.c` | `e9d7e121f60702954d14870b586e400543d64e84` | 同上 | 既有整合 | 同上 |
| `es2m_snapshot/mudlib/daemon/class/taoist.c` | `cc220b40727fd53b939ab5e25ead7ceea98f40b8` | 同上 | 既有整合 | 同上 |
| `es2m_snapshot/mudlib/daemon/class/alchemist.c` | `798936cb5e75c93728141a95d2897381dd8c917b` | 同上 | 既有整合 | 同上 |
| `es2m_snapshot/mudlib/daemon/class/soldier.c` | `191970bc552bc9ee76d66403789a1d07668642b9` | 同上 | 既有整合 | 同上 |
| `es2m_snapshot/mudlib/daemon/class/scholar.c` | `f3580a90c07849eaae87fc247ea42b6584d5c47c` | 同上 | 既有整合 | 同上 |
| `es2m_snapshot/mudlib/daemon/class/monk.c` | `e508baf3c28714645cc29f06b4d2d8583d203e6e` | 同上 | 既有整合 | 同上 |
| `es2m_snapshot/mudlib/daemon/class/thief.c` | `f67ac5f7a6e3112692eb84760156fa99b735e88f` | 同上 | 既有整合 | 同上 |
| `es2m_snapshot/mudlib/daemon/race/yenhold/breathe.c` | `6aca4dc824bc3c36fb1361dd0c0f45e919d82116` | 複製至 `cmds/usr/breathe.c` | 已同步上游火焰傷害力加成 | 靜態／Runtime 回歸仍待執行 |
| `es2m_snapshot/mudlib/daemon/race/headless/dance.c` | `eab9f024cfeab307e9524c1868feaa0ddbdbe0e6` | 複製至 `cmds/usr/dance.c` | 既有指令接線 | 實際玩家指令可達性測試 |

## 已報告差異與處理決策

| 項目 | 目前觀察 | 分類 | 本輪處理 |
|---|---|---|---|
| `yenhold/breathe.c` | 已直接核對 wolfer168/es2-webmud commit `f21f59cecb55e5c3e31d2e97a7ef6d43783ecdcb`；上游多出 `apply/damage_vs_fire` 加成與 help 說明 | `SOURCE_DIFF_CONFIRMED`；Runtime 行為仍 `UNKNOWN` | 已同步快照；待測裝備加成、傷害與指令 Runtime |
| Human `resurge` | 已從上游 commit `f21f59cecb55e5c3e31d2e97a7ef6d43783ecdcb` 取得來源，已加入快照並接入 race command overlay | `ADAPTER_REQUIRED`；Runtime／數值邊界仍 `UNKNOWN` | 靜態回歸與實際玩家指令測試待執行 |
| Avatar `radiate` | 已從上游 commit `f21f59cecb55e5c3e31d2e97a7ef6d43783ecdcb` 取得來源，已加入快照並接入 race command overlay | `ADAPTER_REQUIRED`；Runtime／數值邊界仍 `UNKNOWN` | 靜態回歸與實際玩家指令測試待執行 |
| `std/char/npc.c` | 較新 ES2M 有 NPC 技能機制；非種族階段核心範圍 | `UNKNOWN`／範圍外 | 不納入本輪種族整合；另開 NPC 依賴審查 |
| `logind.c`、`chard.c`、`command.h` | snapshot 未收錄；生成 Runtime 使用固定 Original 版本 | `COMPATIBILITY_REVIEW_REQUIRED` | 不以 snapshot 缺檔判為過時；比對固定 Original 與最新 ES2M 的契約差異 |
| `feature/char/score.c` | phase2 套用腳本已從 snapshot 複製到 Generated Runtime | 既有整合 | 不重複整合；針對角色成長與種族職業上限做 Runtime 驗證 |
| 12 個種族 daemon | 現有靜態回歸腳本要求 Runtime 檔案與 snapshot 相同，並檢查登入種族表 | 靜態契約已具備；真實創角證據待補 | 逐一執行創角、核對出生數值、存檔與重登；保存原始輸出 |

## 實機創角腳本檢查發現的證據缺口

檢查既有 `scripts/test_original_player_creation_e2e.mjs` 後，確認原本腳本會檢查角色存檔存在、種族、commoner 職業、等級 1、部分種族指令、存檔／登出／重登；但原本**沒有直接比對存檔中的八大出生屬性數值**。因此即使創角旅程通過，也不足以單獨證明出生屬性符合 ES2M。

本盤點分支已新增八大出生屬性範圍斷言，涵蓋 12 種族，並輸出 `ES2M_BIRTH_ATTRIBUTES_PASS:<race>` 標記。範圍依本分支各 race daemon 的 `base + random(n)` 推導，包含下限與上限；此修改只調整測試，不改遊戲邏輯。

- 測試檔：`scripts/test_original_player_creation_e2e.mjs`
- 修改前 Git blob SHA：`d410b05e8f5bb2c9f902f6cb9bccda1433463045`
- 修改後 Git blob SHA：`a545ad26501b34625c8283f4b46921c6e3529a9c`
- 修改後 commit：`28e850a3822f6b7cc5644582d481e2ae2d7a8b52`
- 驗證狀態：`RUNTIME_UNKNOWN`；尚未在 Docker／Neolith 實際執行，需確認存檔序列化格式確實可由測試取出屬性欄位，並確認 12 種族的範圍斷言與實測一致。
- 注意：這是對 ES2M snapshot 採用值的測試，不代表該第三方數值等於 Original ES2 Canon。

## 三方雜湊表的完成規則

每個目標檔案需記錄三種不同證據，不能混用：

| 欄位 | 記錄規則 |
|---|---|
| Pinned Original commit / blob SHA | 由固定 commit 的 Git tree 取得；若該路徑不存在，記錄 `ABSENT_AT_PINNED_ORIGINAL`，不能留白後猜測 |
| ES2M Snapshot Git blob SHA | 由本分支 tree 取得；目前種族清冊已記錄 12 個 race daemon 的 blob SHA |
| Latest ES2M source commit / SHA | 獨立抓取指定來源 commit 與檔案後記錄；尚未獨立取得者標記 `UNKNOWN` |
| Generated Runtime SHA-256 | Docker Runtime 實際生成後以 `sha256sum` 計算；未建成前標記 `BLOCKED / NOT_RUN` |
| 行為差異 | 以來源 diff、呼叫關係與測試證據說明，不只依檔名或雜湊判斷 |
| 結論 | `COMPATIBLE`、`ADAPTER_REQUIRED`、`CONFLICT`、`UNKNOWN` 四類之一，並附證據 |

Git blob SHA 不等於 SHA-256；相同 blob SHA 表示 Git 內容物件相同，但 Generated Runtime 仍須記錄其實際 SHA-256 以確保套用結果可追溯。

## 本輪待辦清單

1. [ ] 以本文件分支確認最新 HEAD 仍以基準 commit 為父提交；不變更主開發分支。
2. [ ] 在可用的本機 Docker 環境執行專案既有 Dockerfile 建置；不使用 Render。
3. [ ] 若建置被環境／網路／資源限制阻擋，記錄為 `BLOCKED`，保留完整錯誤，不誤報程式 FAIL。
4. [ ] 在 Generated Runtime 對 12 個 race daemon、8 個 class daemon、`feature/char/score.c` 計算 SHA-256，並對照來源。
5. [ ] 確認測試腳本中的 12 種族靜態檢查通過；將靜態結果與真實 Runtime E2E 分開記錄。
6. [ ] 使用可切換單鍵／整行輸入的實機創角腳本，逐一建立 12 個種族角色，保存登入、出生屬性、存檔、登出及重登證據。
7. [ ] 逐項重現與確認五個阻擋點，建立「現象、重現步驟、日誌、根因狀態、影響、後續方案」紀錄；未取得證據前不自行命名根因。
8. [x] 已重新取得 ES2M 最新版 `yenhold/breathe.c`、Human `resurge`、Avatar `radiate` 並完成來源差異確認；`breathe` 已同步，`resurge`／`radiate` 已新增並接線。仍需執行靜態、LPC 與玩家 Runtime 驗證。
9. [ ] 更新本清冊的三方 SHA、Runtime 證據與狀態。
10. [ ] PR #13 保持 OPEN / NOT MERGED；不部署 Render；不套用外部整合 ZIP。

## 本次 GitHub 初始證據

- `scripts/apply_race_phase2_runtime.sh`：Git blob SHA `d770dad02cab1b30673ab0c13dc03e93b4d47633`
- `scripts/test_race_phase2_static.sh`：Git blob SHA `03e98ab530fbda1e510e91af37e02a8e97aac6c1`
- `scripts/test_race_phase2_regression.sh`：Git blob SHA `22d4e18d3512a476eadf84e719d0a451e50c033c`
- `Dockerfile`：固定 Original ES2 commit 為 `cc45c06af4852380e5148dad3c9d53ff06854f2c`
- `docs/research/RACE_SOURCE_DIFFERENCE_REVIEW_20261011.md`：Git blob SHA `5bce7af398cb16777ecf428f1f5f0b9d331004e3`
- `docs/evidence/es2m/ES2M_RACE_CLASS_RECOVERY.json`：Git blob SHA `6046a141624e658a1d18b79c353f28ac1858a95a`

**重要聲明：** 本文件建立時，尚未在本次工具環境實際啟動 Docker／Neolith，也未執行 12 種族真人創角。所有未取得實際執行證據的項目都維持 `RUNTIME_UNKNOWN` 或 `BLOCKED`，不可宣稱 PASS。
