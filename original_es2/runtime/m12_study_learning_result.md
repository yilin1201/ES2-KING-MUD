# M12 Original ES2 研讀學習 Runtime 驗證結果

> 證據標籤：`[Confirmed Source]` + `[Runtime Verified]`

## 結論

GitHub Actions `Original ES2 M12 Study Runtime` Run #8（Run ID `35073378482`）已通過。

本次驗證不是直接由測試程式替玩家增加學習進度，而是建立真實玩家後，由 Telnet 送出 Original `study` 指令，走 Original `study_ob()` → `study_content()` → `improve_skill()` 學習路徑。

## 已驗證行為

- Original `study <物品>` 可啟動研讀。
- 研讀會消耗 `gin`（精）與 `sen`（神）。
- 成功研讀會透過 Original `improve_skill()` 增加技能學習進度。
- 玩家 `quit` 後重新登入，已取得的學習進度仍會保存。
- Runtime-only 測試物件與探針只建立於 `.runtime`，不修改保存用途的 Original ES2 原始碼。
- 測試夾具依 Original `USER_PROTECT` 規則使用 `MUDLIB_UID` 權限，避免繞過玩家資料保護機制。

## Original 公式邊界

研讀成本、悟性／慧根影響、古文造詣需求、疲勞限制與隨機學習判定均以 Original `mudlib/feature/study.c` 為準；ES2-KING 不自行改寫成另一套學習公式。

## 下一階段

M12 的「技能底層介面」與「玩家真實研讀路徑」均已有 Runtime 證據。後續可進入 M13 武學／內功重建，並把 M14 師徒學習與 `study` 研讀分成不同學習來源驗證。
