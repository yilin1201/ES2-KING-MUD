# ES2M → KING 差異批次：李家村入口相容性閘門（2026-10-02）

> 此文件是實際來源比對結果，不是 Runtime PASS，也不是授權直接啟用新地圖。
> KING HEAD：`58f581593b64c7650ac25fd9ca0f00a55d7e2923`
> ES2M tree：`10aa4561ab47813becbcb6a48f2a2a188e128d5d`
> ES2M Source：`source/upstream/mudlib/`

## 全量檔案路徑比對

透過兩端 Git Trees API 的 recursive=1 且 truncated=false 結果，按 `source/upstream/mudlib/` 對應 `es2m_snapshot/mudlib/` 比對 Git blob SHA：

- ES2M upstream：1304 個檔案。
- KING 既有 snapshot：594 個檔案。
- 上述相對路徑中，ES2M 尚未在 KING snapshot 保存：710 個。
- 相對路徑相同但 Git blob SHA 不同：3 個（`d/lee/LEE_TOPOLOGY.json`、`daemon/race/yenhold/breathe.c`、`daemon/skill/taoism-spells.c`）。
- 注意：不同 Git blob SHA 只表示位元內容不同，不直接等於功能衝突；上述 710 個不等於 710 個應移植檔案，包含核心 daemon、原始地圖與 README。此數據是此版本兩份樹的 snapshot 差異，不是 Runtime 差異。

## P1：李家村地圖／NPC 來源審核

ES2M `d/lee/` 的李家村入口程式明確標示 `RECONSTRUCTED`，並稱拓樸來自使用者提供的地圖；不能升級為 Original ES2 歷史 Canon。

| 來源 | 直接證據 | 依賴 | 決策 |
|---|---|---|---|
| `d/lee/entrance_s.c` | north→gate_s；southwest→/d/snow/egate；spawn traveller×3 | gate_s、traveller、Snow egate | REFERENCE_ONLY；尚未核對 Snow 反向出口 |
| `d/lee/gate_s.c` | north→street2；south→entrance_s；spawn guard×2 | street2、guard | REFERENCE_ONLY；不得只移植入口造成斷圖 |
| `d/lee/square_c.c` | west→square_s；north→square_e；south→street1；spawn child×3、well×1 | 三房間、child、well | REFERENCE_ONLY；需要完整區域閉合 |
| `d/lee/npc/guard.c` | fighter 等級15，裝備 brow_staff、hemp_cloth、hemp_boots；accept_fight 覆寫 | F_VILLAGER、staff/parry/dodge、三件裝備 | REFERENCE_ONLY；需驗證 NPC 與裝備繼承相容 |

## 安全導入閘門

1. 先對 `d/lee/` 全區域逐一確認房間、NPC、裝備及跨區引用；完整閉合前不開放玩家入口。
2. `/d/snow/egate` 是跨來源邊界：ES2M reconstructed 入口不得自動改寫 KING 已確認 Original Snow 出口；需記錄並決定是否以 KING Expansion 形式接入。
3. 相同路徑的三個 SHA 差異先比對實際文字及既有 KING 功能；不得自動覆蓋。
4. 檢查既有 `scripts/apply_race_phase2_runtime.sh` 的 overlay 範圍，避免 reference-only 區域意外進入正式 Runtime。
5. Static gate：來源檔 SHA、出口目標、clone/include/inherit、NPC 裝備與技能引用。Runtime gate：隔離普通玩家雙向移動、NPC 互動／戰鬥、save→quit→relogin；KING 回歸另測。

## 本批狀態

已完成：固定雙方版本、全量路徑／blob SHA 比對、李家村入口四檔的原文審核與相容性風險記錄。

未完成：710 個候選的逐檔語意差異、李家村全區域依賴閉合、正式 Runtime 導入、真 Driver 測試。以上未驗證部分不得標記 PASS。
