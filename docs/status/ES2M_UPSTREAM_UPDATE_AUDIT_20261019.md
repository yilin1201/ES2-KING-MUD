# ES2M 上游更新稽核 — 2026-10-19

## 1. 本輪來源與版本差異

- KING Repository：`yilin1201/ES2-KING-MUD`
- KING 工作分支：`integration/es2m-audit-import-20261017`
- ES2M 上游：`https://github.com/wolfer168/es2-webmud`
- KING 目前固定的 ES2M 證據 pin：`71693beb79ced81d51719ea1ccf7c02c641ca9b0`
- 本輪查到 ES2M 上游 `main`：`63e932a2e46aa745a741df14e108df76bcd30f84`
- GitHub compare 結果：上游 `main` 比固定 pin 領先 **45 commits**，merge-base 仍是固定 pin。
- 這表示上游有新資料可考證，但**不表示這些差異已匯入 KING Runtime**。

## 2. 新資料分類

### A. 新增／更新武學與技能資料（先保存證據，不直接啟用）

本輪上游差異包含：

- `daemon/skill/liuh-ken.c`
- `daemon/skill/chaos-steps.c`
- `daemon/skill/fonxansword.c`
- `daemon/skill/fonxan_force.c`
- `daemon/skill/eight_steps.c`
- `daemon/skill/magic_steps.c`
- `daemon/skill/reflecting_star_sword.c`
- `daemon/skill/sun_force.c`
- `daemon/skill/taoism-spells.c`（大幅修改）
- `daemon/skill/ksanmando.c`、`daemon/skill/seven.c`（既有檔案修改）

上游近期提交亦包含清河映星劍、陰陽奇門步、火雲奇門步法、天師道法四破等武學資料。

**處理狀態：SOURCE DISCOVERED / RUNTIME IMPORT HOLD。** 依既有工作順序，先完成 Docker、Admin、Port、E2E 閘門；通過後才逐項驗證技能。不得整批搬入或宣稱已可用。

### B. 煉丹、藥物、藥材與火候系統

上游新增多個 `daemon/misc` 與 `daemon/skill` 檔案，包含：

- `heat_commands.c`、`heat_d.c`、`heat_recipes.c`
- `herb_catalog.c`、`herb_cycle.c`、`herb_d.c`、`herb_qualification.c`
- `alchemy-medication.c`
- 多種藥丸、藥材、混合物與爐具物件

**處理狀態：SOURCE DISCOVERED / DEPENDENCY AUDIT REQUIRED。** 需確認命令註冊、daemon 載入、物件路徑、配方依賴、角色技能與資源消耗；未完成前不得直接視為可玩的系統。

### C. 世界、NPC 與任務相關內容

上游有以下可追蹤變更：

- `custom/legacy_npc/liuh_don_lu.c`
- `d/wutang/npc/guo_boo.c`
- `d/qiaoyin/npc/keeper.c`、`d/qiaoyin/npc/old_ho.c`
- `d/snow/npc/herbalist.c`、`d/snow/npc/teacher.c`
- `d/lee/herb_shop.c`、`d/lee/npc/lee_yen.c`
- `d/lee/obj/bronze_furnace.c`、`bronze_reactor.c`、`firewood.c` 有刪除變更

**處理狀態：逐檔比對，不可直接覆蓋。** 特別是 `d/snow/npc/teacher.c`，KING 已有自訂版本，必須保留 KING 版本並另外記錄上游差異。

### D. 核心系統與物件路徑變更（高風險 HOLD）

本輪差異包括：

- `adm/daemons/combatd.c`
- `feature/char/combat.c`
- `adm/simul_efun/utf8.c`
- `std/char.c`、`obj/user.c`
- `cmds/std/acquire.c`、`drop.c`、`get.c`、`put.c`、新增 `prepare.c`
- `include/room.h`
- 多個藥物物件從舊路徑刪除、移動或改名

**處理狀態：CORE HOLD。** 不可將上游戰鬥規則、UTF-8、角色生命週期或物件路徑差異直接覆蓋到 KING。必須以 Original ES2 為基底做三方差異分析，衝突保留 KING，並建立獨立測試。

## 3. 已知固定來源與匯入管線限制

目前 KING Dockerfile 與匯入腳本仍明確引用：

- 固定來源目錄：`source/es2m_updates/20261017_71693beb/upstream-es2-webmud`
- 固定 manifest：`docs/status/ES2M_SOURCE_SYNC_MANIFEST_20261017.json`
- 固定 source commit：`71693beb79ced81d51719ea1ccf7c02c641ca9b0`
- 既有持久 overlay：`es2m_snapshot/latest_import_overlay/71693beb/mudlib`

匯入腳本 `import_es2m_latest_missing_files.py` 與 `merge_es2m_latest_changes_safe.py` 也會驗證固定 commit 與 manifest blob SHA。**只更新 submodule 指標、卻不同步更新 manifest、驗證腳本與 overlay 版本，會使建置失敗或造成來源／清冊不一致。**

因此本輪不擅自移動固定 pin，也不改寫舊 manifest 假裝它代表最新上游。

## 4. 本輪寫入 KING 的內容與實際狀態

本文件把 2026-10-19 上游更新線索、主要變更分類、保護規則及後續匯入條件保存至 KING Repository，供下一輪工作直接接續。

| 項目 | 狀態 |
|---|---|
| 讀取上游最新 main 與 compare | PASS：確認 45 commits ahead |
| 上游更新類別初步整理 | PASS：技能、煉丹／藥物、世界／NPC、核心系統 |
| 寫入 KING 版本庫稽核文件 | 本次提交完成後以 commit SHA 確認 |
| 更新 submodule 固定 pin | NOT DONE：需先建立新版本快照與新 manifest |
| 更新全量 source blob manifest | NOT DONE |
| 寫入 Runtime overlay | NOT DONE：尚未完成新來源三方差異及依賴驗證 |
| Docker／Runtime／E2E | NOT RUN：本文件不是遊戲通過證據 |

## 5. 下一步執行順序

1. 保持既有 `71693beb` 證據快照不可變。
2. 建立獨立的新上游快照，固定至 `63e932a2e46aa745a741df14e108df76bcd30f84`，並記錄 commit/tree/blob 證據。
3. 產生與新快照一致的全量 manifest，重新核對 Original、舊 ES2M snapshot 與 KING Runtime 三方差異。
4. 先處理低風險、缺檔且依賴明確的世界／NPC／物件資料；同名異動全部保留 KING 並列為 HOLD。
5. 核心戰鬥、角色生命週期、UTF-8 與技能批次維持 HOLD，直到相關建置與 E2E 閘門通過。
6. 僅把無衝突、來源可驗證的內容輸出至新版本 overlay；不可用舊 overlay 覆蓋新內容。
7. 執行最小必要測試，回報新增、相同、衝突、排除與未解依賴數量。未實測項目不得標示 PASS。

## 6. 專案保護規則

- Original ES2、ES2M 上游與 ES2-KING Expansion 分層保存。
- 不 Merge PR #13；PR #13 保持 OPEN / NOT MERGED。
- 不修改 `build/original-es2-races-phase2`。
- 不部署 Render。
- 不刪除測試、不降低閘門、不以推測補造缺失檔案。
- `d/snow/npc/teacher.c` 保留 KING 自訂版本。
- 戰鬥核心與技能正式移植需等待前置閘門通過。
