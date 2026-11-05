# M12 Original `study` 研讀學習 Runtime 計畫

> 狀態：`[Confirmed Source]` 架構 + `[ES2-KING Reconstruction]` 測試設計。

## 已確認 Original 流程

- 玩家指令：`study <物品>`。
- 物品必須提供 `study_ob()`。
- `feature/study.c` 可設定 `required/attribute`、`required/skill`、`content`、`study_msg`。
- 戰鬥中或 busy（忙碌）狀態不能研讀。
- `literate` 是主要研讀基礎；`archaic attainment` 可作為條件並增加消耗。
- 研讀會消耗精與神；慧根 `wis` 影響消耗，悟性 `int` 影響學習點。
- 疲勞上限會阻止研讀。
- 成功研讀透過 `improve_skill()` 推進技能學習。

## 下一個 Runtime Probe／執行期探針

建立只存在於測試 Runtime 的研讀物件，不修改 Original 保存原始碼。測試流程：

1. 建立測試玩家並進入遊戲。
2. 以可信任測試權限準備 Original 所需前置條件與資源。
3. 放置 Runtime-only（僅執行期）研讀物件。
4. 玩家實際執行 `study <物品>`。
5. 驗證 `improve_skill()` 造成的技能進度／等級變化。
6. `quit` 後重新登入。
7. 驗證研讀造成的技能資料仍存在，完成 Persistence（持久化）閉環。

## 證據邊界

在讀清 `improve_skill()` 的精確進度演算法以前，不硬寫預期升級數字；測試應先以「進度確實增加且重新登入後保存」為核心，再依 Original 原始碼補精確斷言。
