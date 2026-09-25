# ES2-KING GitHub 程式與檔案中文導覽

> 盤點基準：Branch `build/original-es2-races-phase2`  
> Head：`c1fc52dd5a938b2100c91cfabdbd9c59593f2fdc`（Cleanup 前基準）  
> PR #13：OPEN / NOT MERGED  
> 本文件只整理與說明現有 Repository，不搬動 Original ES2 保存資料、不 Merge、不建立 M31。

## 一、先看懂整個 Repository

Cleanup 前 Repository 共 266 個檔案。建議用「規則 → Original → Expansion → 執行/測試 → Web/部署」的順序閱讀，而不是照 GitHub 字母排序。

| 閱讀順序 | 區域 | 用途 | 是否可直接修改 |
|---|---|---|---|
| 01 | 根目錄規格文件 | 專案規則、Roadmap、M30 狀態 | 可更新說明，不任意改 Canon |
| 02 | `original_es2/` | Original ES2 證據、重建、Runtime 結果 | 保存/證據層禁止推測污染 |
| 03 | `es2_king_expansion/` | ES2-KING 原創擴充與真正 Runtime overlay | 主要開發區 |
| 04 | `king_library/` | KING 武學、人物、神兵設定資料庫 | Canon/設計資料 |
| 05 | `legacy_sources/` | 舊 Gemini 等歷史參考 | 只作來源，不直接當 Canon |
| 06 | `scripts/` | 建置、套用、測試、部署腳本 | 工程執行層 |
| 07 | `webtelnet/` | 瀏覽器登入 MUD 的前端與橋接 | Public Browser 主要開發區 |
| 08 | `.github/workflows/` | GitHub Actions 自動測試定義 | 目前 ACTIONS-INFRA-BLOCKED |
| 09 | Docker / Render | 公開部署包裝 | Render Free 有持久化限制 |

## 二、根目錄：專案總控層

### `README.md`
專案入口。說明「保存 → 理解 → 重建 → 擴充」以及 Original / Expansion 分離。

### `AGENTS.md`
開發工作守則。包含證據優先順序、禁止 AI 擅自補完 Original、繁體中文註解、修改安全邊界。

### `ES2_CN_STANDARD.md`
ES2-CN 中文規範。技術名詞第一次出現需有繁中名稱與白話用途。

### `ROADMAP_M0_M30.md`
正式鎖定 M0～M30。M0～M25 以 Original 保存/重建為主；M26～M30 為 ES2-KING Expansion。PR #13 不 Merge。

### M30 三份文件
- `docs/history/m30/M30_ALPHA_FINAL_AUDIT.md`：M0～M30 稽核矩陣。
- `docs/history/m30/M30_PLAYABLE_ALPHA_ENTRY.md`：本機 Neolith/KING 可玩證據。
- `docs/history/m30/M30_DEPLOYMENT_READINESS.md`：Docker、Web、持久化、Render 部署架構。

注意：這些是「歷史驗收紀錄」，其中部分 Browser/Render 描述已早於目前公開 Render 實機進度，不應把舊文字當成最新 Runtime 狀態。

## 三、Original ES2：歷史保存與重建層

`original_es2/` 是專案最重要的「原作證據區」，目前 80 個檔案。

### 1. `original_es2/source_manifest.md`
來源總表。最高優先上游為 `taedlar/es2_mudlib`，用來鎖定 Original ES2 真實程式來源。

### 2. `original_es2/data/`
機器可讀的歷史資料，例如歷史種族 registry、梅影風/冷梅莊資料。

### 3. `original_es2/research/`
考證主區。M5、M10～M25、Google Sites、種族、職業、技能、武學、NPC、世界、Quest、生命週期等證據與計畫都放這裡。

### 4. `original_es2/runtime/`
實際 Runtime 驗證結果，不是 Canon 設定本身。用來記錄 M2～M25 的實機結果。

### 5. `original_es2/tests/`
大型 Original 驗收規格，例如 M20 Original Alpha。

### 6. `original_es2/characters/`、`races/`、`systems/`、`ui/`
分別放人物、種族、系統與 Original UI 規格。

**整理原則：Original 內的 UNKNOWN / PARTIAL 必須保留，不因 ES2-KING 已可玩就補造成歷史事實。**

## 四、ES2-KING Expansion：真正新增內容

`es2_king_expansion/` 目前 31 個檔案，分成「設定/研究」與「Runtime 程式」。

### 設定與研究
- `admin_rooms/wuji_realm.md`：天神殿・無極之境。
- `characters/`：Expansion 人物設定。
- `martial_arts/yijinjing.md`：易筋經設定。
- `research/m26_* ~ m30_*`：KING、神域、武學、Canon、Owner 授權的設計與證據邊界。
- `runtime/m26_* ~ m30_*`：各里程碑實際結果紀錄。

### 真正 LPC Runtime 程式
`es2_king_expansion/runtime/mudlib/`
- `adm/daemons/kingd.c`：KING 核心服務。
- `kingmartiald.c`：KING 武學狀態。
- `kingcanon_d.c`：M29 Canon 武學狀態。
- `cmds/adm/kingcreate.c`：KING 創造指令。
- `kingrealm.c`：進入天神殿/無極之境。
- `kingmartial.c`：易筋經、霸天煉體訣等管理指令。
- `kingcanon.c`：渾天寶鑑、如來神掌等 Canon 指令。
- `d/king/wuji_realm.c`：神域房間。
- `obj/king/creation_mark.c`：KING 創造物件。

這一區是 Expansion 真正「會跑」的遊戲程式，不應與 Original 證據文件混為一談。

