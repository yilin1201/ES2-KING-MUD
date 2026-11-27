# ES2M 地圖／NPC／武器裝備導入 Gate（2026-10-01）

> 範圍：ES2-KING branch `build/original-es2-races-phase2`；外部來源 `wolfer168/es2-webmud`（ES2M）。本文件是可執行導入規格，不代表資料已匯入或 Runtime PASS。

## 來源與信任邊界
- Original target 的同版本 LPC 仍是最高依據；ES2M 的 catalog 是 upstream LPC 索引，**不是**可直接執行的遊戲資料或原作證明。
- ES2M README 已記載 `tools/build_catalog.py`、`tools/audit_es2.py`、`tools/catalog_diff.py`，及 `manifest.json`／`all.json`／`audit.json` 輸出；這些輸出未取得前不得聲稱已完成逐項比對。
- ES2M 對無法安全資料化的 LPC 腳本標示 `manual_review`；此類一律不自動移植。
- 禁止將 ES2M Web UI、Windows 啟動腳本或未驗證版本差異覆蓋現有 Render／Neolith／WebSocket 鏈。

## 導入優先序與最小證據
| 順序 | 類別 | ES2M 索引候選 | Target 比對 | 准入 Gate |
|---|---|---|---|---|
| 1 | World/Map | room path、exit、room object、audit broken edges | 同版本 room LPC、出口目標與 include/inherit | 來源可追溯、引用閉合、targeted room compile、雙向移動 Runtime |
| 2 | NPC | race/class/level、skills、merchandise、equipment、add_action | 同版本 NPC LPC、clone path、互動指令 | 不引入新虛構 NPC；clone + interaction Runtime |
| 3 | Weapon/Equipment | object aliases、weight、equipment refs、merchant refs | 同版本 object LPC、equip slot、weapon skill mapping | inventory→wield/unwield→save/quit/relogin；無複製或權限逸出 |
| 4 | Skill | skill-daemon registry、study required/content | target daemon、既有凍結 Canon | 只登錄差異；未授權不得改動冷梅／KING 已凍結技能 |

## 本輪確認的既有缺口與阻擋條件
1. Snowkeep：現有 girl→invitation→guard 前置鏈有 Target Source；`/d/snowkeep/entrance.c` 缺失。ES2M 若僅索引另一 lineage，不得拼接為 Original；取得同版本 room 與完整引用後再測。
2. `wine_pot`→`red_wine`：caller 已確認；`/d/choyin/npc/obj/red_wine.c` 缺失。不可生成替代物。
3. Taoist／Bonze／Soldier 玩家職業：NPC 或文件線索不等於玩家職業 daemon；本輪不得藉 ES2M catalog 宣稱玩家轉職 PASS。
4. 既有完整玩家 Journey 與已驗證地圖／NPC／裝備保持不變，僅對有直接新增證據的缺口執行 targeted tests。

## 下次資料落地的逐項紀錄格式
每個候選物件一列：`category | es2m_source_path | es2m_source_commit | target_path | target_source_commit | evidence_class | compatibility | missing_refs | manual_review | decision | targeted_test | runtime_marker`。

決策只允許 `IMPORT`（同版本相容且引用閉合）、`REFERENCE_ONLY`（外部版本僅作對照）、`BLOCKED`（缺檔／衝突）與 `ALREADY_PRESENT`（避免重做）。未取得原始 LPC 或 catalog 實檔時，先標 `BLOCKED`，不猜測缺失欄位。

## 執行驗收
1. 固定 ES2M 與 Target commit；先取得 ES2M 實際 generated catalog／audit 或原始 LPC。
2. 依地圖→NPC→武器裝備順序，比對 target tree；先做引用與相容性檢查，再進行最小 LPC 修改。
3. 只跑新增內容的 targeted static／真 Driver E2E；Static PASS ≠ Runtime PASS。
4. 任何 FAIL 先修復；不為觸發 CI 建立 no-op commit，不重跑已知 Actions infrastructure failure。
5. PR #13 保持 OPEN／NOT MERGED；禁止 force push。
