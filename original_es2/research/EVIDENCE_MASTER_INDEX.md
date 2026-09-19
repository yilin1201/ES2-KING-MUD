# Original ES2 Evidence Master Index（證據總索引）

> 第四階段 4A。目的：建立 19 份 Original Research Evidence 的來源分級與主題索引；**本階段不搬移、不刪除、不合併 Evidence 正文**。

## 證據優先原則

Original Source（原始程式／官方保存來源） > Archived Source（歷史網站／截圖／封存） > Archived Gameplay Record（歷史實機紀錄） > Player Record（玩家紀錄） > Reconstruction（重建推論）。來源衝突時並列保存，不自行融合。

| 檔案 | 主題 | 主要來源層級 | 角色 | 重複/交叉關係 | 動作 |
|---|---|---|---|---|---|
| `es2_google_sites_index.md` | 全站索引 | Archived / Player / Source 混合 | Master Registry | 與各 Google Sites 專項交叉 | KEEP |
| `m16_npc_item_evidence_registry.md` | NPC/物品 M16 | Text + Runtime | Registry | M22 為後續 Runtime 擴充，不取代 M16 | KEEP |
| `m17_world_evidence_registry.md` | 世界 M17 | Text + Runtime | Registry | M21 為後續 Runtime 擴充，不取代 M17 | KEEP |
| `m18_quest_evidence_registry.md` | 任務 | Text + Runtime | Registry | 與 M18 Closure 配對 | KEEP |
| `m19_lifecycle_evidence_registry.md` | 生命週期 | Original Runtime | Registry | 與 M24 資料完整性交叉 | KEEP |
| `m21_world_content_evidence_registry.md` | 世界 Runtime | Original Runtime | Registry | 補強 M17；不是重複刪除候選 | KEEP |
| `m22_npc_item_evidence_registry.md` | NPC/物品 Runtime | Original Runtime | Registry | 補強 M16；不是重複刪除候選 | KEEP |
| `original_apprentice_m14.md` | 師徒 | Original Source | Baseline | 與 M23 核心玩法交叉 | KEEP |
| `original_class_reconstruction_m11.md` | 職業 Runtime | Original Source | Baseline | 與門派截圖證據互補 | KEEP |
| `original_class_school_evidence.md` | 七職業/門派 | Archived Screenshot | Baseline | 與 M11 Runtime 證據互補 | KEEP |
| `original_martial_force_m13.md` | 武學/內功 | Original Source | Baseline | 與 M23 核心玩法交叉 | KEEP |
| `original_race_google_sites_evidence.md` | 種族設定 | Archived Screenshot | Baseline | 與 Race Reconstruction 來源不同 | KEEP |
| `original_race_reconstruction_phase2.md` | 種族重建 | Source + Archived Gameplay | Reconstruction Baseline | 保留版本/命名衝突，不與網站證據融合 | KEEP |
| `original_race_runtime_baseline_m10.tsv` | 種族 Runtime 基線 | Runtime Dataset | Machine-readable Evidence | 與 Race 文件配對 | KEEP |
| `original_skill_reconstruction_m12.md` | 技能 | Original Source + Reconstruction | Baseline | 與 Study 文件互補 | KEEP |
| `original_study_formula_m12.md` | Study 精確公式 | Original Source | Formula Evidence | 比 Learning 文件更精確的公式層 | KEEP |
| `original_study_learning_m12.md` | Study 行為 | Original Source | Behavioral Evidence | 與 Formula 互補，不合併 | KEEP |
| `original_world_map_google_sites_evidence.md` | 國家地圖 | Archived Screenshot | Visual Evidence | 與 M17/M21 Runtime 世界證據互補 | KEEP |
| `score_interface_spec.md` | Score 介面 | PROJECT-CANON + Evidence Boundary | Mixed / Needs separation later | 含 ES2-KING Canon，不應當純 Original Evidence | REVIEW |

## 4A 結論

目前沒有任何一組 Evidence 適合直接去重刪除。M16→M22、M17→M21 是不同里程碑／不同證據成熟度；Study Formula／Learning 是公式與行為兩層；Race Google Sites／Reconstruction 是不同來源層。唯一需要後續治理的是 `score_interface_spec.md`：它明確標示 PROJECT-CANON，混在 Original Research Evidence 目錄中，應在 4B 評估移至 ES2-KING Canon/介面規格位置，但在未完成引用檢查前不搬動。
