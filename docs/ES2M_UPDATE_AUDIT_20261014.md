# ES2M 上游更新盤點與 KING 相容性稽核（2026-10-14）

## 1. 稽核基準

- 上游 Repository：`wolfer168/es2-webmud`
- 上游舊基準：`ee12e717e2d3d88728607a01c2c2f1d634bf9616`
- 上游最新基準：`f21f59cecb55e5c3e31d2e97a7ef6d43783ecdcb`
- GitHub compare 結果：**11 commits ahead、0 behind**；此範圍包含新增 NPC 技能系統、技能 ID 改名／存檔遷移、NPC／技能共用檔、NPC／房間 compendium 與相關測試。
- KING Repository：`yilin1201/ES2-KING-MUD`
- KING 目標分支：`build/original-es2-races-phase2`
- 本次查核時 KING 分支 HEAD：`a2fa8dbb12c587a5697cd2d3fbaf3406a8f426f7`
- 本文件是**差異與相容性證據紀錄**，不是「已整合」或「Runtime PASS」聲明。
- PR #13 經 GitHub 查核為 **OPEN / NOT MERGED**；維持原狀。未部署 Oracle，未改動正式容器。

## 2. 主要發現

### A. NPC 基本技能系統：ADAPTER_REQUIRED / 尚未整合

上游新增：
- `source/upstream/mudlib/daemon/misc/npc_skill.c`
- `source/upstream/mudlib/tests/test_npc_skill.py`
- `source/upstream/mudlib/docs/CUSTOM_NPC_SKILL.md`（文件實際位於上游 repo 的 `docs/CUSTOM_NPC_SKILL.md`）
- `include/daemon.h` 增加 `NPC_SKILL_D`
- `adm/etc/preload` 預載 `/daemon/misc/npc_skill`
- `std/char/npc.c` 增加手動技能／映射記錄、依職業／門派／等級套用技能，以及武器裝備後補技能的 hooks。

已核對上游 NPC 技能規則：主修 ×3、通用 ×2、輔助 ×1.5，技能上限 200；依職業與 `custom_faction` 門派表補基本技能，保留 NPC 在 `create()` 中手動設定的技能與映射；武器技能需在裝備後補上。此為 ES2M 自訂擴充，不標記為 Original ES2 原作機制。

KING 現況：
- `es2_king_expansion/runtime/mudlib/std/char/npc.c` 已有 KING／ES2M NPC 強度 `NPC_POWER_D`、手動屬性／精氣神保護及 `setup()` 流程。
- `es2_king_expansion/runtime/mudlib/include/daemon.h` 目前有 `NPC_POWER_D`，尚無 `NPC_SKILL_D`。
- KING Runtime 的 NPC 與上游同名檔不是可直接覆蓋的乾淨副本；整檔替換會有覆蓋現有 NPC_POWER 與 setup 行為的風險。

**處置：ADAPTER_REQUIRED。** 必須以最小增量方式合併 hooks，確認呼叫順序不破壞 NPC_POWER、手動數值、原有 NPC 技能、種族初始化及武器裝備時序；完成 LPC compile／Driver runtime 與 NPC regression 前，不匯入 Runtime。

### B. 技能 ID 更名與舊存檔遷移：ADAPTER_REQUIRED / 高優先待辦

上游有兩組技能檔案改名：
- `sanmeendo` → `ksanmando`（三門刀法）
- `tiger-force` → `tiger_force`（瘋虎功 daemon 檔名；技能註冊 ID 為 `tiger force`）

上游 `feature/char/skill.c` 增加舊 ID 對照與 `migrate_skill_ids()`；`feature/save.c` 的 `restore()` 在還原成功後，若物件具有該函式便呼叫它。上游同時有道士法術熟練度刷新等其他新增行為，不能將整個 `skill.c` 直接覆蓋 KING。

KING Runtime 的 `feature/char/skill.c` 有專屬 **KING Owner skill cap 300** 保護（唯一 admin KING 才可到 300，其他玩家維持 200）；這段必須保留。KING Snapshot 的 `feature/save.c` 尚未包含上游的技能 ID 遷移 hook。若直接更名技能檔而不遷移舊玩家存檔，可能造成舊技能等級／映射資料留在舊 ID。

**處置：ADAPTER_REQUIRED。** 下一批應先完整檢查舊／新技能 ID 的全庫引用、skill daemon 註冊名、技能映射、玩家 save/restore 及 KING 300 cap，再做保留 KING 專屬邏輯的最小合併與回歸測試。未完成前不批次重命名或刪除舊檔。

### C. NPC 與武學檔的 add_skill 調整：需逐檔審查

本次 11 commits 也變更多個 NPC、武器、道士 NPC、武學檔案及技能測試。部分變更是移除／調整 `add_skill()`，其意圖與 NPC 自動技能系統相關。這些變更只有在 NPC_SKILL_D 的規則與 hooks 同時正確生效時才可能安全；不可把單一 NPC 的刪行當成獨立清理套用到 KING。

**處置：CONFLICT_RISK / 逐檔待審。** 暫不批次複製或刪除。

### D. NPC／房間 Compendium 與文件：可作參考資料，非 Runtime 整合

上游新增：
- `catalog/legacy_room_npc_compendium.json`
- `catalog/room_npc_compendium.json`
- `docs/LEGACY_ROOM_NPC_COMPENDIUM.md`
- `docs/ROOM_NPC_COMPENDIUM.md`
- 對應建置工具與門派武功對照表。

