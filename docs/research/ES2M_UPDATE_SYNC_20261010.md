# ES2M 更新同步稽核 — 2026-10-10

## 目的與來源基準

本文件記錄 ES2M 上游更新是否已同步至 ES2-KING，不代表僅憑靜態檢查就宣稱所有玩法均已通過。

- 上游 Repository：`wolfer168/es2-webmud`
- 本次上游 HEAD：`60c12efac447d63730f953ac83ef47fdc62f7368`
- 本次範圍：2026-10-09 上游最新合併內容，尤其是 PR #26～#30 相關更新。
- King 開發分支：`build/original-es2-races-phase2`
- 保護原則：不直接覆寫 Original ES2 保存來源；已完成的 King 自訂武功與技能成長規則不得被 ES2M 整檔覆蓋；PR #13 保持 OPEN / NOT MERGED。

## 同步核對結果

| ES2M 更新 | King 落點 | 稽核結果 |
|---|---|---|
| `disable` 可停用所有已學技能，含沒有技能檔的基本技能 | `es2_king_expansion/runtime/mudlib/cmds/usr/disable.c` | 與 ES2M `main` 同一 Git blob：`e1303e0035c10f153b549c76e20059d5ed8e4d75` |
| `enable` 支援已具有效技能等級的基本技能 | `es2_king_expansion/runtime/mudlib/cmds/usr/enable.c` | 與 ES2M `main` 同一 Git blob：`233d824854baa960ec6d90019947d9e8ebe5bd7d` |
| `abandon` 驗證已學技能、重複操作與恢復訊息 | `es2_king_expansion/runtime/mudlib/cmds/usr/abandon.c` | 與 ES2M `main` 同一 Git blob：`e3c739bdf9b2890505afd87d5f3ac179d1a6cb92` |
| 私塾王懷芝：讀書點數、坐下狀態、NPC 強度及學習條件 | `es2_king_expansion/runtime/mudlib/d/snow/npc/teacher.c` | 與 ES2M `main` 同一 Git blob：`3418099cb14f82665b261634d189551244859a10`；生成 Runtime 另套用 UTF-8 回答相容修正 |
| 新版武功引擎支援學成當級獎勵 | `es2_king_expansion/runtime/mudlib/std/martial_art.c` | 與 ES2M `main` 同一 Git blob：`50fc14306147723b9a49d026efc04d96f0c0860d` |
| 七巧如意手（`seven`） | `es2_king_expansion/runtime/mudlib/daemon/skill/seven.c` | 與 ES2M `main` 同一 Git blob：`8596aa0156230e886d28a74b10973bb3f66bc528` |
| 梅影身法（`mayin`） | `es2_king_expansion/runtime/mudlib/daemon/skill/mayin.c` | 與 ES2M `main` 同一 Git blob：`4481fd68a67d3340c7ae7f3da298f657efb114e6` |
| 冷梅莊莊主梅影風與五堂鎮生成點 | `es2_king_expansion/runtime/mudlib/d/wutang/npc/may_yin_fong.c`、`crossroad.c` | NPC 已同步並保留 King 必要差異；生成點 `crossroad.c` 與 ES2M 同 blob：`d4d3269d42f83d0b219cc42c605361a20bbf7ca9` |
| 練武假人：必定命中、不閃躲／格擋、不顯示部位與傷勢，並調整 fight／kill／look | `scripts/apply_es2_king_expansion.sh` 於生成 Runtime 套用 | 已有冪等補丁及 `scripts/test_es2m_training_dummy.py` Runtime Gate；不改寫 Original 保存來源 |

## 本輪補齊的快照落差

第一次比對發現：ES2M 原始快照內的虎刀門相關檔案落後於上游最新更新，單靠既有「檔案存在」檢查不足以攔截。已於本輪補齊：

| 更新 | King 實作 |
|---|---|
| 狻猊步法 `tiger-steps.c` | 將快照更新至 ES2M 最新來源 blob `cae9e59ba2e14b40cd4cb14bc6eefa372ce6cb11`；五句敘述交由 `defend_message` 在實際閃避成功後顯示，並保留學成 10 級、11 級起武術造詣及 41 級起武學之道。 |
| 三門刀法 `sanmeendo.c` | 保留 King 既有招式資料，只補入每級武術造詣與 30 級起 `(lv - 29) × 10` 武學之道。 |
| 瘋虎功 `tiger-force.c` | 保留 King 自訂精氣上限、90 級分歧及練功公式；在既有逐級成長迴圈中補入武術造詣，以及 31 級起 `(lv - 30) × 10` 武學之道。 |
| 高慎 `kao_shen.c` | 只更新瘋虎刀法門檻提示，保留 King 的拜師與授技重建邏輯。 |
| 私塾快照 | 更新為 ES2M 最新來源 blob `3418099cb14f82665b261634d189551244859a10`；King Runtime overlay 保留正式種族代碼 `rainnar`，生成 Runtime 另修復 UTF-8 回答。 |

