# ES2-KING Game Completion Matrix

> Updated：2026-09-27  
> Branch：`build/original-es2-races-phase2`  
> Playability Audit Baseline（可玩性稽核起點）：`79dfcf1b5b40fa3901c5ba221f7651975d6c844e`  
> PR #13：OPEN（開啟） / NOT MERGED（未合併）  
> 原則：preserve → understand → rebuild → expand。

此矩陣記錄 Game Completion Track（遊戲完整可玩性主線）與獨立 Public Release Gate（公開發布關卡）。主要公開執行環境固定為 `ES2-KING-MUD`；`es2-king-alpha` 僅為 TEMP / UNCHANGED（臨時／未修改）。

| 系統 | 狀態 | 本次 Runtime 證據／邊界 |
|---|---|---|
| Original ES2 Runtime | RUNTIME PASS | 同一 Neolith Full Driver Journey 實際執行 |
| Class / Apprentice | M31 + Phase 3 BOUNDED RUNTIME PASS | 真實 Driver 已通過 alchemist、scholar、thief Target transition；Fighter Historical Reconstruction 亦通過 `join→fighter→武者→save/relogin`。Taoist／Bonze／Soldier 維持 SOURCE_REQUIRED／EVIDENCE_EXHAUSTED |
| World / Map | RUNTIME PASS / BOUNDED | Snow 保存區所有玩家路徑及 custom action 已由真 Driver 逐段走通；未保存的完整歷史世界仍 UNKNOWN |
| Movement | RUNTIME PASS | 方向、enter、out、climb 與門實際通過 |
| NPC | RUNTIME PASS | look／ask／vendor、死亡／corpse 與 room reset 重生實際通過 |
| Economy / Shop | RUNTIME PASS | Original `buy` 實際扣款、Vendor 交貨與 Inventory 餘額通過 |
| Items / Equipment | RUNTIME PASS | get／look／corpse loot、wield／unwield、wear／remove 實際通過 |
| Combat | RUNTIME PASS | NPC defeat 與普通玩家 defeat／ghost／寺廟 recovery 實際通過 |
| Skills / Study / Force | RUNTIME PASS | Original dragon force 的 enable／map、exert、資源消耗、戰鬥修正與重登還原已由隔離真 Driver 通過 |
| Inventory Persistence | RUNTIME PASS / BOUNDED | Original money autoload 的合併數量 37 已跨 save／quit／relogin 精確還原；非 autoload 任意裝備仍不宣稱完成 |
| School / Apprentice | RUNTIME PASS | 門派／師徒流程實際通過 |
| Social / Communication | RUNTIME PASS / BOUNDED | 雙玩家 say／tell／reply、UTF-8、缺席玩家錯誤與斷線重登通過；跨 MUD GTELL 協定 UNKNOWN |
| Quest | PARTIAL / 3 RUNTIME PASS CHAINS | Snow thief、貨棧工錢與私塾 Scholar entry 均由真 Driver 完成並通過 save/relogin；`try/fon` 與英雄帖→Snowkeep 已 Evidence Exhausted，仍缺檔／斷鏈，不補造 |
| Character lifecycle | RUNTIME PASS | Character、Enter World 與生命週期串接通過 |
| Save / Quit / Relogin | RUNTIME PASS | 同一完整 Journey 實際完成存檔、離開與重新登入 |
| KING Authorization | RUNTIME PASS | 重用既有 KING fixture 與授權流程 |
| 天神殿／無極之境 | RUNTIME PASS | 既有 M27 Runtime 證據保持有效 |
| Expansion 武學 | RUNTIME PASS | 既有 M28/M29 Runtime 證據保持有效；未定義 Original 數值仍 UNKNOWN |
| Developer Bootstrap | COMPLETE | 已完成且供 Full Driver Journey 重用 |
| Full Game Journey | PLAYABLE PASS | 真 Driver 完成 `Login → World → NPC → Item → Equipment → Combat → Death/Recovery → Save → Quit → Reconnect/Restore`；既有 Skill／Apprentice／Class gates 同時保持 PASS |
| Primary Public Runtime | DEPLOYED / SYNCED | `ES2-KING-MUD`；每次正式驗收以公開 `/health` 的 `build_commit` 精確等於 Branch HEAD 為準 |
| Public Race Runtime | RUNTIME PASS | 真實公開 WSS 完成 Race → Gender → Character → Enter Game；不是 Static PASS |
| Public Device Acceptance | PASS | Owner 已確認 iPhone Public Runtime |
| Public Compatibility | PASS | 公開 Runtime、Web Client、WSS 與 iPhone Entry 均通過 |
| Render | RUNTIME PASS | HTTPS、WSS、Bridge、Neolith 與 Login Prompt 已在 Primary Service 實測通過 |
| Game Completion Track | PLAYABLE PASS | 五個缺口段落與完整 Journey 均取得真實 Neolith Runtime 證據 |

## 狀態規則

- `RUNTIME PASS`：已由真正 Neolith Driver 執行通過，不是 Static PASS（靜態檢查通過）。
- `PLAYABLE PASS`：完整玩家流程在單一真實 Driver Journey 中通過。
- `UNKNOWN`：Original 史料不足，禁止推測或補造。
- `PENDING`：只剩指定的 Owner 真實裝置驗收，不能用自動測試冒充。
- `PARTIAL`：公開程式與 Runtime 已通過，但 Owner Device Gate 尚未完成。
