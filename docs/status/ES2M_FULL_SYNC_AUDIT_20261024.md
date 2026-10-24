# ES2M 全量更新整合稽核紀錄（2026-10-24）

> 本文件是本次實際檢查紀錄，不代表 ES2M 全量匯入已完成。
> 狀態用語：已確認 = 本次工具直接讀取；未知／阻塞 = 尚無足夠證據，不得推定完成。

## 1. GitHub 基準

- KING Repository：`yilin1201/ES2-KING-MUD`
- 開發分支：`build/original-es2-races-phase2`（已確認分支存在）
- 本次檢查時 PR #13 HEAD：`25f5f2ac2daaa4e5ad130d0f3f79abccc1dea7a9`
- PR #13：OPEN / NOT MERGED；不得自行合併。
- ES2M 上游：`wolfer168/es2-webmud`
- 本次取得的 ES2M 最新提交：`d013a64cc9e5e5a9e148732bc58f6f7264219fcc`（2026-10-24 12:32:55 UTC）
- 先前紀錄所用 ES2M 基準：`70cbf3c244dd59c13a32ab2bae0f658e020e3a88`

## 2. 上游版本差異的直接證據

GitHub compare API 回報：從舊基準 `70cbf3c...` 到新基準 `d013a64...`，上游前進 314 個 commits，狀態為 ahead。

本次 compare 回應最多只提供 300 筆檔案差異；這 300 筆包含：
- modified：111
- added：170
- renamed：6
- removed：13

**重要限制：300 筆是 API 本次回傳筆數，不是完整差異總數。不得將這份結果宣稱為完整檔案清單。** 必須另以完整 Git tree／可分頁的檔案清單或可取得的上游快照，產生完整 manifest，才能完成逐檔盤點。

已見差異橫跨部署／更新腳本、文件、地圖區域、NPC、角色系統、技能、戰鬥、物品、煉丹系統及 mudlib 核心檔案。因此不能把上游整批直接覆蓋到 KING Runtime。

## 3. 本次實際檢查到的既有 KING 匯入程式

### `scripts/import_es2m_world_zones_safe.py`

目前可讀取的程式預設處理：
- `d/lee`
- `d/oldpine`
- `d/wutang`

它會檢查 LPC 文字引用的部分相依性、拒絕未知同名衝突，並對明確列出的六個既有 KING 檔案保留原內容、記錄兩側 SHA256。程式註明此流程是檔案 staging，不等同遊戲 Runtime PASS。

明確保留、尚未判定內容等價的衝突檔案：
- `d/lee/obj/brow_staff.c`
- `d/lee/obj/flour.c`
- `d/lee/obj/salt.c`
- `d/lee/obj/sugar.c`
- `d/lee/obj/waterskin.c`
- `d/wutang/npc/may_yin_fong.c`

### `scripts/apply_es2m_20261008_world_delta.py`

