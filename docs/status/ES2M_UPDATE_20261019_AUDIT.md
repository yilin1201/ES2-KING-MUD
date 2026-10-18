# ES2M 上游更新稽核與候選快照（2026-10-19）

## 來源與差異
- 上游：`wolfer168/es2-webmud`
- 固定舊快照：`71693beb79ced81d51719ea1ccf7c02c641ca9b0`
- 最新上游 HEAD：`8baf4c9d39feafd56804194b282cea60e3f166ac`
- 新增提交：40；差異路徑：82
- 路徑狀態：`{"modified":28,"added":39,"removed":9,"renamed":6}`

## 已寫入 KING Repository
- 最新上游現行檔案：73 個，存於 `es2m_snapshot/latest_source_candidate/8baf4c9d/`。
- 每個候選檔案以 Git blob SHA 與上游最新樹逐檔比對；SHA 不一致數：0。
- 上游刪除路徑：9 個，只列入 manifest，不刪除 KING 檔案。
- 完整清單、舊／新路徑、狀態、差異量、上游與 KING 候選 SHA、分類及核對結果：`es2m_snapshot/latest_source_candidate/8baf4c9d/manifest.json`。

## 分類與保護
- 煉丹／藥鋪系統：候選來源已保存；Runtime 仍需檢查依賴、指令掛勾、配方、庫存及生命週期。
- 新增技能 `liuh-ken.c`、`chaos-steps.c`、`fonxansword.c`、`fonxan_force.c`：HOLD，須按既定順序逐項測試。
- `combatd.c`／`combat.c`：戰鬥核心 HOLD。
- `d/snow/npc/teacher.c`：保留 KING 自訂版本；最新上游版本只在候選快照保存。
- 其他修改檔逐檔相容性審查；任何上游刪除都不直接套用到 KING。
- 原有 71693beb 快照、Original ES2、KING Expansion 與凍結武學不覆蓋。

## 驗證狀態
- 上游比較與候選內容保存：已執行。
- 候選內容 SHA 逐檔一致：PASS。
- Runtime 套用／遊戲實際驗證：NOT RUN。
- Docker／E2E／Actions：本次未宣稱通過。
- PR #13：維持 OPEN / NOT MERGED；Render 未部署。
