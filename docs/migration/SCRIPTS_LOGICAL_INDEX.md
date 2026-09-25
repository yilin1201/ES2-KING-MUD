# Scripts 邏輯分類索引

> Cleanup 基準：`c1fc52dd5a938b2100c91cfabdbd9c59593f2fdc`  
> 80 份 Script 均有 Runtime、Regression、Deployment 或歷史 Gate 用途。為避免 Docker／Workflow／Script path regression，本輪維持原路徑，只做完整分類，不實體搬移。

## 01_BUILD_OVERLAY（2）

- `scripts/apply_es2_king_expansion.sh`
- `scripts/bootstrap_original_es2.sh`

## 02_RUNTIME_DEPLOY（11）

- `scripts/assert_m30_final_runtime.sh`
- `scripts/healthcheck_es2_king.mjs`
- `scripts/prepare_es2_persistence.sh`
- `scripts/start_es2_king.sh`
- `scripts/start_es2_king_playable.sh`
- `scripts/start_es2_king_web.sh`
- `scripts/sync_es2_persistence.sh`
- `scripts/test_m30_deployment_smoke.mjs`
- `scripts/test_m30_deployment_static.sh`
- `scripts/test_m30_final_runtime_permissions.sh`
- `scripts/test_m30_persistence_paths.sh`

## 03_GAME_COMPLETION（11）

- `scripts/audit_game_completion_runtime.sh`
- `scripts/bootstrap_game_completion_character.sh`
- `scripts/run_game_completion_track.sh`
- `scripts/test_daxie_qisun_runtime_e2e.mjs`
- `scripts/test_daxie_qisun_runtime_e2e.sh`
- `scripts/test_daxie_qisun_static.sh`
- `scripts/test_game_completion_bootstrap_static.sh`
- `scripts/test_game_completion_full_driver_e2e.mjs`
- `scripts/test_game_completion_full_driver_e2e.sh`
- `scripts/test_game_completion_journey.sh`
- `scripts/test_game_completion_quest_evidence.sh`

## 04_TEST_GATES（55）

- `scripts/test_apprentice_m14_static.sh`
- `scripts/test_class_m11_static.sh`
- `scripts/test_class_school_m11_static.sh`
- `scripts/test_es2_cn_standard.sh`
- `scripts/test_king_owner_authorization_static.sh`
- `scripts/test_lengmei_m15_runtime_gate.sh`
- `scripts/test_lengmei_m15_static.sh`
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
- `scripts/test_m30_king_claim_e2e.mjs`
- `scripts/test_m30_king_claim_e2e.sh`
- `scripts/test_m30_king_reservation_e2e.mjs`
- `scripts/test_m30_king_reservation_e2e.sh`
- `scripts/test_m30_mobile_responsive.mjs`
- `scripts/test_m30_production_equivalent_king_reservation.sh`
- `scripts/test_m30_webtelnet_display.mjs`
- `scripts/test_m5_m18_closure.sh`
- `scripts/test_martial_force_m13_static.sh`
- `scripts/test_race_original_baseline_m10.sh`
- `scripts/test_race_original_evidence_m10.sh`
- `scripts/test_race_phase2_regression.sh`
- `scripts/test_race_phase2_static.sh`
- `scripts/test_roadmap_m21_m30.sh`
- `scripts/test_skill_m12_static.sh`
- `scripts/test_study_m12_static.sh`

## 05_SUPPORT（1）

- `scripts/apply_race_phase2_runtime.sh`

## 規則

- 新增 Script 前先確認能否擴充現有入口。
- Runtime path 搬移必須與 Docker、Workflow、其他 Script 引用同一 Commit 更新。
- Historical Gate 可保留，但 Current PASS 以 `docs/status/CURRENT_M30_STATUS.md` 為準。
