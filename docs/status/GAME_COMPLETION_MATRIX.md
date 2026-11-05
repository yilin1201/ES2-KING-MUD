# ES2-KING Game Completion Matrix

> Updated：2026-09-29  
> Branch：`build/original-es2-races-phase2`  
> Playability Audit Baseline（可玩性稽核起點）：`79dfcf1b5b40fa3901c5ba221f7651975d6c844e`  
> PR #13：OPEN（開啟） / NOT MERGED（未合併）  
> 原則：preserve → understand → rebuild → expand。

此矩陣記錄 Game Completion Track（遊戲完整可玩性主線）與獨立 Public Release Gate（公開發布關卡）。主要公開執行環境固定為 `ES2-KING-MUD`；`es2-king-alpha` 僅為 TEMP / UNCHANGED（臨時／未修改）。

| 系統 | 狀態 | 證據／邊界 |
|---|---|---|
| Login | RUNTIME PASS | 真 Driver 與公開 WSS 登入已通過 |
| Character Creation | RUNTIME PASS | Race→Gender→Name→Enter Game 已由真 Runtime 驗證 |
| Human Race | RUNTIME PASS | M5 真 Driver 已驗證 human、Lv.1、屬性範圍、gin／kee／sen 與 armor；本輪另加精準 Source fixture |
| Other Races | PARTIAL | 公開 Race 選擇流程可執行；缺失 Original initializer 不補造，Expansion/Reconstruction 與 Original 分離 |
| Commoner | RUNTIME PASS | 新角色預設 class=commoner、Lv.1 |
| Fighter | RUNTIME PASS | Historical Reconstruction 已通過 join→fighter→武者→save/relogin |
| Taoist | SOURCE_REQUIRED | 缺 Target entry／recruit／class daemon／initialize／advance_level |
| Bonze | SOURCE_REQUIRED | 缺 Target entry／recruit／class daemon |
| Soldier | SOURCE_REQUIRED | 只有 NPC soldier；缺玩家 entry 與 class daemon |
| Scholar | RUNTIME PASS | Snow Scholar entry 與 save/relogin 已通過 |
| Thief | RUNTIME PASS | Snow thief progression 與 save/relogin 已通過 |
| Alchemist | RUNTIME PASS | Target class transition／rank compatibility 已驗證 |
| World Snow | RUNTIME PASS | 保存區玩家路徑與 custom action 已由真 Driver 走通 |
| Snowkeep | SOURCE_REQUIRED | invitation／guard 前置鏈已確認；`/d/snowkeep/` LPC 缺失 |
| NPC | RUNTIME PASS | look／ask／vendor、死亡／corpse、room reset 重生已通過 |
| Item | RUNTIME PASS | get／drop／give／look 與 loot 已通過 |
| Equipment | RUNTIME PASS | wield／unwield／wear／remove 已通過 |
| Inventory | RUNTIME PASS | Inventory 操作與 Original autoload 邊界已驗證；任意 non-autoload 保存為 N/A |
| Economy | RUNTIME PASS | 金錢取得、扣款與餘額已驗證 |
| Shop | RUNTIME PASS | Original buy、Vendor 交貨已驗證 |
| Combat | COMBAT PASS | NPC defeat 與玩家 defeat／recovery 已通過 |
| Skills | RUNTIME PASS | learn／study／enable／map／force 鏈已通過 |
| Martial | COMBAT PASS | 已有武學 Combat Runtime 證據；UNKNOWN 數值未補造 |
| Quest | PARTIAL | 三條既有 Runtime chain 通過；Random Task 與 Snowkeep 仍缺 Target Source |
| Death | RUNTIME PASS | 玩家 defeat／death 狀態已驗證 |
| Ghost | RUNTIME PASS | ghost→寺廟 recovery 已驗證 |
| Social | RUNTIME PASS | 雙玩家 say／tell／reply、UTF-8 與 reconnect 已通過 |
| Save | PERSISTENCE PASS | Local→Neon durable save 已驗證 |
| Quit | RUNTIME PASS | quit 流程已驗證 |
| Relogin | PERSISTENCE PASS | save→quit→relogin→restore 已驗證 |
| KING Admin | RUNTIME PASS | Owner→Wizard→Arch→remove、Help 過濾與 Player denial 已通過 |
| KING Weapons | RUNTIME PASS | 武器 inventory／wield mode／unwield／relogin fixture 已有 Runtime 證據 |
| KING Martial | COMBAT PASS | 既有 Combat／perform Runtime gate 保持有效 |
| Web Client | RUNTIME PASS | WebTelnet、WSS 與 iPhone Entry 已通過 |
| Persistence | PERSISTENCE PASS | Neon restore 與 Render new-container restore 已通過 |

## 狀態規則

- `SOURCE PASS`：直接 Source 與 dependency 已確認，但不代表已執行。
- `STATIC PASS`：精準靜態檢查通過，不代表 Driver Runtime。
- `RUNTIME PASS`：已由真正 Neolith Driver 執行通過。
- `PERSISTENCE PASS`：已通過 save／restore 或跨容器持久化驗證。
- `COMBAT PASS`：已在真 Combat 流程驗證。
- `PARTIAL`：只有部分 Source 或部分 Runtime 閉環。
- `SOURCE_REQUIRED`：缺少可安全實作的直接 Original／同版本 Source。
- `EVIDENCE_EXHAUSTED`：既定來源已合理搜尋完畢，無新來源不重搜。
- `N/A`：Original Source 已證明不是該系統要求，不列為待辦。