## 五、KING Library：設定資料庫

`king_library/` 目前 8 個檔案。用途是集中保存 KING 世界觀可重用設定：
- 古飛揚／李雲霄
- 霸天煉體訣
- 渾天寶鑑
- 如來神掌
- 易筋經
- 古霄、飛雲等神兵

它是「設計/Canon Library」，不是 Neolith 直接執行的 Runtime 程式。

## 六、Legacy Sources：舊參考資料

`legacy_sources/gemini/` 目前 5 個檔案。保存早期 Gemini 整理內容、修正/排除紀錄、戰鬥風格等。

建議永遠視為「參考來源」，若要正式採用，先進研究/Canon 層確認，不直接複製到 Original。

## 七、Scripts：工程執行中心

`scripts/` 目前 80 個檔案，是數量最大的工程區之一。

### A. 建立 Runtime
- `bootstrap_original_es2.sh`：抓乾淨 Original ES2 + Neolith，建立可執行樹。
- `apply_es2_king_expansion.sh`：把 Expansion overlay 套到獨立 Runtime；KING Claim、KING ID 保護、指令重索引也在此層。
- `apply_race_phase2_runtime.sh`：早期種族 Runtime 套用。

### B. 公開部署
- `prepare_es2_persistence.sh`：把 `mudlib/data` 接到持久儲存位置。
- `start_es2_king_web.sh`：啟動 Neolith + Web Bridge。
- `healthcheck_es2_king.mjs`：健康檢查。
- `assert_m30_final_runtime.sh`：部署前 Runtime 斷言。

### C. 測試
大量 `test_mXX_*.sh/.mjs/.py` 是 M5～M30 的 Static / Runtime / Regression 證據。

目前開發策略應改成：
**小修正只跑對應最小測試；M30 最終封版才跑全套。**
不要因為檔案很多就每次全部重跑。

### D. 目前 Race blocker 的最小測試
- `test_m30_character_browser_input.mjs`
- `test_m30_webtelnet_display.mjs`

最新修正已將 Race 的確認鍵改為 Original `cursor_translate()` 明確接受的 CR（Carriage Return／回車）。

## 八、WebTelnet：現在最重要的 Public Browser 層

`webtelnet/` 目前 8 個檔案。

### `public/index.html`
iPhone/桌機看到的黑底終端 UI。負責：
- WebSocket 連線
- 輸出顯示
- 密碼遮蔽
- Claim 輸入
- Race/Gender/Confirm Compatibility UI
- Mobile 排版

### `public/character-input.mjs`
**目前 Race 問題的核心相容模組。**

Original ES2 使用 `get_char` 單鍵選單；現代網頁輸入是文字表單，因此此檔負責翻譯：
- human → CR（確認目前 human）
- avatar → KEY_DOWN → 等 Original 重畫 → CR
- Gender → F / M / N
- Confirm → Y / N

### `public/claim-input.mjs`
把 KING Claim Secret 轉成 HEX-V1 安全傳輸，避免 Telnet 特殊字元破壞 Token。

### `server.mjs`
Web Server + WebSocket/Telnet Bridge。瀏覽器資料透過 WebSocket 送到 Neolith TCP :4000。

### `telnet.mjs`
過濾 Telnet IAC 控制碼，避免 UTF-8 中文被控制位元組破壞。

### `package.json / package-lock.json`
Node.js Web Bridge 套件與固定版本。

## 九、GitHub Actions

`.github/workflows/` 現保留 8 份現行 Regression／Release Gate：M26～M30、M25 Release Candidate、Driver Build、Roadmap。M4～M24 與舊 Race Phase 2 共 25 份 Workflow 已原文移入 `docs/archive/workflows/`；對應 scripts 未刪除。

GitHub Actions 維持 `ACTIONS-INFRA-BLOCKED`，不應反覆 rerun。

## 十、Docker / Render 部署層

- `Dockerfile`：把 Original ES2、Neolith、Expansion、WebTelnet 打成容器。
- `render.yaml`：Render 服務設定。
- `.dockerignore`：避免把不必要檔案包進 image。
- `.gitignore`：避免 Runtime/暫存資料誤 Commit。

公開架構：
`iPhone/PC → HTTPS/WSS → WebTelnet → Bridge → Neolith :4000 → ES2-KING`

玩家資料：
`mudlib/data/login/... + mudlib/data/user/...`

Render Free 沒有 Persistent Disk，因此公開 Runtime 重新部署仍有存檔遺失風險；這和 Race Compatibility 是兩個不同問題。

## 十一、我建議的「邏輯排序」，不是現在就大搬檔案

目前 Repository **結構本身其實已經分層成功**，真正凌亂的是「219 個檔案沒有一張給 Owner 看得懂的地圖」，而不是一定要把路徑全部重搬。

因此第一階段採低風險整理：
1. 保留現有路徑，避免 33 個 Workflow、66 個 scripts 因搬檔案一起失效。
2. 新增本中文導覽作為 Owner 索引。
3. 之後新增檔案遵循 Original / Expansion / Runtime / Test / Deploy 分層。
4. 等 M30 Public Acceptance 完成後，再評估是否做實體目錄重構；若要搬，需一次同步修 Workflow/Script path。

## 十二、目前最新開發狀態

GitHub Head：`d16165f8ce358605beec7d7247eef7355e634ec1`

PR #13：OPEN / NOT MERGED。

最新 Race 修正：
`human → CR`
`avatar → KEY_DOWN → CR`

尚待 Public Device 真實驗收 Race → Gender → Display Name → Confirm → Enter Game。

M30 仍未關閉；不建立 M31。
