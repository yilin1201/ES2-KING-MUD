# Original ES2 M12 技能系統證據基線

> 狀態：`[Confirmed Source]` + `[ES2-KING Reconstruction]`
>
> 原則：保存 → 理解 → 重建 → 擴充。此文件只記錄已由 Original ES2 原始碼／歷史文件確認的內容；未確認的師門技能、學習公式或武學效果不補造。

## 1. 已確認的 Original 技能 Daemon（技能常駐物件）

目前保存的 `mudlib/daemon/skill/` 內至少確認：

- `unarmed`：徒手格鬥。
- `sword`：劍術。

兩者都 `inherit SKILL`，並向 `DAEMON_D` 註冊；戰鬥時會透過 `COMBAT_D->fight()` 執行招式。

## 2. Skill Daemon 的 Original 設計

歷史 `docs/legacy/build/skill` 明確說明：ES2 把技能抽象成 Skill Daemon。技能物件必須向 `DAEMON_D` 註冊，其他程式再透過 `SKILL_D("技能代號")` 取得技能定義。

因此 M12 不把技能當成單純文字欄位，而要驗證角色技能資料與真正 Skill Daemon 可以共同工作。

## 3. 角色技能資料介面

`mudlib/feature/char/skill.c` 已確認提供：

- `set_skill(skill, val)`：設定技能等級，現有 Original 上限為 200。
- `query_skill(skill, raw)`：讀取技能等級；非 raw 模式會納入暫時加成與技能映射。
- `improve_skill(skill, amount)`：增加學習進度，並呼叫對應 Skill Daemon 的 `skill_improved()`。
- `advance_skill(skill, amount)`：增加技能等級，最高 200，並呼叫 `skill_advanced()`。
- `map_skill()` / `skill_mapped()`：Original 已具備技能映射機制。

## 4. M12 第一階段 Runtime 驗證範圍

為避免把尚未考證的「師父教學條件」或「技能學習公式」誤寫成 Original，本階段只驗證已確認的底層能力：

1. 真實玩家角色可以持有 `unarmed` 與 `sword` 技能等級。
2. `set_skill()`、`query_skill()`、`advance_skill()` 在 Runtime 可執行。
3. 技能等級 200 上限確實生效。
4. `unarmed`、`sword` 的 Skill Daemon 能被 Runtime 載入。
5. 角色 `quit` 後重新登入，技能資料仍保存。

## 5. 尚未宣稱完成的內容

- NPC／師父正式教授技能流程。
- `learn`／`study` 等玩家指令的完整 Original 行為。
- 各武學的師承、前置技能、悟性需求與消耗公式。
- ES2-KING 高階武學（易筋經、如來神掌等）的正式接入。

上述項目待後續 Original 證據與 Runtime 驗證後再逐層接入。
