# Original ES2 Evidence → Runtime Usability Matrix（證據轉實作可用性矩陣）

> 第四階段 4E。用途：把 Evidence（證據）轉成後續 Original ES2 重建工作的安全優先順序。這不是新的 Runtime PASS 宣告，也不覆蓋 `docs/status/CURRENT_M30_STATUS.md`。

## 可用性等級

- `IMPLEMENTABLE`（足以實作／維護）：已有 Original Source 或 Runtime 直接支持，可依證據重建，不自行補值。
- `PARTIAL_IMPLEMENTABLE`（部分可實作）：核心框架有直接證據，但內容、版本或資料集不完整；只能實作已確認部分。
- `REFERENCE_ONLY`（僅歷史參考）：有 Archived/Player 證據，但不足以直接建立 Original Runtime 機制。
- `SOURCE_REQUIRED`（仍缺來源）：必須先找到 Original Source/Runtime 才能安全實作。
- `CONFLICT_BLOCKED`（衝突阻擋）：關鍵值有來源衝突，不得自行選值。

| 領域 | 主要 Evidence | 可用性 | 可安全使用範圍 | 仍不可補造 |
|---|---|---|---|---|
| Character / Score 基礎 | `character_foundation.md`, `ui/score_interface.md` | PARTIAL_IMPLEMENTABLE | 八屬性代碼、HP/精氣神分離、多 Score Course 架構 | 未驗證成長公式 |
| Class 職業框架 | `original_class_reconstruction_m11.md` | PARTIAL_IMPLEMENTABLE | commoner/fighter Daemon、Class 初始化/升級呼叫鏈 | 遺失職業 Daemon、公式、能力 |
| Skill 技能底層 | `original_skill_reconstruction_m12.md` | IMPLEMENTABLE | set/query/improve/advance/map skill、現存 Skill Daemon | 未考證師門武學 |
| Study 研讀 | `original_study_formula_m12.md`, `original_study_learning_m12.md` | IMPLEMENTABLE | study 條件、成本、隨機學習、improve_skill 鏈 | 各武學專屬升級門檻 |
| Force 內功 | `original_martial_force_m13.md` | PARTIAL_IMPLEMENTABLE | force→專用內功映射、exert、dragon force 現存行為 | 遺失內功公式/門派歸屬 |
| Apprentice 師徒 | `original_apprentice_m14.md` | IMPLEMENTABLE | apprentice 指令、relation mapping、accept/init 流程 | 七職業完整師父與拜師條件 |
| NPC / Item 歷史人物 | `m16_npc_item_evidence_registry.md` | REFERENCE_ONLY | 人名、已保存裝備名稱 | NPC path、HP、技能、掉落率 |
| World 歷史區域 | `m17_world_evidence_registry.md`, Google Sites Map | REFERENCE_ONLY | 已辨識地名/關係 | 精確房間 path、出口、出生點 |
| Quest 任務 | `m18_quest_evidence_registry.md` | SOURCE_REQUIRED | 僅保留任務存在性/研究邊界 | daemon、旗標、獎勵、完整流程 |
| Lifecycle 生命週期 | `m19_lifecycle_evidence_registry.md` | PARTIAL_IMPLEMENTABLE | 昏迷、死亡、屍體、寺廟復活入口、在線年齡 | 完整鬼魂鏈、死亡懲罰、輪迴轉生 |
| Snow World 保存區 | `m21_world_content_evidence_registry.md` | IMPLEMENTABLE | snow 保存區、房間/出口/登入與復活房間基線 | 未保存歷史區域 |
| Snow NPC / Item | `m22_npc_item_evidence_registry.md` | IMPLEMENTABLE | 已保存 NPC/物品程式與 clone 關係 | 未直接支持的 HP/掉落/任務職責 |
| Race 種族框架 | Race Source + Runtime baseline | PARTIAL_IMPLEMENTABLE | 已確認 ID、已保存初始化框架、八屬性映射 | 缺失種族 initializer/能力公式 |
| Race 業力版本值 | Google Sites + 2014 Gameplay | CONFLICT_BLOCKED | 只可顯示各版本證據 | blackteeth 3/5、yaksa 35/30 不得選成單一 Original 真值 |
| Race 人類族 ID | Google Sites + Reconstruction | SOURCE_REQUIRED | 設定內容可作歷史參考 | `human_clan` 不得冒充 Original ID |

## 後續優先順序

1. **可直接維護的 Original Engine（引擎）**：Skill、Study、Apprentice、Snow World、Snow NPC/Item。
2. **部分可重建**：Character/Score、Class、Force、Lifecycle、Race Framework；每次只碰已確認區段。
3. **Evidence Recovery（證據補完）優先**：Quest、歷史 World/NPC、遺失 Race initializer、人類族 Original ID。
4. **Conflict 不阻塞其他工作**：blackteeth/yaksa 業力與刑天/形天版本文字繼續並存，不因尚未解決而阻塞已確認引擎。

## 4E 邊界

本矩陣只決定「證據是否足以支持實作」，不代表功能已通過 Public Acceptance（公開裝置驗收）。任何 Runtime 修改仍需依專案 Gate 規則做對應的最小必要驗證；本階段本身不執行 Runtime、Regression Test（回歸測試）或 GitHub Actions（GitHub 自動測試流程）。


## 第二階段：新增實機 Evidence → Runtime 對應

| 領域 | 新 Evidence | 可用性 | Runtime 對應 | 下一個最小 Gate |
|---|---|---|---|---|
| 梅影風核心 Skills | `mei_yingfeng_skills_runtime_evidence.md` | IMPLEMENTABLE（名稱／ID／acquire 關係） | M15 冷梅資料、後續梅影風 NPC/skill reconstruction | 驗證五項 ID 與 `acquire seven from may`；未知前置條件不補造 |
| 冷梅歷史內容 | `pixnet_clert2201_historical_gameplay_evidence.md` | PARTIAL_IMPLEMENTABLE | M15 Evidence/Data；Expansion 明鏡止水必須分層 | 只導入有直接證據欄位 |
| Login／創角／初期操作 | `es2_actual_login_character_runtime_evidence_part1.md` | PARTIAL_IMPLEMENTABLE | WebTelnet compatibility + Full Driver expected behavior | 逐格補 Prompt/Command/Output 後再收斂 E2E matcher |
| 寒梅心法命名 | Gameplay screenshot + PIXNET | IMPLEMENTABLE | Expansion `lengmei_d.c` compatibility naming | 正名為寒梅心法；舊冷梅心法僅 alias |

### 重複文件整合規則

M16/M22、M17/M21 等不同里程碑 Evidence 不刪除、不合併正文；Master Index 負責主題聚合。Plan/Result/Closure/Status-Historical 保留原路徑，Current 文件只引用，不複製其舊狀態。
