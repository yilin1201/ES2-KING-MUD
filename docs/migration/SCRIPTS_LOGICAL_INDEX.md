# Scripts 邏輯分類索引

> 目的：先把 `scripts/` 分門別類，但 **不實體搬移**。目前 Script 路徑可能被 Docker、Workflow 或其他 Script 引用，屬 HIGH 風險。

## 01_BUILD_OVERLAY 建置/套用（3）

- `scripts/apply_es2_king_expansion.sh`
- `scripts/apply_race_phase2_runtime.sh`
- `scripts/bootstrap_original_es2.sh`

## 02_DEPLOY_RUNTIME 部署/啟動（7）

- `scripts/assert_m30_final_runtime.sh`
- `scripts/healthcheck_es2_king.mjs`
- `scripts/prepare_es2_persistence.sh`
- `scripts/start_es2_king_web.sh`
- `scripts/test_m30_deployment_smoke.mjs`
- `scripts/test_m30_deployment_static.sh`
- `scripts/test_m30_persistence_paths.sh`

## 03_ORIGINAL_TESTS Original/Runtime 測試（22）

- `scripts/test_lengmei_m15_runtime_gate.sh`
- `scripts/test_m16_npc_item_runtime_gate.sh`
- `scripts/test_m16_npc_item_static.sh`
- `scripts/test_m17_world_runtime_gate.sh`
- `scripts/test_m18_quest_runtime_gate.sh`
- `scripts/test_m19_lifecycle_runtime_gate.sh`
- `scripts/test_m19_lifecycle_static.sh`
- `scripts/test_m20_original_alpha.py`
- `scripts/test_m20_original_alpha_static.sh`
- `scripts/test_m21_world_runtime_gate.sh`
- `scripts/test_m21_world_static.sh`
- `scripts/test_m22_npc_item_runtime_gate.sh`
- `scripts/test_m22_npc_item_static.sh`
- `scripts/test_m23_core_gameplay_runtime_gate.sh`
- `scripts/test_m23_core_gameplay_static.sh`
- `scripts/test_m24_data_integrity_runtime_gate.sh`
- `scripts/test_m24_data_integrity_static.sh`
- `scripts/test_m25_release_candidate_runtime_gate.sh`
- `scripts/test_m25_release_candidate_static.sh`
- `scripts/test_m5_m18_closure.sh`
- `scripts/test_martial_force_m13_static.sh`
- `scripts/test_race_phase2_regression.sh`

## 04_EXPANSION_M26_M30 測試（22）

- `scripts/test_m26_king_admin_runtime_gate.sh`
- `scripts/test_m26_king_admin_static.sh`
- `scripts/test_m27_wuji_realm_runtime_gate.sh`
- `scripts/test_m27_wuji_realm_static.sh`
- `scripts/test_m28_martial_runtime_gate.sh`
- `scripts/test_m28_martial_static.sh`
- `scripts/test_m29_canon_runtime_gate.sh`
- `scripts/test_m29_canon_static.sh`
- `scripts/test_m30_alpha_runtime_gate.sh`
- `scripts/test_m30_alpha_static.sh`
- `scripts/test_m30_character_browser_input.mjs`
- `scripts/test_m30_claim_browser_input.mjs`
- `scripts/test_m30_desktop_centering.mjs`
- `scripts/test_m30_final_audit.sh`
- `scripts/test_m30_final_runtime_permissions.sh`
- `scripts/test_m30_king_claim_e2e.mjs`
- `scripts/test_m30_king_claim_e2e.sh`
- `scripts/test_m30_king_reservation_e2e.mjs`
- `scripts/test_m30_king_reservation_e2e.sh`
- `scripts/test_m30_mobile_responsive.mjs`
- `scripts/test_m30_production_equivalent_king_reservation.sh`
- `scripts/test_m30_webtelnet_display.mjs`

## 05_SUPPORT 其他支援（12）

- `scripts/test_apprentice_m14_static.sh`
- `scripts/test_class_m11_static.sh`
- `scripts/test_class_school_m11_static.sh`
- `scripts/test_es2_cn_standard.sh`
- `scripts/test_king_owner_authorization_static.sh`
- `scripts/test_lengmei_m15_static.sh`
- `scripts/test_race_original_baseline_m10.sh`
- `scripts/test_race_original_evidence_m10.sh`
- `scripts/test_race_phase2_static.sh`
- `scripts/test_roadmap_m21_m30.sh`
- `scripts/test_skill_m12_static.sh`
- `scripts/test_study_m12_static.sh`

## 重構規則

M30 Public Acceptance 前維持原路徑。未來若實體搬移，必須同一批更新 Workflow、Docker、Render 與 Script 內部引用，再做一次對應 Gate。
