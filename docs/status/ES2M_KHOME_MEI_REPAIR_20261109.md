# ES2-KING 最新 ES2M 同步與 Khome／梅寒霜修復紀錄（2026-11-09）

## 1. 寫入邊界

- 唯一寫入 Repository：`yilin1201/ES2-KING-MUD`
- 寫入分支：`build/original-es2-races-phase2`
- ES2M 來源：`kds121tw/ES2M-KDS`，main HEAD `ced29a6e9cdb0ce6e2392a80702295e350dbcb57`
- ES2M、ES2M-KDS、ES2-KDS 均只讀；本輪沒有向來源 Repository 推送。
- PR #13 保持 OPEN / NOT MERGED。

## 2. 全量來源鏡像核對

以 Git Tree blob SHA 比對 ES2M `source/upstream/mudlib/` 與 KING `es2m_source_mirror/mudlib/`：

| 項目 | 數量 |
|---|---:|
| ES2M 最新原始 Mudlib 檔案 | 1,829 |
| KING 最新來源鏡像檔案 | 1,829 |
| Blob SHA 完全相同 | 1,829 |
| 缺漏 | 0 |
| 內容不同 | 0 |

來源鏡像現已精確對齊 ES2M-KDS 指定 HEAD。來源鏡像目錄只反映上游當前檔案；KING Runtime Overlay 不採刪除上游不存在檔案的方式處理。

## 3. KING Runtime Overlay 匯入結果

GitHub Actions `Sync ES2M Files Into KING Overlay`（Run 42541479251）成功：

| 分類 | 數量 |
|---|---:|
| ES2M 來源檔案 | 1,829 |
| 新增到 KING Overlay | 6 |
| 覆蓋 KING 同路徑舊檔 | 63 |
| 原本已相同 | 1,739 |
| KING 保護檔案 | 21 |
| ES2M 與固定 Original ES2 基準不同 | 181 |

181 筆代表 ES2M 相對於固定 Original ES2 來源有內容差異，並非全部都是程式衝突。保護檔依同步報告保留，未把 KING Owner 技能上限、凍結冷梅技能、種族 ID、梅影風教學、振武整合、WebTelnet 連接埠及李家村拓樸相容性盲目覆蓋。

詳細逐檔紀錄：`docs/research/ES2M_NEW_FILES_IMPORT_REPORT.json`。

## 4. Khome 自宅根因與修復

### 已確認根因

- 原 `cmds/adm/khome.c` 將 `khome` 指向 `/d/king/wuji_realm`，與 `kinghome` 神域入口重複。
- 原 `docs/help/home_help.txt` 宣告尚未開放家園入口。
- 自宅大廳、寢室、書房、未來房間、管家、床、告示板與儲物箱檔案實際存在，並非資料夾遭刪除。

### 修復

- `khome` 改為建立 `/custom/home/room/home_hall`，先呼叫 `set_home_owner(me)`，再將 Owner 移入房間。
- Owner 授權仍由 `SECURED_ADMIN_COMMAND` 與 `kingd->authorized(me)` 雙重限制。
- `kinghome` 繼續負責天神殿・無極之境，不改變其用途。
- 更新 `docs/help/home_help.txt`，說明 Khome、儲物箱、管家、告示板、增建與返回客棧。
- 將 KING 家園說明列入 ES2M 同步保護清單，避免下一次來源覆蓋。

## 5. 梅寒霜與演武界

- NPC：`/d/arena/npc/mei_hanshuang`
- 房間：`/d/arena/yanwujie`
- 無極之境出口：`enter → /d/arena/yanwujie`
- 演武界出口：`out → /d/king/wuji_realm`
- 演武界 `objects` mapping 指定自動生成梅寒霜，房間 `setup()` 負責載入。
- 冷梅、傲劍、焦黑枯梅枝與既有技能檔均保留；本輪未重造 NPC 或改寫武學。

## 6. 驗證紀錄與界線

- ES2M 同步 Workflow：PASS。
- Khome／梅寒霜靜態入口檢查：PASS（同步 Workflow step 6）。
- M27 無極之境靜態與 Runtime Gate：PASS（本輪初始提交之 Workflow）。
- ES2M Update Sync Regression：PASS（本輪初始提交之 Workflow）。
- Khome 實際玩家 E2E：本次尚未執行；已將 `khome`、`look`、`look board`、`returnhome` 驗收加入既有 `test_cold_plum_arena_runtime_e2e.mjs`，待可用真實 Driver fixture 執行。
- 梅寒霜完整戰鬥 E2E：既有測試程式保留；本次靜態入口通過不取代完整戰鬥 Runtime 驗收。
- Render 正式部署：未因本次 GitHub commit 自動宣告完成，需以公開服務 build_commit 與部署狀態另行核對。

## 7. 本輪 KING Commit

- 初始修復／同步 Workflow 更新：`3f45b3e9fc06246db9065bcc3dc9ea696180d6d2`
- ES2M 最新鏡像及 Overlay 同步：`90ffe425bbb909484d78e9f31ccbd9c7d5dd0288`