目前可讀取的增量工具僅處理：
- 雪亭鎮留言板 `daemon/board/snow_board.c)
- 雪亭鎮廣場西側載入留言板 `d/snow/square_w.c)
- 李家村小旅店非戰區 `d/lee/inn.c)

工具採新檔不存在才建立、房間程式採精確錨點修改、衝突即停止的方式。這是限定範圍的更新，不是 ES2M 全量同步器。

### 本次檢查限制

下列候選路徑未能在目前開發分支以 GitHub Contents API 讀取（回傳 404），因此不能把它們當成存在或完整：
- `scripts/merge_es2m_latest_changes_safe.py`
- `docs/ES2M_IMPORT_STATUS.md`
- `docs/ES2M_SOURCE_MANIFEST.json`
- `es2m_snapshot/latest_import_overlay/71693beb/manifest.json`
- 候選 ES2M sync workflow 路徑

404 只表示本次指定路徑／ref 未取得檔案，不能單獨證明整個 Repository 沒有其他相似檔案。下一步需透過完整 tree/Workflow 清單定位實際路徑。

## 4. 本輪整合狀態分類

| 類別 | 本次狀態 | 證據／處置 |
|---|---|---|
| Repository 與開發分支 | Confirmed | 已取得 GitHub Repository metadata 與 branch search 結果 |
| PR #13 保護狀態 | Confirmed | OPEN / NOT MERGED |
| ES2M 最新上游提交 | Confirmed | `d013a64...` |
| 舊基準至新基準的上游變動 | PARTIAL | 314 commits ahead；compare 回傳 300 筆檔案，清單可能截斷 |
| 三區域安全匯入工具 | Confirmed | 已讀取 `import_es2m_world_zones_safe.py` |
| 2026-10-08 世界增量工具 | Confirmed | 已讀取 `apply_es2m_20261008_world_delta.py` |
| ES2M 全量來源 manifest | UNKNOWN / BLOCKED | 尚未取得可證明完整性的來源檔案清單 |
| KING 全 Repository 檔案 SHA 對照 | NOT COMPLETED | 目前工具回應不足以建立完整逐檔清單 |
| 全量資料匯入 | NOT COMPLETED | 未執行整批覆蓋；沒有足夠完整 manifest 與差異分類 |
| 本輪 Runtime / Docker / Actions | NOT RUN | 本輪未執行，不能宣稱 PASS |
| ES2M 全量整合 | NOT COMPLETE | 不符合全量完成標準 |

## 5. 下一階段執行條件

1. 取得 ES2M 上游完整 Git tree／遞迴檔案清單與每檔 blob SHA；不可用被截斷的 compare 結果取代。
2. 取得 KING 開發分支同一時間點的完整 tree／blob SHA。
3. 依路徑與 SHA 分成相同、上游新增、上游修改、上游刪除、KING-only、同名不同內容與未知動態相依。
4. 優先以只讀方式將上游原始快照保存到獨立來源區；先不覆蓋 KING Runtime。
5. 對低衝突新增資料批次匯入；核心 mudlib、帳號、存檔、WebSocket、戰鬥與 KING 專屬檔案需分別審核。
6. 更新逐檔 manifest／匯入報告，再對實際修改範圍執行靜態測試、Docker build 與必要 Runtime 驗證。
7. 每次工作前重新確認 Branch HEAD；PR #13 必須持續 OPEN / NOT MERGED。

## 6. 本次結論

本輪完成了最新上游與 KING 開發基準的重新確認，並取得上游至少 300 筆差異中的可見部分、確認既有兩個安全匯入工具的實際範圍與已知衝突保護機制。

**本次沒有執行全量匯入，也沒有宣稱全量完成。** 目前最大的阻礙是完整、可分頁的來源／目標檔案清單尚未取得；在這項阻礙排除前，直接複製整個上游會有覆蓋 KING 自訂功能、漏掉被截斷差異及錯誤處理刪除／改名的風險。


## 7. 後續增量來源保存（2026-10-24）

為了先保存可直接讀取、來源版本可追溯的 ES2M 更新內容，本輪將以下來源檔案寫入獨立快照目錄：
`es2m_snapshot/upstream_20261024/`。

### 文件快照

| ES2M 原始路徑 | ES2M Blob SHA |
|---|---|
| `docs/AREA_KANGPING_BAIHUA.md` | `87be0d44be498085aeb6829a9a0731ce039174a3` |
| `docs/FORTUNE_TELLER.md` | `ab935ad4db8a7848319ff950cb910a8f099a18f1` |
| `docs/catalog/玩家圖鑑_技能.md` | `004bcb7e2db3652f0b740571e8deeb4e792c3757` |
| `docs/martial_arts/共通_水雲劍法.md` | `e06097b897fda8b1fd3597bebc41e37340e5cbfb` |
| `docs/PAWNSHOP_NETWORK.md` | `1c273e494dfa8dc26104f379b1c84ac28a4746fa` |

### LPC 原始碼快照

| ES2M 原始路徑 | ES2M Blob SHA |
|---|---|
| `source/upstream/mudlib/d/qiaoyin/npc/fortune_teller.c` | `d80993b172b00a5edb7f7efacf4dab1d477d5792` |
| `source/upstream/mudlib/daemon/skill/sayuensword.c` | `457b43095628dad94706f82952d98774f05fe0b0` |
| `source/upstream/mudlib/d/qiaoyin/npc/girl.c` | `f35517e3eec4bfb6060d2bfaa0ab70cb80236918` |

所有快照均附來源 Repository、上游 Commit 與原始 Blob SHA，存放在獨立的 `es2m_snapshot` 目錄，**尚未安裝至 KING Runtime，也不代表已通過 LPC 載入或遊戲流程驗證**。此作法是來源保存／資料落地，不是把上游程式直接覆蓋到正式遊戲目錄。

本輪新增 8 個快照檔案；每個檔案以 GitHub Contents API 成功回傳的 Commit SHA 寫入開發分支。尚未執行 Docker、Actions 或 Runtime 測試。

## 8. 本輪最新進度更新

- 最新稽核文件 Commit：`ca677360fb02b0bb926105b36b088288b49c25cb`；8 個快照檔案最後一筆 Commit：`a7fa02ae1c20ebf721ad87b659394a6775ac26b4`
- 新增快照數：8（5 份文件、3 份 LPC）
- 遊戲 Runtime 匯入數：0（本輪刻意未直接覆蓋 Runtime）
- 全量差異清單：仍未完成
- 全量整合：仍未完成
- PR #13：必須維持 OPEN / NOT MERGED
