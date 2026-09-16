# M10／M12 下一階段執行清單

## M10 種族

- 執行新建的 Original 種族證據／基線 Actions。
- PASS 後才把靜態基線標記為驗證完成。
- 研究 Original 創角上限、亂數與先天不足規則，之後才修改實際出生演算法。
- 種族特殊能力先逐項尋找 Original Source，不用網站描述反推公式。

## M12 研讀

- 執行 `study` 靜態證據 Actions。
- 讀取 Original `improve_skill()` 精確演算法。
- 建立 Runtime-only 研讀物件與測試玩家前置條件。
- 真實執行 `study`，確認技能進度增加。
- quit → relogin 後再次確認資料，完成 Persistence（持久化）驗證。

## 合併限制

PR #13 保持 OPEN；沒有使用者明確的 Merge（合併）授權，不執行 Merge。
