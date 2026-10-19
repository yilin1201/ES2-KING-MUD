# ES2M 上游更新稽核 — 2026-10-19

## 1. 本輪來源與版本差異

- KING Repository：`yilin1201/ES2-KING-MUD`
- KING 工作分支：`integration/es2m-audit-import-20261017`
- ES2M 上游：`https://github.com/wolfer168/es2-webmud`
- 舊證據 pin（保留不變）：`71693beb79ced81d51719ea1ccf7c02c641ca9b0`
- 新增獨立上游證據 pin：`63e932a2e46aa745a741df14e108df76bcd30f84`
- GitHub compare 結果：上游 `main` 比舊 pin 領先 **45 commits**，merge-base 仍是舊 pin。
- 新來源已註冊於 ` .gitmodules `，並新增 gitlink：
  `source/es2m_updates/20261019_63e932a2/upstream-es2-webmud`
- 新來源 pin 提交：`cb44648573a5895d52bfb1efb1eabc071e861455`
- 新來源的註冊只保存可重現的上游證據，不表示這些差異已匯入 KING Runtime。

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

## 3. 現有 Runtime 匯入管線仍固定於舊 pin

目前 Dockerfile 與匯入腳本仍引用舊來源：

- 舊來源目錄：`source/es2m_updates/20261017_71693beb/upstream-es2-webmud`
- 舊 manifest：`docs/status/ES2M_SOURCE_SYNC_MANIFEST_20261017.json`
- 舊 source commit：`71693beb79ced81d51719ea1ccf7c02c641ca9b0`
- 舊持久 overlay：`es2m_snapshot/latest_import_overlay/71693beb/mudlib`

匯入腳本 `import_es2m_latest_missing_files.py` 與 `merge_es2m_latest_changes_safe.py` 會驗證固定 commit 與 manifest blob SHA。**不可只把 Dockerfile 路徑換成新來源，也不可把舊 manifest 的 source_commit 改成新 SHA；這會讓來源與 blob 清冊不一致。**

新證據 pin 已保存，但全量 manifest、三方比較與新 overlay 尚未產生；因此本輪沒有宣稱 Runtime 資料已更新。

## 4. 本輪寫入 KING 的內容與實際狀態

| 項目 | 狀態 |
|---|---|
| 讀取上游最新 main 與 compare | PASS：確認 45 commits ahead |
| 上游更新類別初步整理 | PASS：技能、煉丹／藥物、世界／NPC、核心系統 |
| 寫入 KING 稽核文件 | PASS：`docs/status/ES2M_UPSTREAM_UPDATE_AUDIT_20261019.md` |
| 註冊新來源於 `.gitmodules` | PASS：新增 `20261019_63e932a2` |
| 新增固定 gitlink | PASS：提交 `cb44648573a5895d52bfb1efb1eabc071e861455` |
| 舊證據 pin | PRESERVED：`71693beb` 未替換 |
| 新全量 source blob manifest | NOT DONE |
| 新來源三方差異清冊 | NOT DONE |
| 寫入新 Runtime overlay | NOT DONE：等待差異與依賴驗證 |
| Docker／Runtime／E2E | NOT RUN：沒有把來源 pin 或文件提交冒充遊戲通過證據 |

## 5. 下一步執行順序

1. 透過 checkout/submodule update 確認新 gitlink 實際下載至 `source/es2m_updates/20261019_63e932a2/upstream-es2-webmud`，核對 HEAD 必須等於 `63e932a2e46aa745a741df14e108df76bcd30f84`。
2. 由新來源產生完整檔案清冊與 blob SHA manifest；另存新版本檔案，不覆寫 `ES2M_SOURCE_SYNC_MANIFEST_20261017.json`。
3. 比對 Original ES2、舊 ES2M snapshot、新 ES2M snapshot、KING Runtime 四方差異，分類新增、相同、修改、刪除、改名與 KING-only。
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
