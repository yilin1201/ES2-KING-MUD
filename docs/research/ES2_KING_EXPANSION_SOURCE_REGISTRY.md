# ES2-KING Expansion／第三方來源與採用登錄表

更新日期：2026-10-11

## 使用規則

本登錄表追蹤第三方資料、歷史重建與 ES2-KING 自訂內容的來源及採用狀態。出現在本表不代表已採用 Runtime，更不代表 Original ES2 Confirmed。

狀態定義：

- `SOURCE-ARCHIVED`：來源已保存，尚未採用。
- `REVIEWED`：已完成差異審查，仍須明確決策才可採用。
- `EXPANSION-ADOPTED`：專案擁有者已明確決定採用，並應有對應設計文件。
- `RUNTIME-PARTIAL`：部分接線或匯入，尚未完成端到端驗證。
- `RUNTIME-PASS`：具備可追溯 Runtime 驗證證據。
- `UNKNOWN`：證據不足，不能推定。

## 登錄清單

| 項目 | 來源／路徑 | 來源類型 | KING 狀態 | 採用規則／待辦 |
|---|---|---|---|---|
| Human／Avatar M5 | `original_es2/runtime/m5_race_framework_result.md` | Original ES2 Runtime 證據 | `SOURCE-CONFIRMED` | Human 13–18、護甲 +3；Avatar 16–18、護甲 +5；精氣神 30／30／30。不可用第三方數值覆蓋。 |
| 刑天／Headless | `original_es2/races/headless.md`、`es2_king_expansion/races/headless.md` | Original 考證＋KING Expansion＋第三方對照 | `REVIEWED` | 第三方數值、自然護甲 +50、攻擊 +30、防禦 +20、裝備限制只供比對；KING 既有高定力／一般膽識／60% 學習速度不自動變更。 |
| wolfer168 自訂 A–H 種族資料 | `wolfer168/es2-webmud` 的 race daemon；KING 僅引用已封存至 `source/es2m_updates/20261011_latest/` 的對應檔案（逐檔核對存在性） | 第三方自訂資料 | `SOURCE-ARCHIVED`／逐種族待核 | 來源檔頭若標註使用者提供的自訂種族資料，不能標成 Original ES2 Confirmed；每個種族分別記錄差異與 KING 採用狀態。 |
| 雪亭以外的家園／家園房間 | wolfer168／ES2M 上游來源與封存快照 | 第三方重建 | `UNKNOWN`（逐項審查） | 必須先登記房間檔案、出口、NPC、物品、任務與依賴；沒有完整拓樸證據不得直接部署。 |
| 老松林 Old Pine Forest | `es2m_snapshot/mudlib/d/oldpine/`、`scripts/test_es2m_oldpine_topology.py` | ES2M 第三方重建 | `RUNTIME-PARTIAL`（以最新測試結果更新） | 保留 ES2M 來源註記；先通過來源／Runtime 拓樸檢查，再確認入口、出口、NPC 與物件依賴。 |
| 李家村 Lee Village | `es2m_snapshot/mudlib/d/lee/`、`scripts/test_es2m_lee_topology.py` | ES2M 第三方重建 | `RUNTIME-PARTIAL`（以最新測試結果更新） | 需持續驗證雪亭東門接線、雙向出口、房間與任務相容性；不可改標 Original ES2。 |
| 振武軍營 Zhenwu | `es2m_snapshot/mudlib/custom/zhenwu/`、相關 topology／recruitment tests | ES2M 第三方重建 | `RUNTIME-PARTIAL`（以最新測試結果更新） | 保留徵兵規則來源；驗證雙向地圖接線與玩家端旅程。 |
| 五堂鎮 Wutang | `es2m_snapshot/mudlib/d/wutang/`、`scripts/test_es2m_wutang_topology.py` | ES2M 第三方重建 | `RUNTIME-PARTIAL`（以最新測試結果更新） | 需確認區域拓樸、入口與軍營連接，不能僅因檔案存在就宣稱完整可玩。 |
| ES2M 武學／裝備／NPC 更新 | `source/es2m_updates/20261011_latest/`、`es2m_snapshot/mudlib/` | 第三方上游快照 | `SOURCE-ARCHIVED` | Hainmay、瘋虎功及其他 KING 凍結／自訂項目依專案保護規則，不可整檔覆蓋。 |
| Oracle VM 部署 | `deploy/oracle/`（含 `backup.sh`） | KING 部署工具 | `EXPANSION-ADOPTED` | 4000 只作內部 Neolith TCP、8080 僅綁 loopback；已新增檔案備份腳本，但異地備份與還原尚未驗證。Port 不因第三方不同而單獨更改。 |

## 登錄維護規則

1. 新增第三方種族、家園、地圖、NPC、物品或任務時，先登錄來源與狀態，再決定是否採用。
2. 每項 `EXPANSION-ADOPTED` 必須指向專案擁有者確認的設計文件；僅有上游程式不構成採用授權。
3. 每項 `RUNTIME-PASS` 必須附實際測試名稱、執行版本／Commit 與結果；沒有日誌或沒有 Runner 的執行不得標成 PASS。
4. Original ES2 的證據只寫入 `original_es2/`；KING 設計只寫入 `es2_king_expansion/`；第三方來源保留在 source archive／snapshot 並在此表交叉引用。
5. 若來源無法存取、檔案缺失或拓樸不完整，標記 `UNKNOWN`／`SOURCE-ARCHIVED`，不得自行補造。
