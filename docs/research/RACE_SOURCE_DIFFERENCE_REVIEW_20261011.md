# Original ES2／ES2-KING／wolfer168 種族差異評估（2026-10-11）

## 目的與證據分層

本文件區分 Original ES2 可驗證基準、第三方重建資料與 ES2-KING Expansion。第三方程式可用於差異比對，不得直接當成 Original ES2 的已確認設定。

- **Original ES2**：以對應上游原始碼、已驗證 Runtime 證據為準。
- **Third-party reconstruction**：wolfer168/es2-webmud；該版本部分 race 檔頭明確註記為使用者提供的自訂 A–H 種族資料。
- **ES2-KING Expansion**：由專案擁有者確認的 KING 設計；不能反向證明 Original ES2。

## 1. M5 Human／Avatar：保留已驗證的 Original 基準

KING 的 `original_es2/runtime/m5_race_framework_result.md` 保存了 M5 實機證據。該文件所記錄的基準為：

| 項目 | Original ES2 Human | Original ES2 Avatar |
|---|---|---|
| 八項屬性初始化 | 各項為 `13 + random(6)`，範圍 13–18 | 各項為 `16 + random(3)`，範圍 16–18 |
| Gin／Kee／Sen | 30／30／30 | 30／30／30 |
| 自然護甲 | +3 | +5 |
| 證據狀態 | 已記錄實機建立與 Runtime probe | 已記錄實機建立與 Runtime probe |

wolfer168 第三方重建差異：

| 項目 | wolfer168 Human | wolfer168 Avatar |
|---|---|---|
| 八項屬性 | `13 + random(6)`，13–18 | `15 + random(6)`，15–20 |
| Gin／Kee／Sen | 35／35／35 | 30／30／30 |
| 自然護甲 | +10 | +10 |
| 證據狀態 | 第三方重建，不等於 Original ES2 | 第三方重建，不等於 Original ES2 |

**處理決策：** 不修改已驗證的 Original ES2 M5 預期值以配合 wolfer168。M5 測試繼續驗證 Original Human／Avatar；第三方值只列於差異文件或獨立測試，不混入原版驗收條件。

## 2. 刑天／Headless

wolfer168 `headless.c` 記錄的屬性、精氣神、自然護甲、攻防、職業等級與裝備限制，已列入 `es2_king_expansion/races/headless.md` 的「第三方重建資料對照」段落，以及 `docs/research/THIRD_PARTY_CONTENT_INVENTORY_20261011.md` 的獨立來源登記。為維持 Original／第三方分層，`original_es2/races/headless.md` 只保留指向第三方索引的連結，不再內嵌第三方數值。

**處理決策：** 不將自然護甲 +50、攻擊 +30、防禦 +20 或裝備限制直接套入 KING Runtime。KING 保留已確認的高定力（`cps`）、一般膽識（`cor`）、學習速度 60% 等設計，數值待全種族平衡階段統一決定。

## 3. 帳號分片目錄

Original ES2 bootstrap 原先只建立 `login/a-z` 與 `user/a-z`。若帳號驗證允許數字開頭，而資料路徑依帳號首字元分片，則數字帳號可能在存檔或重新登入時失敗。

**本次修改：**
- `scripts/bootstrap_original_es2.sh`：新增 `login/0-9` 與 `user/0-9` 分片目錄。
- `scripts/test_original_player_creation_e2e.sh`：測試 Runtime 同時建立英文字母與數字目錄。
- `scripts/test_original_player_creation_e2e.mjs`：新增帳號 `7probe` 的 Human 創角、存檔、登出與重新登入旅程；必須輸出 `ORIGINAL_PLAYER_CREATION_NUMERIC_ID_E2E_PASS`。

此修改已寫入 Repository，但尚未取得本輪真實 Driver E2E 執行結果。若上游 `check_legal_id` 實際拒絕數字開頭帳號，測試將明確失敗，需依實際規則調整，而不能宣稱已修好。

## 4. ENABLE_ANTISPAM

KING bootstrap 的政策是：保留 Original source checkout 作為研究基線，但在準備好的測試／執行環境停用 `ENABLE_ANTISPAM`。此為 KING Runtime 決策，不代表應修改原始保存檔。

**處理決策：** 不為了與 wolfer168 的 `login.h` 一致而改變 KING 政策。驗收須檢查實際建置環境的生效設定，不能只比對單一來源檔。

## 5. Port 與 Oracle 部署

KING 已有 `deploy/oracle/setup.sh`、`update.sh`、`https.sh` 及 README。現行文件採 Web 8080、Neolith TCP 4000 內部使用、Caddy 對外 HTTPS。

**處理決策：** 不單獨把 4000 改成 4001。只有在確認 Bridge、Driver、Docker Port Mapping、健康檢查及部署環境都採用新連線契約後，才可成套調整。

## 6. 備份與 Expansion 索引

Oracle VM 的 Docker Volume 是持久化，不等於已有異地備份或還原證據。本次新增 `deploy/oracle/backup.sh`，可對玩家檔案資料建立 tar.gz、SHA-256 校驗碼與保留期限；預設拒絕把備份寫到同一檔案系統。但此腳本尚未完成實際異地備份與還原演練，也不取代 Neon/Postgres 供應商端備份。後續仍需盤點檔案資料與 Neon 資料的實際責任範圍，補上排程、失敗通知與隔離環境還原驗證。

A–H 種族、家園、老松林等第三方內容應登記於 Expansion／來源索引，逐筆記錄來源、可信度、是否採用與驗證狀態；不得自動寫回 Original ES2。

## 7. 驗證狀態

- [x] 重新讀取目前分支 M5 證據與種族文件。
- [x] 保留 Original Human／Avatar M5 的已驗證契約。
- [x] 更新 bootstrap 與玩家創角 E2E 測試，使其覆蓋數字分片目錄與 `7probe`。
- [x] 補充 Headless 第三方差異表，未將其自動採用為 KING 設定。
- [x] 新增第三方內容來源索引，並將 Original 刑天考證檔與第三方數值表分開保存。
- [ ] 本輪尚未執行 Neolith Driver／LPC Runtime E2E。
- [ ] 尚未驗證數字開頭帳號是否被上游合法性規則接受。
- [x] 新增 Oracle 玩家檔案備份腳本與操作文件（尚未執行實際備份）。
- [ ] 尚未完成 Oracle 異地備份及還原演練。
- [ ] GitHub Actions Runner 先前出現無 Runner／無 steps／無 logs 的 INFRA 問題；需以實際執行結果驗收。

PR #13 必須保持 OPEN / NOT MERGED。
