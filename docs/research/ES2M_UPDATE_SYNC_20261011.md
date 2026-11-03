# ES2M 更新核對與 KING 整合紀錄（2026-10-11）

## 來源基準

- 上游：`https://github.com/wolfer168/es2-webmud`
- 上游分支：`main`
- 最新 HEAD：`a1d4f08bcb4a24dbe9abb8618bd32f8e8f0b2192`
- 前次核對 HEAD：`06e8f68f89d8da62507726b60208408ad320c899`
- Compare 結果：13 commits ahead；21 個變更檔案。
- KING 分支：`build/original-es2-races-phase2`
- PR #13：必須維持 OPEN / NOT MERGED。

## 本次已整合至 KING Runtime Overlay

| 檔案 | 同步內容 | 保護規則 |
|---|---|---|
| `feature/char/skill.c` | 技能屬性成長機率同步 ES2M 最新八段分級表 | 保留 KING 專屬 `king` 300 級上限條件、其他玩家 200 級上限與既有技能門檻；未把 ES2M 的人物升級流程整檔覆蓋 |
| `std/martial_art.c` | 一般出招與特效攻擊加入武器參數物件型別防護 | 保留 KING 武功引擎與每級獎勵 |
| `d/snow/npc/obj/pot.c` | 水喝完後重新建立並補滿 | 以 Runtime Overlay 局部覆蓋，不改 Original ES2 原始保存 |
| `d/snow/npc/obj/wine_pot.c` | 酒喝完後重新建立並補滿 | 以 Runtime Overlay 局部覆蓋，不改 Original ES2 原始保存 |

## 已更新 ES2M 來源快照

`es2m_snapshot/mudlib/` 已同步本次上游變更中 11 個 mudlib 檔案；瘋虎功快照刻意保留 KING 使用者指定的成長表。ES2M 最新瘋虎功原始檔另完整保存在 `source/es2m_updates/20261011_latest/source/upstream/mudlib/daemon/skill/tiger-force.c`。新增的 gain／score／room 檔案只作來源快照，不自動成為 Runtime Overlay。

完整 21 個變更檔案（含設計文件、測試與 Web UI）已保存於 `source/es2m_updates/20261011_latest/`，另保留前次新增的 `custom/wizroom/w/windstory/room/home.c`。

## 暫不直接移植的內容

以下更新已保留在 ES2M 快照與來源封存，但不直接覆蓋 KING Runtime：

1. `adm/daemons/combatd.c`：戰鬥核心高影響變更，必須先對照 KING 的 NPC 強度、閃避／招架、戰鬥經驗及 Original ES2 相容性。
2. `cmds/usr/gain.c`、`feature/char/score.c`、`cmds/usr/score.c`：ES2M 引入 gain 時技能／人物升級與狀態顯示契約；KING 有獨立技能成長及 300 級授權規則，尚不能整檔覆蓋。特別是 `try_level_up()`／`apply_gain_progression()` 不可在沒有相容實作與回歸測試前直接啟用。
3. `std/room.c`：共用房間基礎類別，先保存，避免影響全世界地圖。
4. `d/lee/obj/well.c`：來源註明為 ES2M 新增的李家村水井；尚未確認 KING 地圖出口與房間配置，暫不部署。
5. `daemon/skill/hainmay_force.c`：雖已同步最新上游版本至來源快照，但寒梅心法屬既有凍結的 KING 自訂武功；為保護既定設計，Runtime 仍保留 `king_frozen_baseline` 版本。上游的 `mm_minus = 29`、門派／等級限制及內功點數公式列為待評估差異，不直接覆蓋。
6. `daemon/skill/tiger-force.c`：保留上游版本於快照；KING 瘋虎功有使用者指定的成長表，不以整檔覆蓋。
7. Web UI 與 ES2M 自身測試：只保存為外部來源證據，不混入 KING 遊戲 Runtime。

## 驗證狀態

