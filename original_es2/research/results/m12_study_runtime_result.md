# M12 `study` 研讀學習驗證結果

> 狀態：**Static + Runtime + Persistence 全部 PASS**。最新完整回歸為 GitHub Actions `Original ES2 M12 Study Runtime` Run #19（Run ID `35081627565`）成功；同一版程式的 `Original ES2 M12 Study Static` Run #21（Run ID `35081627435`）亦成功。

## 已驗證

- Original `study <物品>` 玩家介面證據。
- `study_ob()` 研讀物件介面證據。
- `improve_skill()` 學習進度核心證據。
- `literate`、`archaic attainment`、精／神、慧根、悟性與疲勞等已確認條件。
- Runtime-only（僅執行期）研讀物件測試夾具，不修改保存用途的 Original ES2 原始碼。
- 真實玩家登入後執行 `study sheet`，由 Original `study` 流程進入 `improve_skill()`。
- 成功研讀後 `learned` 學習進度增加。
- quit → relogin（離線→重新登入）後，`learned` 仍保持，完成 Persistence（持久化）閉環。
- 研讀造成的 busy（忙碌狀態）與精／神資源限制已納入 Runtime 測試流程，避免測試腳本本身造成假 FAIL。

## 結論

M12 `study` 已不再只是靜態原始碼考證；目前已完成「Original 指令 → 真實 Runtime → 技能學習進度 → 離線保存 → 重新登入驗證」的可執行閉環，可作為後續 M13 內功／武學學習與 M14 師徒系統的基礎。

> 證據邊界：目前只宣稱已驗證 Original `study` 與 `improve_skill()` 的既有機制及持久化流程；不同技能如何把 `learned` 轉成技能等級，仍由各 Skill Daemon（技能常駐程式）自己的 `skill_improved()` 邏輯決定，不建立未經證據支持的通用升級門檻。