這些內容主要是索引／研究資料，不等於所有 NPC 或房間程式碼已移植。可以作為後續資料比對來源，但必須標示來源、路徑與原版／變體可信度，不能直接匯入 Runtime。

**處置：COMPATIBLE_AS_REFERENCE。** 先建立清單與差異追蹤，再按需求挑選內容；不整包搬入正式遊戲路徑。

### E. `preload`、`include/daemon.h` 與共用技能檔

這些共用檔與新增 daemon 互相依賴。KING 的 `daemon.h` 目前已有 `NPC_POWER_D`，應保留既有定義後才可增加 `NPC_SKILL_D`；preload 必須確認使用的 daemon 路徑在最終 Runtime 存在且能載入。上游的技能 ID 遷移也依賴 `feature/save.c` 與 `feature/char/skill.c` 同步修改。

**處置：DEPENDENCY_GATED。** 不單獨先改 preload 或 header，避免啟動時找不到 daemon。

## 3. 相容性矩陣

| 項目 | 分類 | 理由 | 下一個安全動作 |
|---|---|---|---|
| `daemon/misc/npc_skill.c` | ADAPTER_REQUIRED | 新系統依賴 NPC hooks、職業／門派表與 preload | 審核 class／faction 覆蓋，再做隔離合併 |
| `std/char/npc.c` | CONFLICT_RISK | KING 已有 NPC_POWER 與自訂 setup 流程 | 只做增量 patch，不覆蓋整檔 |
| `include/daemon.h` | DEPENDENCY_GATED | 需保留 NPC_POWER_D 並新增 NPC_SKILL_D | 與 daemon／preload 同批提交 |
| `adm/etc/preload` | DEPENDENCY_GATED | preload 指向不存在的 daemon 會影響啟動 | 等 daemon 檔與 runtime path 確認後再改 |
| `feature/char/skill.c` | CONFLICT_RISK | KING 具有 Owner 專屬 skill cap 300 | 保留 KING 區塊，按函式最小合併 |
| `feature/save.c` | ADAPTER_REQUIRED | restore hook 可遷移舊技能 ID，但需搭配 skill.c | 先確認存檔欄位與遷移測試 |
| `ksanmando.c` / `tiger_force.c` 改名 | ADAPTER_REQUIRED | 舊路徑與 ID 可能仍被引用／存檔使用 | 全庫引用掃描＋舊存檔遷移後再改 |
| NPC／武器／武學 `add_skill()` 調整 | CONFLICT_RISK | 與 NPC_SKILL_D 自動補技能互相依賴 | 按檔案逐一確認，不批次刪行 |
| Room/NPC Compendium | COMPATIBLE_AS_REFERENCE | 索引資料，非執行程式 | 作為後續比對清單，保留來源標籤 |
| 相關上游測試 | COMPATIBLE_AS_REFERENCE | 測試多以靜態字串／表格檢查為主 | 移植前改成涵蓋 KING overlay 與 Runtime 的測試 |

## 4. 驗證狀態

- 上游 GitHub compare：**PASS（來源差異已確認）**。
- KING 同名／對應檔查核：**PASS（確認存在差異與相依關係）**。
- LPC 編譯、Driver Boot、NPC 技能實際套用、技能更名後舊存檔還原、KING Owner 300 cap regression：**NOT RUN / NOT VERIFIED**。
- Docker／Oracle／Render：本次未執行；正式容器未變更。
- GitHub Actions：不得因未取得 workflow run 而宣稱 PASS。
- PR #13：**OPEN / NOT MERGED**。

## 5. 後續執行順序

1. 先針對 `sanmeendo`／`ksanmando` 與 `tiger-force`／`tiger force` 做全庫引用盤點，確定技能 ID、檔案路徑與 save/restore 欄位的實際對應。
2. 先建立技能遷移測試案例，涵蓋舊存檔含舊 ID、遷移後無重複／遺失、映射仍有效、一般玩家上限 200、唯一 KING Owner 上限 300。
3. 再以小 patch 合併 `feature/char/skill.c` 與 `feature/save.c`，不得覆蓋 KING 專屬區塊。
4. NPC 基本技能系統另開一批，先完成 class/faction 及 NPC setup 依賴矩陣，再合併 daemon、header、preload、NPC hooks，最後移植相關 NPC 調整。
5. 每批完成靜態測試後，必須執行實際 Neolith／Driver runtime regression；未執行者標記 NOT VERIFIED。
6. 保持 PR #13 OPEN / NOT MERGED；未經使用者明確授權不得 Merge 或 Deploy。


## 6. 追加全庫路徑掃描（2026-10-14）

已對 KING 目標分支的完整 Git tree（2,496 個路徑，包含本次稽核文件）掃描技能檔名：

- 舊檔名 `sanmeendo.c`、`tiger-force.c` 仍存在於 `es2m_snapshot/mudlib/daemon/skill/`，也存在於歷史匯入資料夾 `source/es2m_updates/...`。
- KING 分支目前未找到 `ksanmando.c` 或 `tiger_force.c` 這兩個新檔名的路徑。
- KING Runtime 的 `feature/char/skill.c` 仍將 `sanmeendo` 列入舊技能成長判斷；尚未找到對應的 `migrate_skill_ids()`。
- KING Snapshot 的 `feature/save.c` 仍在 restore 成功後直接回傳，未呼叫技能 ID 遷移函式。

這代表上游更名尚未以完整相容批次整合。此掃描是路徑與已讀取檔案內容的靜態證據，並不代表所有 LPC 動態字串引用均已完整掃描；後續仍需對技能 ID、技能映射與存檔資料做程式級搜尋及 Runtime 測試。