- 上游 HEAD／差異核對：**PASS**（13 commits／21 files）。
- 原始來源與測試／文件／Web 檔案封存：已建立。
- Runtime 靜態契約測試：修正 `scripts/test_es2m_latest_martial_updates.py` 中瘋虎功的來源判定。ES2M 武術造詣／武學之道規則改由上游原始碼封存檢查；KING snapshot 獨立檢查使用者定案的自訂成長表，避免把兩種版本的正確差異誤判成 FAIL。
- GitHub Actions：最新 `ES2M Update Sync Regression` 與 `ES2M Update Snapshot Gate` 仍顯示 **FAIL**，但最新執行的 job 均為 `runner_id=0`、`steps=[]`、`logs_url=null`，且約 2～3 秒內結束；證據顯示 GitHub 尚未指派 Runner，無法從這些執行結果判定測試程式是否通過。已將最新武學契約測試加入 Snapshot Gate，並修正 Sync Regression 的報告路徑。不得宣稱 Actions PASS。
- LPC 編譯、Neolith 實機與玩家端到端測試：尚未執行，不宣稱 PASS。
- Original ES2 原始保存：未修改。
- PR #13：不合併。

## 後續優先項目

1. 先恢復／確認 GitHub Actions Runner 可用性；目前 job 沒有執行步驟與日誌，不能把 Runner 未啟動當成程式測試失敗。Runner 可用後重新執行兩個 ES2M 閘門，取得真正的測試輸出。
2. 若靜態測試通過，再針對 gain／人物升級機制做獨立相容性設計與測試；不可直接套用 ES2M 的整套角色升級程式。
3. 對 combatd 進行逐段差異審查，確認可安全移植的最小變更後再另行整合。
## 2026-10-14 — 寒梅心法同步邊界修正

- 重新比對上游 kds121tw/ES2-KDS 的 rebuild/es2-game、KING es2m_snapshot/mudlib/daemon/skill/hainmay_force.c 與 KING Runtime overlay。
- ES2M 原始快照 blob：f71871c01d26502cb5958ee668fc55c46ab8f90e；KING 凍結基準／Runtime overlay blob：1fc654ba02accb5c3ee864158c80b4c09e8433dd。
- 差異屬已登錄的待評估項目：mm_minus、修煉點數公式、冷梅莊／等級 15 學習限制與描述。依凍結規則，這些差異不可在建置時自動覆蓋。
- 已在 scripts/apply_es2_king_expansion.sh 增加 build gate：Runtime overlay 必須與 es2m_snapshot/king_frozen_baseline/daemon/skill/hainmay_force.c 完全一致；不一致即停止建置並輸出 diff。
- 靜態核對結果：ES2M snapshot 保留上游更新；KING overlay 與凍結基準 SHA 完全一致；KING 專屬成長公式未被覆蓋。
- GitHub Actions 觸發後仍是 failure，但相關 job 回傳 steps=[]，沒有執行測試步驟；分類為 INFRA FAIL，不可當作程式測試失敗或 PASS。尚未執行 Driver／遊戲實機驗證。
- PR #13 維持 OPEN / NOT MERGED；本輪未部署、未建立雲端資源。


## 2026-11-01 — ES2M 最新全量 Mudlib 同步（a60bd653）

### 來源與目標基準

- ES2M：`wolfer168/es2-webmud`，`main`，HEAD `a60bd653e75000614b3857efa1dddcd736dc3324`。
- 本次前一個已同步來源：`18cee8bcaff35d45ff20c5dfab2287cbba31d65b`；上游差異為 28 commits ahead，Compare API 列出 14 個變更檔案（其中 11 個位於 `source/upstream/mudlib/`，另 3 個為上游文件、測試與 Web UI，不屬於 KING Runtime Mudlib 同步範圍）。
- KING：`build/original-es2-races-phase2`；同步前 HEAD `8cf83c79725fb02f5003ab091387feffda28b7b5`。

### 執行結果

