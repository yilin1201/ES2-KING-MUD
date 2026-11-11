# Original ES2 M12 研讀／學習系統證據基線

> 狀態：`[Confirmed Source]`
>
> 本文件只整理 Original ES2 原始碼已確認的學習機制，不把 ES2-KING 尚未實裝的武學或師承公式冒充 Original。

## 1. study 指令

Original `mudlib/cmds/std/study.c` 已確認玩家指令格式為：

```text
study <物品>
```

用途是研讀書籍、文件等具有 `study_ob()` 的物件。玩家忙碌時不能開始研讀。

## 2. study_ob() 的學習條件

Original `mudlib/feature/study.c` 已確認研讀物件可以設定：

- `required/attribute`：最低人物屬性要求。
- `required/skill`：最低前置技能要求。
- `content`：可由該物件學習的技能，以及物件可教授／研讀到的上限。
- `study_msg`：開始研讀時的訊息。

玩家戰鬥中或忙碌中不能開始研讀；屬性或前置技能不足也不能理解內容。

## 3. 研讀消耗與成長

`study_content()` 已確認：

- 以 `literate`（讀寫能力）作為主要研讀技能基礎。
- 若內容要求 `archaic attainment`，會納入古文造詣並提高消耗。
- 研讀消耗 `gin`（精）與 `sen`（神）。
- `wis`（慧根）會影響研讀成本。
- `int`（悟性）會影響技能學習點數。
- 疲勞達上限時不能繼續研讀。
- 成功理解內容時會呼叫角色的 `improve_skill()` 增加學習進度。
- 成功研讀也可能提升 `literate`／`archaic attainment` 的學習進度，並增加疲勞。

## 4. 與 M12/M13 的關係

這證明 Original ES2 的技能成長不是單純由測試程式直接改技能等級。正式重建方向應區分：

1. `set_skill()`／`advance_skill()`：底層技能資料與進階介面。
2. `improve_skill()`：累積技能學習進度。
3. `study`：玩家透過書籍／文件進行真實學習的其中一條 Original 路徑。
4. `Skill Daemon`：技能本身的規則、進階回呼與戰鬥行為。

後續 Runtime 測試會先建立測試專用研讀物件，驗證 `study → improve_skill → 保存重登` 的真實鏈路，再進入 M13 武學／內功與 M14 師父教授系統。