新增 `scripts/test_es2m_latest_martial_updates.py`，同時檢查來源快照與生成 Runtime；Dockerfile 已納入此 Gate。同步工作流程 `.github/workflows/es2m-update-sync-regression.yml` 也會執行這項檢查，避免未來只更新文件或只確認檔案存在。

## King 保留的必要差異

梅影風 NPC 檔案不與 ES2M 逐位元相同，這是刻意保留的 King 相容修正，不能用上游整檔覆蓋：

1. ES2M 上游使用 `rainner`；King 正式種族代碼是 `rainnar`，King 檔案採 `rainnar`。
2. King 依 `skill_entry_level(skill)` 及 `skill_threshold(skill, entry_level)` 計算傳授補點，避免高入門等級武功被錯誤地只補到 1 級門檻。
3. 冷梅莊既有凍結武功維持 King/KDS 基準；只同步新增的 `seven`、`mayin`，不以 ES2M 新版整檔覆蓋既有凍結檔案。

## 驗證方式與證據邊界

Dockerfile 已將以下測試接入生成 Runtime 建置流程：

- `python3 scripts/test_es2m_training_dummy.py --runtime /opt/es2-king/runtime`
- `python3 scripts/test_es2m_skill_commands.py --runtime /opt/es2-king/runtime`
- `python3 scripts/test_es2m_cold_plum_overlay.py --runtime /opt/es2-king/runtime`
- `python3 scripts/test_es2m_latest_martial_updates.py --runtime /opt/es2-king/runtime`
- `ES2_DRIVER_BIN=/opt/es2-king/bin/neolith bash scripts/test_es2m_latest_martial_lpc_load.sh /opt/es2-king/runtime`（Driver Build 後真實載入狻猊步法、三門刀法、瘋虎功與高慎）

這些閘門驗證來源／Expansion／生成 Runtime 的檔案一致性與關鍵契約。它們本身不取代 Neolith Driver 的完整遊戲內 E2E；只有取得相應真實 Runtime marker 才能宣稱玩法驗收 PASS。

## 結論

截至 ES2M 上游 HEAD `60c12ef`，已補齊狻猊步法、三門刀法、瘋虎功、高慎與私塾快照的已確認差異，並加入來源／Runtime 一致性測試。這些修改只作用於 ES2M 快照、King 相容層及生成 Runtime，不整檔覆寫 Original ES2。同步靜態工作流程已執行成功；Dockerfile 現已加入完整快照匯入後的真實 Neolith LPC Load Gate，該新 Gate 需待完整 Docker/部署建置執行後才可標記 PASS。PR #13 保持開啟、不合併。

## 2026-10-10 實際分支／Actions 複核紀錄

本節記錄本次重新連接 GitHub 後的實際查核結果；不將來源保存或 LPC 載入擴大解讀為完整玩法驗收。

- ES2M `main` HEAD：`60c12efac447d63730f953ac83ef47fdc62f7368`（已重新讀取上游 refs/commit）。
- KING 查核時的分支 HEAD：`f2ac9c6b29919536dd76aa36be6c915992f74c33`；PR #13 查核結果為 OPEN、NOT MERGED。
- `ES2M Update Sync Regression` Run `38029863328`：SUCCESS；訓練假人／私塾契約、技能狀態指令、冷梅莊相容性、最新武學成長與來源快照等步驟均成功。
- `ES2M Update Snapshot Gate` Run `38029863329`：SUCCESS；Python 語法、來源快照、戰鬥成長契約、冷梅莊 overlay、技能清單與技能指令檢查均成功。
- `ES2-KING M30 Alpha` Run `38029863378`：SUCCESS；包含 Expansion Runtime Gate、ES2M 訓練假人／私塾閘門、冷梅莊／技能指令檢查、Driver Build、冷梅莊 LPC Load 與 ADMIN GM LPC Load。
- 同一查核批次的 `ADMIN GM Regression` Run `38029863416`：SUCCESS。

### 本次確認的剩餘界線

1. 上述成功代表目前分支的指定靜態／Runtime 閘門與 LPC 載入步驟通過，不代表梅影風完整拜師、五項武學實戰、NPC 強度數值平衡或全部區域 NPC 已完成普通玩家 E2E。
2. ES2M 本輪區域 NPC 差異繼續保存在來源證據層；未經逐檔相容性審查，不批次覆蓋 KING／Original 同名 NPC。
3. 後續優先處理梅影風拜師與技能傳授的真實玩家流程、NPC 強度數值驗證，以及區域 NPC 變更的分區回歸；每項需有獨立 Runtime 證據才可升級為 PASS。
