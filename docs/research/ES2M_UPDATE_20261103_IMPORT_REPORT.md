# ES2M 2026-11-03 更新匯入紀錄

## 來源與基準
- Source repository：`kds121tw/ES2M-KDS`
- Source branch：`main`
- Source HEAD：`ced29a6e9cdb0ce6e2392a80702295e350dbcb57`
- Source commit：`backup: update ES2M equipment-aware class stat growth files`
- KING target：`yilin1201/ES2-KING-MUD`
- KING branch：`build/original-es2-races-phase2`
- 匯入策略：ES2M 僅供讀取；保留 KING 自訂 Runtime 與既有擴充；不刪除 KING-only 檔案。

## 本次最新來源提交差異（相較前一個 ES2M-KDS commit）
| ES2M 路徑 | 類型 | KING 處理 |
|---|---|---|
| `docs/CUSTOM_RACE_A_H.md` | 文件更新 | 原文保存至 `es2m_snapshot/upstream_20261103/docs/CUSTOM_RACE_A_H.md` |
| `docs/TAOIST_CLASS.md` | 文件更新 | 原文保存至 `es2m_snapshot/upstream_20261103/docs/TAOIST_CLASS.md` |
| `source/upstream/mudlib/daemon/class/taoist.c` | LPC 原始碼 | 已存在於 ES2M Source Mirror，且 KING Runtime Overlay Blob SHA 與最新 ES2M 完全相同，不需覆蓋 |
| `source/upstream/mudlib/include/class_level.h` | LPC 標頭 | 已存在於 ES2M Source Mirror，且 KING Runtime Overlay Blob SHA 與最新 ES2M 完全相同，不需覆蓋 |

## 逐檔比對
- ES2M `source/upstream/mudlib/`：1,829 blobs
- KING `es2m_source_mirror/mudlib/`：1,829 blobs
- Mirror SHA 相同：1,829
- Mirror 缺漏／差異／多餘：0／0／0
- 本次兩個 Runtime LPC 變更檔均已與 ES2M 最新版一致。
- 沒有將 ES2M 根目錄所有開發工具、部署腳本、測試工具直接覆蓋 KING；這些不屬於可直接替換的 Mudlib Runtime。

## 保護事項
- 不寫入 ES2M、ES2M-KDS 或 ES2-KDS。
- 不反向同步 KING 到 ES2M。
- 不修改 Original ES2 唯讀基準。
- 不覆蓋 KING 自訂功能、Khome、梅寒霜、管理員權限及相容性修補。
- PR #13 保持 OPEN / NOT MERGED。

## 結論
本次最新 ES2M commit 的兩個 Mudlib 原始碼變更已經在 KING Mirror 與 Runtime Overlay 中，沒有額外 LPC 檔案需要覆蓋。兩份更新文件已作為日期化上游證據保存至 KING，避免覆蓋 KING 自訂文件。
