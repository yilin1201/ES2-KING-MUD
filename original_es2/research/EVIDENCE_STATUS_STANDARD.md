# Original ES2 Evidence Status Standard（證據狀態標準）

> 第四階段 4D。目的：統一 Original ES2 Research 的證據狀態語意；**只治理標籤，不改寫來源事實、不提高未驗證內容可信度**。

## 正式狀態

- `CONFIRMED_SOURCE`（原始來源已確認）：Original Source Code、Original 文件，或可直接辨識的 Original 官方／歷史原始材料。
- `CONFIRMED_RUNTIME`（實機原始碼已確認）：已在乾淨 Original ES2 Runtime tree（執行程式樹）直接核對可執行 LPC 原始碼或行為。
- `ARCHIVED_SOURCE`（歷史封存來源）：Google Sites、歷史頁面、截圖或 Archive 可直接支持的內容。
- `ARCHIVED_GAMEPLAY`（歷史實機紀錄）：歷史遊戲畫面、影片、角色紀錄或實機選單。
- `PLAYER_RECORD`（玩家紀錄）：玩家攻略、文字紀錄或回憶；未經 Source/Runtime 交叉驗證前不得升級。
- `RECONSTRUCTION`（重建推論）：依證據重建的結構或識別碼；不得反向宣稱為 Original 事實。
- `UNKNOWN`（未知）：目前沒有足夠證據。
- `SOURCE_PENDING`（來源待考證）：已知有候選內容，但 Original 來源／版本尚未確認。
- `CONFLICT`（證據衝突）：可靠來源彼此不一致；並列保存至衝突解決。

## 舊標籤相容規則

- `[Confirmed Source]` → `CONFIRMED_SOURCE`。
- `CONFIRMED_TEXT` 不自動等於 Source；依實際來源改列 `ARCHIVED_SOURCE`、`PLAYER_RECORD` 或 `CONFIRMED_SOURCE`。
- `[Archived]` → 原則上 `ARCHIVED_SOURCE`；若是實機畫面／影片則 `ARCHIVED_GAMEPLAY`。
- `[Player Memory]` → `PLAYER_RECORD`。
- `[Unverified]` → `SOURCE_PENDING` 或 `UNKNOWN`，依是否已有候選線索判定。
- `[ES2-KING Reconstruction]` → `RECONSTRUCTION`，且必須與 Original Evidence 分離。

## 禁止升級

1. 導覽頁存在不等於正文已讀取。
2. 檔名、路徑名稱或 Reconstruction 不等於 Original 機制已確認。
3. Runtime 保存上游缺少內容，不等於歷史 Original 不存在該內容。
4. Player Record 不得單獨升級為 `CONFIRMED_SOURCE`。
5. 來源衝突不得選一邊覆寫另一邊；統一登錄至 `EVIDENCE_CONFLICT_REGISTER.md`。

## 4D 掃描結果

18 份 Original Research Evidence 的既有語意可映射到本標準。M16/M17/M18 使用的 `CONFIRMED_TEXT` 保留為歷史標籤，但後續新增內容不得再使用此模糊標籤；M19/M21/M22 的 `CONFIRMED_RUNTIME` 可直接保留。Google Sites 截圖型 Evidence 應視為 `ARCHIVED_SOURCE`，即使舊文件標題使用 `[Confirmed Source]`，也不代表它與 Original LPC Source Code 是同一證據層級。
