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

## C-004 八屬性代碼 cor/cps 中文對應

- `historical_race_registry.json` 目前寫：`cps=膽識`、`cor=定力`。
- `es2_google_sites_index.md` 目前校正敘述寫：`cor=膽識`、`cps=定力`。
- 判定：**INTERNAL EVIDENCE CONFLICT**，屬高風險欄位映射；會影響 Race/Score/Runtime 解讀。
- 狀態：**DECISION/VERIFICATION REQUIRED**。在取得 Original 顯示或 Source 的直接欄位證據前，不自動改任一方。

## C-005 人類族 Original ID

- Google Sites 證據支持「人類族」設定內容。
- `human_clan` 明確只是 ES2-KING Reconstruction ID（重建識別碼），Original ID 待考證。
- 判定：**SOURCE-PENDING，不是衝突**。
- 狀態：維持 UNKNOWN；禁止把 `human_clan` 升級為 Original ID。

## 4B 原則

以上衝突全部保留原始證據，不修改來源正文。C-001～C-003 可安全以「版本／歷史衝突」形式並存；C-004 涉及核心欄位映射，需優先考證或 Owner 提供已確認實機證據後才能校正。
