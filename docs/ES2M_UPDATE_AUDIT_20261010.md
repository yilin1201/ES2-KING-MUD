# ES2M 上游更新盤點與 KING 採用紀錄（2026-10-10）

## 基準與保護規則

- ES2M 來源：`wolfer168/es2-webmud`
- 本次來源 HEAD：`60c12efac447d63730f953ac83ef47fdc62f7368`
- 上次記錄來源基準：`5f042999e0d884ab35808a1c48a9e70bea46667f`
- GitHub compare：來源基準至目前 HEAD 共前進 92 個 commits，差異共 170 個檔案，其中 140 個 mudlib 檔案。完整逐檔清單見 [ES2M 更新檔案差異清單](ES2M_UPDATE_FILE_MANIFEST_20261010.md)。
- KING 目標分支：`build/original-es2-races-phase2`
- 本文件是來源證據與採用狀態紀錄，不代表所有項目已進入 Runtime。
- 不整包覆蓋、不修改 Original 保存來源；先隔離到 Expansion，再做靜態／Runtime 驗證。
- PR #13 必須維持 OPEN / NOT MERGED；不得 Force Push、Merge 或 Deploy。

## 本次確認的上游更新範圍

### A. 冷梅莊武學系統（待分批整合與驗證）

來源檔案／資料：
- `source/upstream/mudlib/std/martial_art.c`（新增學成點數門檻與「學成當級是否給獎勵」設定）
- `source/upstream/mudlib/std/martial_art.h`
- `source/upstream/mudlib/daemon/skill/lunmay.c`（冷梅劍法）
- `source/upstream/mudlib/daemon/skill/hainmay_force.c`（寒梅心法）
- `source/upstream/mudlib/daemon/skill/advance_lunmay.c`（傲梅暗劍訣）
- `source/upstream/mudlib/daemon/skill/mayin.c`（梅影身法）
- `source/upstream/mudlib/daemon/skill/seven.c`（七巧如意手）
- `source/upstream/mudlib/d/wutang/npc/may_yin_fong.c`（冷梅莊莊主梅影風）

來源確認重點：
- 新版武功共用引擎支援學成點數門檻與學成當級獎勵。
- 冷梅莊武學包含右手劍、內功、左手劍、閃躲身法、空手五項技能。
- 梅影風是五堂鎮 NPC，提供冷梅莊拜師與技能傳授；依來源定義種族／職業／等級／武器／技能／移動範圍。
- 上述來源尚須核對 KING 的武器、副手、戰鬥鉤子、門派資料及 NPC 裝備依賴，不可僅複製技能檔就宣稱可遊玩。

### B. NPC 強度系統（待依 KING NPC 架構隔離整合）

- `source/upstream/mudlib/daemon/misc/npc_power.c`
- `source/upstream/mudlib/std/char/npc.c`
- `source/upstream/mudlib/docs/CUSTOM_NPC_POWER.md`（上游文件實際位置為 `docs/CUSTOM_NPC_POWER.md`）

來源設計以 NPC 種族、職業、等級及 C/B/A/S 強度計算屬性與精氣神。需先確認 KING 的 NPC create/setup 流程、屬性上限及現有 NPC 數值，不能直接套用到所有原始 NPC。

### C. 技能使用／學習狀態與成長修正（需做差異合併）

- `source/upstream/mudlib/cmds/usr/disable.c`
- `source/upstream/mudlib/cmds/usr/abandon.c`
- `source/upstream/mudlib/cmds/usr/enable.c`
- `source/upstream/mudlib/feature/char/skill.c`
- `source/upstream/mudlib/feature/char/combat.c`
- `source/upstream/mudlib/adm/daemons/combatd.c`
- `source/upstream/mudlib/feature/equip.c`

來源變更涵蓋停用基本技能與特殊武功、恢復學習狀態、技能進度門檻、武術造詣／武學之道獎勵、戰鬥鉤子及裝備相容性。KING 的 `feature/char/skill.c` 已包含專案專屬的屬性成長、武器技能進度與 KING 上限邏輯；禁止整檔覆蓋，必須逐函式合併並保留 KING 規則。

### D. 區域、NPC 與訓練假人

來源差異涉及 `d/lee`、`d/oldpine`、`d/snow`、`d/wutang`，包含 NPC 對話／外觀／裝備、私塾、五堂鎮交叉路口與新 NPC；另有訓練假人規則更新。需要逐檔判定是內容補齊、描述修正、遊戲規則改動或依賴新系統，不得批次覆蓋同名 KING 原始檔。

### E. 其他武功與內容

來源差異亦涉及：
- 虎刀門：瘋虎刀法、瘋虎功、狻猊步法及相關技能獎勵／技能總覽。
- 三門刀法、七巧如意手、梅影身法與武功設計文件。
- `docs/CUSTOM_NPC_POWER.md`、`docs/NPC_POWER_LIST.md`、`docs/NPC_MAY_YIN_FONG.md` 及測試。
- WebMUD 前端與 Session Recorder 更新不屬於 KING LPC Runtime，除非另有指定，不直接導入遊戲原始碼。

