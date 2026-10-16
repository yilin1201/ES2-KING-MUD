# M10 Original ES2 種族 Runtime 重建計畫

> 狀態：`[ES2-KING Reconstruction]`
> 證據基線：`original_race_google_sites_evidence.md`

## 目的

將目前 M6～M9 為了驗證登入、戰鬥與存檔而使用的暫定 25／50 屬性，逐步改為有 Original ES2 Google Sites 證據支持的種族資料；Original 保存層維持原文，不為重建而改寫。

## 實作分層

1. **Evidence／證據層**：保存網站正文可確認的業力、適合職業、精氣神、八屬性上限、被動與主動能力。
2. **Reconstruction／重建層**：把已確認欄位轉成可執行 Runtime 資料結構。
3. **Behavior／行為層**：主動／被動能力只有在找到 Original 行為公式或足夠證據後才實作，不用名稱自行猜公式。
4. **Regression／回歸層**：Human、Avatar 與既有登入、戰鬥、Persistence（持久化）測試不得退化。

## 第一批可安全導入的資料

目前可先導入「靜態出生基線」：種族業力、初始精／氣／神、八項初始屬性上限。這些資料均來自已確認網站正文。

主動／被動能力暫時只建立識別與證據對照，不把「攻擊能力50」「防禦力100」等名稱直接猜成 Driver 內部公式。

## 創角注意事項

Google Sites 使用的是「初始屬性上限」用語，因此不能直接宣稱角色每次出生固定等於該數值。正式取代創角演算法前，仍需核對 Original 創角亂數、先天不足與種族上限之間的關係。

## 完成條件

- 11 種族皆有可追溯證據資料。
- Runtime 能讀取種族靜態基線。
- 不破壞 Human／Avatar Original 保護。
- 既有 M4、M5、M6～M9、M11、M12 回歸保持 PASS。
- 所有 ES2-KING 新增英文技術名稱與重要邏輯均有繁體中文註解。
