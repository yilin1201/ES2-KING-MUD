# M30 CURRENT STATUS — 目前唯一即時狀態入口

> Status Date：2026-09-27  
> Branch：`build/original-es2-races-phase2`  
> Post-Neon Audit Baseline：`15e27c606886f1b96c2bbe5bda037989c767becb`  
> Cold Plum Runtime Evidence Head：`f1b6798ce3562551a10d76521f886b5445d35b1f`  
> 本文件是 Current Status（目前狀態），不是歷史測試報告。  
> PR #13：OPEN（開啟） / NOT MERGED（未合併）。M31：Class 職業系統，BOUNDED RUNTIME PASS。

## 1. Game Completion（遊戲完整可玩性）

| 項目 | 實際 Runtime 狀態 |
|---|---|
| Full Driver Journey（完整真實 Driver 流程） | PLAYABLE PASS（實際可遊玩驗收通過） |
| NPC interaction（非玩家角色互動） | RUNTIME PASS（真實執行環境通過） |
| Economy / Shop（經濟／商店） | RUNTIME PASS（Original 貨幣扣款、Vendor 交貨與 Inventory 餘額通過） |
| Items / Equipment（物品／裝備） | RUNTIME PASS（真實執行環境通過） |
| Combat（戰鬥） | RUNTIME PASS（真實執行環境通過） |
| Skills（技能） | RUNTIME PASS（真實執行環境通過） |
| School / Apprentice（門派／師徒） | RUNTIME PASS（真實執行環境通過） |
| Save / Quit / Relogin（存檔／離開／重新登入） | RUNTIME PASS（真實執行環境通過） |
| Quest（任務） | PARTIAL（Snow 盜賊入門鏈 Runtime PASS；其他斷鏈不補造） |
| World / NPC / Item / Death Recovery | RUNTIME PASS（Snow 保存區逐路徑、NPC death/respawn、corpse loot、玩家 ghost／寺廟復活通過） |
| Social / Communication | RUNTIME PASS（隔離雙玩家 say／tell／reply／UTF-8／斷線重登通過；跨 MUD GTELL 維持 UNKNOWN） |

實際完成流程：

`Connect → Login → Character → Enter World → Look → Score → Inventory → Movement → NPC → Economy/Shop → Items/Equipment → Combat → Skills → School/Apprentice → Save → Quit → Relogin`

因此目前正式判定：**GAME COMPLETION = PLAYABLE PASS（遊戲完整可玩性通過）**。

2026-09-27 新增完整可玩性 Gate：`scripts/test_game_playability_completion_e2e.sh`。真實 Driver 成功標記為 `GAME_PLAYABILITY_COMPLETION_RUNTIME_PASS`，詳細 PASS／UNKNOWN 邊界記錄於 `original_es2/research/game_playability_completion_audit.md`。該次 Gate 只找到 Snow `try/fon` 故事殘鏈，當時 Quest 判定為 UNKNOWN；後續 Phase 2 擴大掃描的新結論如下。

2026-09-27 Game Content Completion Phase 2 擴大掃描 43 個 Snow room、23 個 NPC 與 58 個 Snow／shared area object template。新發現並以隔離真實 Driver 閉合「店小二食物→阿寶梳子→瞎眼老太婆→盜賊職業／技能學習進度→save／relogin」目標版本鏈，marker 為 `ORIGINAL_THIEF_PROGRESSION_RUNTIME_PASS`；Quest 全域狀態因此更新為 PARTIAL。`try/fon`、英雄帖→缺少 Snowkeep、警捕 NPC 與紅酒依賴仍保持 PARTIAL／BROKEN／UNKNOWN。完整清冊見 `original_es2/research/game_content_inventory_phase2.md`。

### 1.1 M30 後續維護：冷梅莊／KING 99 Runtime

本項屬既有 M30 ES2-KING Alpha 的維護與驗證，不建立、命名或啟動 M31。

| 驗收項目 | 最新 GitHub／Runtime 狀態 |
|---|---|
| KING 八項屬性 | RUNTIME PASS：`str/cor/int/spi/cps/dex/con/wis = 99`；只有精確帳號 `king` 可突破 Original 50 上限 |
| KING Owner／Admin boundary | RUNTIME PASS：互動登入、精確帳號 ID 與 Original admin 三項授權條件均保留 |
| KING 冷梅莊技能 | RUNTIME PASS：`hainmay force`、`advance_lunmay`、`lunmay`、`mayin`、`seven` 與五項基本 Combat usage 均為 Original 玩家上限 200 |
| 梅寒霜 | RUNTIME PASS：八項屬性 50；十項 Arena effective skills 300；不改寫全域玩家上限 |
| 明鏡止水／冷梅 Combat | RUNTIME PASS：明鏡止水 Combat State、冷梅五式、傲梅暗劍訣進階招式及 Original Combat 串接均通過 |
| 演武界 | RUNTIME PASS：無極之境 `enter`、演武界 `out`、梅寒霜生成與 Arena defeat protection 均通過 |
| Character lifecycle | RUNTIME PASS：隔離 KING fixture 完成 save／quit／新連線 relogin，8×99、技能與 mapping restore 通過 |

