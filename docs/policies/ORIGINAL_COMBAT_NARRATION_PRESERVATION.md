# Original Combat Narration Preservation

## 首要原則

凡已有 Original Source、Archived Source 或可辨識 Historical Evidence 截圖／文字證據的戰鬥敘述，**原人物出招敘述完整性高於排版美化**。

不得為手機排版、單行顯示、WebTelnet UI、美化或縮短畫面而：
- 刪字
- 縮寫
- 摘要
- 改寫既有 Evidence 句子
- 省略人物、武功、極招、段名、攻擊效果或目標敘述

允許在不減少原文內容的前提下調整 ANSI 配色、換行位置與顯示相容性。

若排版需求與 Evidence 原文衝突，保留 Evidence 原文。

## Regression

Final Runtime 必須執行 `scripts/test_original_combat_narration_preservation.sh`。
目前已鎖定「傲劍訣・劍領風騷」完整人物出招主句、四色招名、忠／武／義／德／狂／情六段與劍氣／目標敘述。
後續每新增一組有 Evidence 的戰鬥敘述，應同步加入此 Gate，不得只依賴人工記憶。
