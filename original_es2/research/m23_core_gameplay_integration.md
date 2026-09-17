# M23 Original ES2 核心玩法整合

## 已確認可串接的核心循環

以下全部來自 `taedlar/es2_mudlib` Original Runtime 原始碼，可標示 `CONFIRMED_RUNTIME`：

1. Class（職業）：`feature/char/score.c` 以 `set_class()`、`query_class()` 與 `CLASS_D` 初始化角色。
2. Apprentice（拜師）：`cmds/std/apprentice.c` 呼叫師父的 `accept_apprentice()` 與 `init_apprentice()`；關係由 `feature/char/relation.c` 保存。
3. Skill（技能）：`feature/char/skill.c` 提供 `set_skill()`、`query_skill()`、`improve_skill()`、`advance_skill()` 與 `map_skill()`。
4. Enable／Map（技能激發／映射）：`cmds/usr/enable.c` 將基本技能映射到專用技能。
5. Study（研讀）：`cmds/std/study.c` 呼叫物件的 `study_ob()`，由 `feature/study.c` 依 Original 公式提高技能。
6. Force／Exert（內功／運功）：`cmds/std/exert.c` 依 force 映射呼叫專用內功的 `exert_function()`。
7. Perform（武學招式）：`cmds/std/perform.c` 依武學映射呼叫 `perform_action()`。
8. Combat（戰鬥）：`feature/char/combat.c` 與 `feature/char/attack.c` 使用映射技能進入 Original 戰鬥流程。
9. Snow 實例：`npc/alchemist.c` 可由平民拜師轉為方士並改善技能；`skill/dragon_force.c` 提供龍圖心經修煉與運功實例。

## 任務邊界

M18 已確認任務、進度與獎勵存在候選程式，但目前尚無完整「觸發→進度→完成→獎勵」鏈可安全宣告為完整 Original Quest Runtime（任務實機系統）。因此任務完整循環維持 `UNKNOWN`（未知），不為達成 M23 而補造。

## Original／Expansion 分離

本階段只驗證 Original 核心介面與既有 Snow 實例。ES2-KING Expansion（擴充內容）的功法、角色、世界與數值不得寫入 Original 核心玩法證據。