## 採用狀態

| 項目 | 狀態 | 決策 |
|---|---|---|
| 上游 HEAD／差異清單 | SOURCE CONFIRMED | 已記錄來源 SHA 與 92 commits 差異範圍 |
| 冷梅莊武學與梅影風 | SOURCE PRESERVED / EXPANSION OVERLAY ADDED / LPC LOAD PASS | 已保存五項技能來源；Runtime 新增 mayin／seven，三項凍結武功採用 KDS/KING 基準；梅影風 NPC 與交叉路口已整合，修正 race 拼字 rainner→rainnar。Neolith Driver 建置與 LPC 載入 PASS；拜師／學武／戰鬥 E2E 仍待測 |
| NPC 強度系統 | SOURCE PRESERVED / EXPANSION OVERLAY ADDED / RUNTIME NOT YET VERIFIED | 已隔離加入 npc_power daemon、NPC 基底 set_power/set_beast 介面與 daemon.h 定義；Neolith 載入 PASS，強度數值平衡仍待 E2E 驗證 |
| disable／abandon／enable | SOURCE PRESERVED / EXPANSION OVERLAY ADDED / NEOLITH E2E PASS | 已整合 ES2M 停用映射、恢復技能使用與中止／恢復學習狀態；真實 Neolith E2E PASS |
| 區域 NPC／訓練假人 | SOURCE CONFIRMED / FILE-BY-FILE REVIEW | 不覆蓋同名 Original；只對明確缺漏建立 Expansion patch |
| WebMUD UI | OUT OF KING RUNTIME SCOPE | 不導入 LPC Runtime |

## 驗證限制

來源差異確認不等於完整 Gameplay PASS。2026-10-10 的 M30 workflow 已完成 Neolith Driver Build、Expansion Runtime Gate、冷梅莊技能／NPC 強度 LPC Load，及管理員技能指令 E2E；但梅影風實際拜師、五項武學升級／出招、NPC 強度數值平衡與區域 NPC 全面驗收仍未完成，不得擴大宣稱為完整遊戲玩法 PASS。

## 2026-10-10 已執行的 KING 變更

- 已更新 `es2m_snapshot/mudlib` 的五項冷梅莊技能、新版 `std/martial_art.c/.h`、NPC 強度 daemon、NPC 基底、daemon.h 與五堂鎮梅影風來源快照；來源內容保留獨立快照。
- 已新增 Expansion overlay：新版 `std/martial_art.c/.h`、新增技能 `mayin`／`seven`、`npc_power.c`、`std/char/npc.c`、`include/daemon.h`、`d/wutang/npc/may_yin_fong.c`、`d/wutang/crossroad.c`。冷梅劍法、寒梅心法、傲梅暗劍訣三項既有凍結武功只採用 KDS/KING 基準版本補足 pinned Original 缺檔，不採用 ES2M 最新改版覆蓋。
- KING `feature/char/skill.c` 保留既有 300 級 KING 上限、屬性成長與武器技能門檻；只對新增技能 `mayin`／`seven` 啟用自訂入門等級與點數門檻；其他既有武功沿用 KING 原本門檻。
- 梅影風傳授邏輯已修正為依技能實際入門等級補足學成點數；來源原本以固定 1 級門檻傳授，與部分技能 10／20／25 級入門設定不一致。
- 已把五項新技能加入 `scripts/test_es2m_skill_import.py`；完整技能清單現為 42 項。新增 `scripts/test_es2m_cold_plum_overlay.py`，並納入 Docker 與 GitHub Actions 靜態閘門。
- 新增 `scripts/test_es2m_cold_plum_lpc_load.sh`，由 M30 workflow 使用真實 Neolith 預載新版武功、NPC 強度 daemon、五堂鎮交叉路口及梅影風。
- 已新增 `disable.c`、`enable.c)、`abandon.c) 的 ES2M 來源快照與 Expansion overlay，並新增 `scripts/test_es2m_skill_commands.py`；管理員 E2E 增加三個命令的真實玩家流程檢查。
- 最新程式碼對應 M30 Actions：`38024536011`（ES2-KING M30 Alpha）完成 PASS；`38024536045`（ES2M Update Snapshot Gate）完成 PASS。這次驗證包含真實 Neolith Driver Build、13 個本輪 overlay 檔案一致性、冷梅莊／NPC 強度 LPC 載入與 admin 測試中的 disable／enable／abandon 流程。
- 上述結果屬於 Driver Build／LPC Load／指定指令 E2E，不等於梅影風完整拜師、所有新技能實戰或 NPC 強度平衡通過；這些項目仍保持待驗證。
- PR #13 仍為 OPEN / NOT MERGED；Original ES2 保存來源未直接覆寫。