- GitHub Actions：`Sync ES2M Files Into KING Overlay`，Run ID `41300921266`，結論 **SUCCESS**。
- 同步後 KING HEAD：`e19689359678e16b1b17a7ffb05c742b6dd4d793`。
- 最新來源 Mudlib 檔案數：1,979。
- 新增：2；覆蓋既有 KING Runtime 檔案：13；內容已相同：1,964。
- 與 pinned Original ES2 不同的來源檔案：180（僅列入差異報告，不回寫 Original ES2）。
- 新增檔案：`data/chinese.o`、`data/emoted.o`。
- 覆蓋檔案：`cmds/std/sneak.c`、`cmds/usr/enable.c`、`cmds/usr/inventory.c`、`custom/legacy_npc/han_wen_suei.c`、`d/snow/npc/teacher.c`、`d/swaylan/lunmay/front_yard.c`、`d/swaylan/temple/gate.c`、`d/wutang/npc/may_yin_fong.c`、`daemon/skill/advance_lunmay.c`、`daemon/skill/hainmay_force.c`、`daemon/skill/lunmay.c`、`docs/help/fighter.lunmay.txt`、`feature/char/skill.c`。
- 逐檔結果與 SHA-256：`docs/research/ES2M_NEW_FILES_IMPORT_REPORT.json`；最新來源 manifest：`es2m_source_mirror/MANIFEST.json`。

### 保護與驗證界線

- 同步只寫入 `es2m_source_mirror/` 與 `es2_king_expansion/runtime/mudlib/`；不修改 pinned Original ES2。
- KING 沒有的路徑才新增；來源同路徑以 ES2M 覆蓋；來源沒有的 KING-only 檔案不刪除。
- 本次 ES2M 自身 Mudlib 同步 Workflow 已成功完成，代表鏡像與 Overlay 匯入步驟成功，不等同 LPC 編譯、Docker、Oracle Runtime 或玩家 E2E PASS。
- 同步後 GitHub PR workflows 因提交者為 `github-actions[bot]` 顯示 `action_required` 且沒有 jobs；該狀態不是測試 PASS，也不是程式 FAIL。此文件更新將由使用者提交身分觸發既有 ES2M 回歸工作流程，以取得實際測試結果。
- PR #13 維持 OPEN / NOT MERGED；本次不部署。


## 2026-11-03 — ES2M 最新來源全量鏡像與 KING Overlay 同步

### 來源與執行結果

- ES2M Repository：`wolfer168/es2-webmud`，branch `main`。
- 最新來源 HEAD：`69d222ecd3b2138a80b87f1dadce9103df278bb3`。
- 前次來源同步基準：`a60bd653e75000614b3857efa1dddcd736dc3324`；本輪差異為 41 commits、47 個變更檔案（含 Mudlib、文件、測試與 Web UI）。
- KING Repository：`yilin1201/ES2-KING-MUD`，branch `build/original-es2-races-phase2`。
- 執行 Workflow：`Sync ES2M Files Into KING Overlay`，Run ID `41564713563`，結論 **SUCCESS**。
- 最新來源 Mudlib：1,991 檔案。
- KING Overlay 同步結果：新增 3、覆蓋 17、內容相同 1,959、保留 KING 專屬保護檔 12。
- 與 pinned Original ES2 不同的來源檔案：184；僅列入差異報告，不回寫 Original ES2。
- 完整逐檔 SHA-256 與結果：`docs/research/ES2M_NEW_FILES_IMPORT_REPORT.json`。
- 最新來源 manifest：`es2m_source_mirror/MANIFEST.json`。

### 登入核心相容性與驗收修正

- 最新 ES2M `adm/daemons/logind.c` 採用業力可選種族清單、`show_race_menu()`、`affordable_races()` 與 `input_to("get_race", ob, list)` callback。
- `scripts/apply_es2_king_expansion.sh` 已具有新版 callback 分支：保留 ES2M 種族選擇流程，並在生成 Runtime 加入 KING Owner Claim 與 Public Character Text Input 相容層。
- 舊版 `assert_m30_final_runtime.sh` 仍要求固定 12 項數字選單與舊 callback `get_race(string, object)`，與最新 ES2M API 不符，造成 2026-11-01 Render build 在最終 Runtime Assertion 停止。
- 本次將驗收改為核對新版 callback、業力種族清單及 KING Public Character Text Input marker；不再要求過時的固定數字選單。
- 此修改只更新驗收契約，不改寫 ES2M 原始種族選擇邏輯，也不變更 KING Owner Claim 程式。

### 部署狀態

- ES2M Source Mirror 與 KING Overlay 同步：**PASS**。
- Original ES2 保存來源：未修改。
- PR #13：維持 OPEN / NOT MERGED。
- M30 Alpha／ES2M Regression 與 Render Docker 部署：待本次新版驗收工作流程及後續部署確認，不預先宣稱 PASS。
