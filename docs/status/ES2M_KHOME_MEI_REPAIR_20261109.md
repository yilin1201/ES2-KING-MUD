# ES2-KING 最新 ES2M 同步與 Khome／梅寒霜修復紀錄（2026-11-09）

## A. 寫入邊界與版本

- 唯一寫入 Repository：`yilin1201/ES2-KING-MUD`
- 寫入分支：`build/original-es2-races-phase2`
- 本輪程式與 Runtime 驗證 HEAD：`e92b3fadee636bb857e4a6dd9e4961fe868e62b0`
- ES2M 來源：`kds121tw/ES2M-KDS`，main HEAD：`ced29a6e9cdb0ce6e2392a80702295e350dbcb57`
- ES2M、ES2M-KDS、ES2-KDS 均只讀；沒有向來源 Repository 推送。
- PR #13：OPEN / NOT MERGED。

## B. ES2M 最新來源鏡像

以 Git Tree blob SHA 比對 ES2M `source/upstream/mudlib/` 與 KING `es2m_source_mirror/mudlib/`：

| 項目 | 數量 |
|---|---:|
| ES2M 最新 Mudlib blobs | 1,829 |
| KING 來源鏡像 blobs | 1,829 |
| Blob SHA 完全相同 | 1,829 |
| 缺漏 | 0 |
| 不同 | 0 |

來源鏡像已精確對齊 ES2M-KDS 指定 HEAD。鏡像只反映上游當前檔案；KING Runtime Overlay 不刪除上游沒有的 KING 專屬檔案。

## C. KING Runtime Overlay 匯入結果

| 同步批次 | 新增 | 覆蓋 | 已相同 | 保護 KING |
|---|---:|---:|---:|---:|
| 首次完整匯入（Run 42541479251） | 6 | 63 | 1,739 | 21 |
| 家園文件保護後再同步（Run 42541830102） | 2 | 1 | 1,804 | 22 |

目前最新匯入報告 `docs/research/ES2M_NEW_FILES_IMPORT_REPORT.json` 記錄第二次增量結果：新增 `data/chinese.o`、`data/emoted.o`；更新 `adm/daemons/logind.c`，其 WebTelnet 四參數 input_to 相容性修正仍保留。22 個 KING 保護路徑包含 Owner 技能上限、冷梅凍結技能、種族 ID、梅影風教學、振武整合、WebTelnet 連接埠、李家村拓樸與 KING 私人家園說明。

ES2M 與固定 Original ES2 基準有 181 個來源內容差異；這是版本差異統計，不代表 181 個程式錯誤。固定 Original ES2 僅供比較，未修改。

## D. Khome 自宅修復

### 根因
- 原 `cmds/adm/khome.c` 指向 `/d/king/wuji_realm`，與 `kinghome` 神域入口重複，沒有進入自宅。
- 原 `docs/help/home_help.txt` 仍標示家園入口尚未開放。
- 自宅大廳、寢室、書房、未來房間、管家、床、告示板及儲物箱程式實際存在，並非檔案被刪除。

### 修復
- `khome` 改為建立 `/custom/home/room/home_hall`。
- 建立後先執行 `home->set_home_owner(me)`，再移動 Owner 進入。
- 保留 `SECURED_ADMIN_COMMAND` 與 `kingd->authorized(me)` 雙重 Owner 權限。
- `kinghome` 維持天神殿・無極之境入口，兩個指令功能分離。
- 恢復家園 help，並把該文件加入 ES2M 同步保護清單，避免日後再被上游同名文件覆蓋。

## E. 梅寒霜與演武界修復／驗證

- NPC：`/d/arena/npc/mei_hanshuang`
- 房間：`/d/arena/yanwujie`
- 無極之境出口：`enter → /d/arena/yanwujie`
- 演武界出口：`out → /d/king/wuji_realm`
- 演武界 `objects` mapping 生成梅寒霜；房間 `setup()` 執行載入。
- 保留梅寒霜原始 NPC、冷梅／傲劍相關技能與焦黑枯梅枝，不重造人物、不改寫武學。

## F. 驗證結果

| 驗證 | 結果 |
|---|---|
| ES2M Source Mirror SHA 比對 | PASS，1,829／1,829 |
| ES2M Update Sync Regression（Run 42542698550） | PASS |
| ES2M Snapshot Gate（Run 42542698573） | PASS |
| M27 生成 Runtime 房間／出口／NPC 拓樸 Gate（Run 42542698533） | PASS |
| M30 Alpha 整合驗收（Run 42542698556） | PASS |
| Neolith Driver Build（Run 42542698570） | PASS |
| Khome 指令 LPC preload | PASS，Neolith 已編譯並載入 `khome.c` |
| 家園大廳 LPC preload | PASS |
| 無極之境／演武界／梅寒霜 LPC preload | PASS，演武界房間 `setup()` 及 NPC 載入路徑已由真 Driver 啟動檢查 |
| Khome 玩家互動 E2E | 尚未執行；已更新 `test_k_admin_runtime_e2e.mjs` 與 `test_cold_plum_arena_runtime_e2e.mjs` 加入 khome/look/board/returnhome 驗收 |
| 梅寒霜完整 look／ask／戰鬥 E2E | 尚未於本輪執行；既有 E2E 腳本保留，不能以 LPC preload 取代玩家互動驗收 |
| Render 正式部署 | 尚未核對；需先確認 Render workspace，再核對服務 build_commit 與 deploy 狀態 |

M30 與 M27 的 Driver／Runtime Gate 已通過，但互動式 Khome 玩家流程與梅寒霜完整戰鬥流程仍明確標示為待執行，不宣稱已 PASS。

## G. 重要 Commit

- 初始修復／同步 Workflow 更新：`3f45b3e9fc06246db9065bcc3dc9ea696180d6d2`
- 首次 ES2M 鏡像及 Overlay 同步：`90ffe425bbb909484d78e9f31ccbd9c7d5dd0288`
- 最新程式／測試基準與 Driver Gate：`e92b3fadee636bb857e4a6dd9e4961fe868e62b0`