完整真實 Driver Gate：`scripts/test_cold_plum_arena_runtime_e2e.sh`。成功證據必須包含 `COLD_PLUM_RUNTIME_PASS`，不得以 Static PASS 或 Render LIVE 取代。Evidence Boundary 與 UNKNOWN 數值記錄於 `original_es2/research/cold_plum_mirror_combat_runtime.md`。

### 1.2 M31：Class 職業系統

Owner 於 2026-09-26 正式指定 M31 主題為 Class 職業系統。Evidence 與實作範圍記錄於 `original_es2/research/m31_class_runtime_completion.md`；正式 Gate 已通過：

- Static：`scripts/test_m31_class_static.sh` — PASS
- True Driver E2E：`scripts/test_m31_class_runtime_e2e.sh` — PASS
- Success marker：`M31_CLASS_RUNTIME_PASS` — CONFIRMED

本階段完成有直接 Source 的 `commoner → apprentice → alchemist` 轉職鏈、Archived Evidence 支持的「方士」稱謂，以及隔離玩家 save／quit／relogin／restore。其他遺失職業 Daemon、初始化／升級公式、能力、裝備限制與門派條件維持 `SOURCE_REQUIRED / UNKNOWN`；因此 M31 為證據邊界內的 BOUNDED RUNTIME PASS，不宣稱七職業內容全部復原。

## 2. Evidence 與 Runtime 分層

- Evidence（證據）記錄 Original ES2 的來源可信度與尚未確認內容。
- Runtime（執行環境）記錄真正由 Neolith Driver（Neolith 遊戲執行引擎）執行的結果。
- Full Driver Runtime Gate（完整 Driver 執行關卡）已在上述 Evidence Head 實際通過。
- Runtime PASS 不會把 Quest 或其他缺少 Original 史料的項目自動提升為歷史 CONFIRMED（已由史料直接證實）。

## 3. Public Compatibility / Render

| Release Gate（發布關卡） | 狀態 |
|---|---|
| Primary Public Runtime（主要公開執行環境） | `ES2-KING-MUD`／https://es2-king-mud.onrender.com |
| Repository / Render Sync（版本同步） | PASS（測試通過）：正式部署以公開 `/health` 的 `build_commit` 精確等於 Branch HEAD 為準；本輪 Playability Commit 已完成新容器部署並核對 |
| Public Runtime Chain（公開執行鏈） | PASS（測試通過）：HTTPS → WSS → Bridge → Neolith；`web`、`bridge`、`neolith` 均為 `true` |
| Public Race Runtime（公開種族執行流程） | PASS（測試通過）：真實公開 WSS 完成 Account → Password → Email → Race → Gender → Character → Enter Game |
| Public Device Acceptance（公開裝置驗收） | PASS（Owner 已確認 iPhone Public Runtime） |
| Public Compatibility（公開環境相容性） | PASS（Web Client、公開 WSS 與 iPhone Entry 已通過） |
| Temporary Validation Service（臨時驗證服務） | `es2-king-alpha`：TEMP / UNCHANGED（臨時／未修改，不是主線） |

Public Gate 是獨立 Release Gate，不回頭阻塞已取得的 Game Completion Runtime 證據。`heros-mud-rebuild` 屬另一獨立專案，未修改。

## 4. Permanent Persistence

Render Free 的 ephemeral filesystem 限制已由 Neon durable backing store 解決。Neolith 仍先寫入 mudlib 實體 `data/`，再以 checksummed opaque snapshot 同步 Neon；新容器會在 Driver 接受登入前還原。KING 已完成 Render New Container 的 Cross-Container Restore，正式判定 PASS。

## 5. 歷史文件定位

以下保留作 Historical Evidence（歷史證據），不可單獨覆蓋本文件：
- `docs/history/m30/M30_ALPHA_FINAL_AUDIT.md`
- `docs/history/m30/M30_PLAYABLE_ALPHA_ENTRY.md`
- `docs/history/m30/M30_DEPLOYMENT_READINESS.md`
- `original_es2/runtime/*`
- `es2_king_expansion/runtime/*_result.md`

Original ES2 Evidence Registry（證據登錄表）與 Source Manifest（來源清單）仍各自保持其證據效力。
