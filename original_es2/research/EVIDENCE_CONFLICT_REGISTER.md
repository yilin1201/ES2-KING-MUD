# Original ES2 Evidence Conflict Register（證據衝突登錄表）

> 第四階段 4B。規則：衝突不覆寫、不融合；先記錄「來源 A／來源 B／影響」，只有需要專案 Canon 決策時才交由 Owner 決定。

## C-001 headless 中文名稱：刑天 vs 形天

- Google Sites／專案正式種族表：`刑天`。
- Original `chinese.o` 與 Archived Gameplay Record（歷史實機紀錄）：`形天`。
- 判定：**VERSION/CANON CONFLICT**。Original Evidence 必須保留「形天」原文；ES2-KING 專案主名稱是否維持「刑天」屬 Canon 決策，兩者不得互相覆寫。
- 狀態：OPEN / OWNER-CANON 已有既定規則時可引用，不修改 Original Evidence。

## C-002 blackteeth 業力：3 vs 5

- Google Sites 種族頁證據：黑齒業力 `3`。
- 2014 Archived Gameplay race-selection：黑齒業力 `5`。
- 判定：**HISTORICAL CONFLICT**。可能為版本差異；目前無足夠證據判定哪一值適用所有 Original 時期。
- 狀態：OPEN；兩值並存，不改寫 historical registry。

## C-003 yaksa 業力：35 vs 30

- Google Sites 種族頁證據：夜叉業力 `35`。
- 2014 Archived Gameplay race-selection：夜叉業力 `30`。
- 判定：**HISTORICAL CONFLICT**。可能為版本差異；不得自行選一值覆蓋另一值。
- 狀態：OPEN。

## C-004 八屬性代碼 cor/cps 中文對應 — RESOLVED

- 專案 Owner 確認 Original 正確對應：`cor=膽識`、`cps=定力`。
- `es2_google_sites_index.md` 原校正敘述正確。
- `historical_race_registry.json` 舊值寫反，已於第四階段 4C 校正為 `cor=膽識`、`cps=定力`。
- 判定：**RESOLVED / OWNER-CONFIRMED**。後續 Race、Score、Runtime 欄位統一採此映射。

## C-005 人類族 Original ID

- Google Sites 證據支持「人類族」設定內容。
- `human_clan` 明確只是 ES2-KING Reconstruction ID（重建識別碼），Original ID 待考證。
- 判定：**SOURCE-PENDING，不是衝突**。
- 狀態：維持 UNKNOWN；禁止把 `human_clan` 升級為 Original ID。

## 4B 原則

以上衝突全部保留原始證據，不修改來源正文。C-001～C-003 可安全以「版本／歷史衝突」形式並存；C-004 已由 Owner 確認並完成欄位校正；C-001～C-003 仍以版本／歷史衝突並存，C-005 維持 SOURCE-PENDING。
