# ES2M → ES2-KING 相容性優先整合規則

## 最高原則
- ES2M 是 ES2-KING 功能與行為更新的主要參考來源。
- ES2-KDS 只作為輔助比較資料，不可直接取代 ES2M 行為或成為整合基準。
- ES2-KING Expansion 可保留自訂規則，但必須明確標示與 ES2M 的差異。
- Original ES2 上游保存來源不得為了套用 Expansion 而直接改寫。

## 每次更新的固定流程
1. 讀取 ES2M snapshot／已確認的最新 ES2M 來源。
2. 與 KING Runtime、Original ES2 source 及既有 Expansion 做差異比較。
3. 依相容性分類：
   - COMPATIBLE：介面、呼叫契約、資料結構與行為相容，可直接整合。
   - ADAPTER_REQUIRED：可保留 ES2M 行為，但需用 Expansion adapter／overlay 接線。
   - CONFLICT：與 KING 已確認自訂規則衝突，先記錄，不直接覆蓋。
   - UNKNOWN：證據不足，不宣告完成。
4. 優先採用 ES2M 行為；只對已確認的介面差異做最小 adapter，不重寫整套系統。
5. 測試原始功能、更新功能與相鄰依賴；測試失敗不得部署。
6. 分開回報來源已封存、程式已寫入、測試通過、Docker 建置成功、Oracle 遊戲內驗證及正式部署。

## 戰鬥／武學更新的額外檢查
- `std/martial_art.c`、`std/martial_art.h`、`adm/daemons/combatd.c`、`feature/char/skill.c` 與招式檔視為相互關聯的變更組。
- 不單獨替換其中一個檔案，除非已確認呼叫介面、action mapping、傷害／防禦契約及學習／升級回呼相容。
- 三門刀法等武學資料以 ES2M 版本為主；KING 自訂招式只能在確認不改變 ES2M 原有行為後保留。
- ES2-KDS 只提供額外的改善候選項，須先與 ES2M 和 KING 三方比對。

## 保護規則
- 不停止或刪除現有 Oracle 容器來做 build-only 驗證。
- PR #13 維持 OPEN／NOT MERGED，除非使用者明確授權。
