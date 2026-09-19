# Original ES2 Research 分類索引

> 第三階段整理。目的：分離 Evidence／Plan／Result／Closure，避免「曾經計畫做」被誤讀成「目前已完成」。
> 本階段不刪除任何 Original 證據，也不搬動可能影響既有引用的研究檔；先以分類索引建立語意邊界。

## 判讀優先順序

1. EVIDENCE（證據）：可支持 Original 歷史／程式事實，但仍須遵守來源等級。
2. PLAN（計畫）：當時預定工作，**不得當作完成證據**。
3. RESULT（結果）：某次測試／研究結果，代表當時證據，不自動等於目前 Runtime。
4. CLOSURE（結案）：里程碑結論／邊界；若與 CURRENT 狀態衝突，以 `docs/status/CURRENT_M30_STATUS.md` 為目前狀態。
5. STATUS-HISTORICAL（舊狀態）：只代表撰寫當時，不得用來啟動重複測試。

## EVIDENCE（19）

- `original_es2/research/es2_google_sites_index.md`
- `original_es2/research/m16_npc_item_evidence_registry.md`
- `original_es2/research/m17_world_evidence_registry.md`
- `original_es2/research/m18_quest_evidence_registry.md`
- `original_es2/research/m19_lifecycle_evidence_registry.md`
- `original_es2/research/m21_world_content_evidence_registry.md`
- `original_es2/research/m22_npc_item_evidence_registry.md`
- `original_es2/research/original_apprentice_m14.md`
- `original_es2/research/original_class_reconstruction_m11.md`
- `original_es2/research/original_class_school_evidence.md`
- `original_es2/research/original_martial_force_m13.md`
- `original_es2/research/original_race_google_sites_evidence.md`
- `original_es2/research/original_race_reconstruction_phase2.md`
- `original_es2/research/original_race_runtime_baseline_m10.tsv`
- `original_es2/research/original_skill_reconstruction_m12.md`
- `original_es2/research/original_study_formula_m12.md`
- `original_es2/research/original_study_learning_m12.md`
- `original_es2/research/original_world_map_google_sites_evidence.md`
- `original_es2/research/score_interface_spec.md`

## PLAN（15）

- `original_es2/research/m10_m12_next_execution.md`
- `original_es2/research/m15_lengmei_runtime_plan.md`
- `original_es2/research/m16_npc_item_runtime_plan.md`
- `original_es2/research/m17_world_runtime_plan.md`
- `original_es2/research/m18_quest_runtime_plan.md`
- `original_es2/research/m19_lifecycle_runtime_plan.md`
- `original_es2/research/m21_world_content_runtime_plan.md`
- `original_es2/research/m22_npc_item_runtime_plan.md`
- `original_es2/research/original_race_runtime_reconstruction_plan.md`
- `original_es2/research/original_study_runtime_plan_m12.md`
- `original_es2/research/plans/m10_m12_next_execution.md`
- `original_es2/research/plans/m15_lengmei_runtime_plan.md`
- `original_es2/research/plans/m16_npc_item_runtime_plan.md`
- `original_es2/research/plans/m17_world_runtime_plan.md`
- `original_es2/research/plans/m18_quest_runtime_plan.md`

## RESULT（4）

- `original_es2/research/m10_original_race_baseline_result.md`
- `original_es2/research/m12_study_runtime_result.md`
- `original_es2/research/results/m10_original_race_baseline_result.md`
- `original_es2/research/results/m12_study_runtime_result.md`

## CLOSURE（7）

- `original_es2/research/closure/m18_quest_closure.md`
- `original_es2/research/m18_quest_closure.md`
- `original_es2/research/m23_core_gameplay_integration.md`
- `original_es2/research/m24_system_data_integrity.md`
- `original_es2/research/m25_release_candidate.md`
- `original_es2/research/m30_completion_matrix.md`
- `original_es2/research/m5_evidence_closure.md`

## STATUS-HISTORICAL（3）

- `original_es2/research/development_acceleration_status.md`
- `original_es2/research/original_google_sites_ingestion_status.md`
- `original_es2/research/status_history/development_acceleration_status.md`

## 實體重構判定

目前先不把這 39 份研究檔大量搬入子資料夾。原因是研究檔可能被 Workflow、Script、歷史文件以固定路徑引用；第三階段優先完成「語意去混淆」。下一次實體搬移只針對確認零引用的 PLAN／RESULT／STATUS-HISTORICAL，並同步更新 Migration Map。
