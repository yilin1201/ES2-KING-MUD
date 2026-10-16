# M31 Class／職業系統 Runtime Completion

> Milestone：M31 — Class 職業系統  
> 原則：Original Source → Archived Source → Reconstruction；UNKNOWN 不補造。

## Evidence Matrix

| 項目 | 狀態 | Evidence／可執行邊界 |
|---|---|---|
| `CLASS_D` 呼叫鏈 | CONFIRMED_SOURCE | `feature/char/score.c` 的 `set_class()`／`set_level()`／`gain_score()` 會呼叫 Class Daemon。 |
| `commoner`／平民 | CONFIRMED_SOURCE | taedlar v1.4 保存 `daemon/class/commoner.c` 與 `query_rank()`。 |
| `fighter`／武者 | CONFIRMED_SOURCE | taedlar v1.4 保存 `daemon/class/fighter.c` 與 `query_rank()`。 |
| `commoner → apprentice → alchemist` | CONFIRMED_SOURCE | Original 陳維俠 NPC 由 `accept_apprentice()`／`init_apprentice()` 呼叫 `set_class("alchemist")`，並設定龍圖丹派弟子。 |
| `alchemist` ID | CONFIRMED_SOURCE | Original NPC 與 `who -at` 均直接使用此 ID。 |
| 「方士」中文職業名 | ARCHIVED_SOURCE | Original ES2 七職業／門派封存資料明列 `alchemist = 方士`。 |
| 方士稱謂相容層 | RECONSTRUCTION | 只恢復 `query_rank()`，明確位於 ES2-KING Runtime overlay；不宣稱是回收的 Original LPC。 |
| 其他職業 Daemon／公式 | SOURCE_REQUIRED / UNKNOWN | soldier、scholar、taoist、thief、bonze 的目標 Original Daemon、初始化、升級、能力與裝備限制未完整回收。 |

## Runtime Call Chain

`玩家 apprentice chen`
→ Original `cmds/std/apprentice.c`
→ 陳維俠 `accept_apprentice()`
→ 陳維俠 `init_apprentice()`
→ Original relation mapping
→ `set_class("alchemist")`
→ `CLASS_D("alchemist")`
→ Reconstruction `query_rank()` 顯示「方士」
→ Original `save_object()`
→ quit／relogin／`restore_object()`。

## 實作邊界

本輪沒有新增或推測：

- initialize／advance_level 公式；
- 屬性、HP、精氣神或 score 成長；
- 技能、武學、裝備限制、戰鬥效果；
- 其他職業的拜師條件、門派規則或歷史內容。

這些項目全部維持 `UNKNOWN`。M31 的 Runtime PASS 只代表已保存且可實際執行的 Class 核心轉換與持久化閉環，不代表七職業內容已全部復原。

## Tests

- Static：`scripts/test_m31_class_static.sh`
- True Driver E2E：`scripts/test_m31_class_runtime_e2e.sh`
- Success marker：`M31_CLASS_RUNTIME_PASS`

Runtime Gate 使用完全隔離的 `classprobe` fixture；不讀寫正式 KING／Neon 玩家資料。

## Runtime Result（2026-09-26）

真實 Neolith Driver 已輸出：

- `M31_CLASS_PASS:commoner-rank`
- `M31_CLASS_PASS:original-world-school-route`
- `M31_CLASS_PASS:apprentice-set-class-alchemist-rank`
- `M31_CLASS_PASS:save-quit-relogin-restore`
- `M31_CLASS_RUNTIME_PASS`

最終判定：**M31 BOUNDED RUNTIME PASS**。此 PASS 僅涵蓋上列證據閉環；`SOURCE_REQUIRED / UNKNOWN` 邊界不變。


## 2026-09-27 Taoist Evidence-Bounded Compatibility

ES2-R1 Recovery 新增歷史職業／Help 證據：天師四派直接保存 `taoist.fire`、`taoist.storm`、`taoist.freeze`、`taoist.thunder`，茅山資料保存 `mao-shan.*`，並與歷史七職業資料共同支持中文職業名稱「道士」。

本輪只在 Expansion compatibility overlay 新增 `daemon/class/taoist.c` 的 `query_rank()`，使既有 `CLASS_D("taoist")` 類型的 score／who 稱謂查詢不因缺少 class daemon 而中斷。此檔明確標示 `[ES2-KING Reconstruction]`。

Evidence Boundary 不變：
- `taoist` 歷史職業 identity／中文名稱：ARCHIVED SOURCE / HELP CORROBORATED。
- 目標版本 `taoist` class daemon 原始 LPC：SOURCE_REQUIRED。
- initialize／advance_level／屬性成長／裝備限制／完整拜師條件：UNKNOWN。
- 道士技能 Help 與實機文字另見 `taoist_skill_combat_screenshot_evidence.md`；不得因此倒灌技能 Runtime。

Static Gate 已擴充 Unknown Guard，禁止 taoist compatibility layer 出現未經 Evidence 支持的成長、技能、裝備或戰鬥 callback。

狀態：**TAOIST RANK COMPATIBILITY IMPLEMENTED / RUNTIME JOURNEY NOT YET CLAIMED**。

## 2026-09-27 Phase 3 七職業 Runtime Gap Closure

已完成 `original_seven_class_runtime_matrix_phase3.md`。目標 tree 與全部可達 Git history 只保存 `commoner.c`／`fighter.c`；可由目標玩家流程閉合的 transition 是 alchemist、scholar、thief。taoist 只有 Evidence-bounded rank compatibility；fighter、taoist、bonze、soldier 均缺少完整同版本玩家入門鏈或 class daemon，狀態維持 `SOURCE_REQUIRED`／`EVIDENCE_EXHAUSTED`。

本輪沒有新增 Runtime LPC，也沒有重跑已 PASS 的 M31／Quest Journey。Static Gate：`scripts/test_original_seven_class_matrix_static.mjs`。

## 2026-09-28 Fighter Historical Reconstruction Runtime

R4 Target Gate 依 mudchina Historical Source 與 Target Original `fighter.c` 將 Fighter 提升為 `RECONSTRUCTION_READY`。本輪只建立明確標示 `[ES2-KING Reconstruction]` 的隔離武者同盟入口，將 Historical `join → me->set("class","fighter")` 適配為 Target `join → me->set_class("fighter")`。

隔離 `fighterprobe` 已由真實 Neolith Driver 完成：

`commoner → reconstruction entry → join → class=fighter → Original rank=武者 → save → quit → relogin → fighter/武者 restore`

Marker：`ORIGINAL_FIGHTER_CLASS_RUNTIME_PASS`。Final classification：`RECONSTRUCTION_RUNTIME_PASS`，不是 Recovered Target Original LPC。

未新增 Fighter initialize／advance_level、能力公式、技能、門派師父、裝備限制、戰鬥 bonus、NPC、Board 或 Waterfog 正式地圖連線。Taoist Gate 仍為 `SOURCE_REQUIRED`。
