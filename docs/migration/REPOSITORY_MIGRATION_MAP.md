# ES2-KING Migration Map（完整檔案遷移清冊）

> 盤點日期：2026-09-19  
> 基準 Head：`481c29f68980059083adc2a5d18fbd6568508b59`  
> 總檔案數：223  
> 第一批實體整理：COMPLETED（根目錄三份 M30 歷史報告已移至 `docs/history/m30/`）。
> 第三階段 3B：COMPLETED（Original research 14 份零引用 PLAN／RESULT／STATUS-HISTORICAL 已分流；Evidence 原位保留）。

## 判讀

- CURRENT：唯一目前狀態。
- CANON：正式規範、正式 Expansion 或可執行程式。
- EVIDENCE：Original／外部證據與研究。
- HISTORICAL：過去測試、Runtime、Workflow 或舊狀態紀錄。
- HIGH：搬動可能直接破壞 Build／Runtime／Workflow，因此 M30 Public Acceptance 前保持原位。

## 完整清冊

| # | 現有路徑 | 類型 | 動作 | 引用風險 | 說明 |
|---:|---|---|---|---|---|
| 1 | `.dockerignore` | CANON | KEEP | HIGH | 部署/Repository 固定位置 |
| 2 | `.github/workflows/es2-king-m26-admin-creation.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 3 | `.github/workflows/es2-king-m27-wuji-realm.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 4 | `.github/workflows/es2-king-m28-martial.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 5 | `.github/workflows/es2-king-m29-canon.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 6 | `.github/workflows/es2-king-m30-alpha.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 7 | `.github/workflows/original-es2-driver-build.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 8 | `.github/workflows/original-es2-m10-race-baseline.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 9 | `.github/workflows/original-es2-m11-class.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 10 | `.github/workflows/original-es2-m11-school-static.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 11 | `.github/workflows/original-es2-m12-skill.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 12 | `.github/workflows/original-es2-m12-study-runtime.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 13 | `.github/workflows/original-es2-m12-study-static.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 14 | `.github/workflows/original-es2-m13-force-runtime.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 15 | `.github/workflows/original-es2-m13-force-static.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 16 | `.github/workflows/original-es2-m14-apprentice-runtime.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 17 | `.github/workflows/original-es2-m14-apprentice-static.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 18 | `.github/workflows/original-es2-m15-lengmei-runtime-gate.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 19 | `.github/workflows/original-es2-m15-lengmei-static.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 20 | `.github/workflows/original-es2-m16-npc-item-runtime-gate.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 21 | `.github/workflows/original-es2-m16-npc-item-static.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 22 | `.github/workflows/original-es2-m17-world-runtime-gate.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 23 | `.github/workflows/original-es2-m18-quest-runtime-gate.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 24 | `.github/workflows/original-es2-m19-lifecycle.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 25 | `.github/workflows/original-es2-m20-alpha.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 26 | `.github/workflows/original-es2-m21-world-content.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 27 | `.github/workflows/original-es2-m22-npc-item.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 28 | `.github/workflows/original-es2-m23-core-gameplay.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 29 | `.github/workflows/original-es2-m24-data-integrity.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 30 | `.github/workflows/original-es2-m25-release-candidate.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 31 | `.github/workflows/original-es2-m4-combat.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 32 | `.github/workflows/original-es2-m5-races.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 33 | `.github/workflows/original-es2-race-phase2.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 34 | `.github/workflows/roadmap-m21-m30.yml` | HISTORICAL | KEEP | HIGH | 固定 Workflow 路徑；移出會停用 |
| 35 | `.gitignore` | CANON | KEEP | HIGH | 部署/Repository 固定位置 |
| 36 | `AGENTS.md` | CANON | KEEP | MEDIUM | 專案規範/入口 |
| 37 | `Dockerfile` | CANON | KEEP | HIGH | 部署/Repository 固定位置 |
| 38 | `ES2_CN_STANDARD.md` | CANON | KEEP | MEDIUM | 專案規範/入口 |
| 39 | `README.md` | CANON | KEEP | MEDIUM | 專案規範/入口 |
| 40 | `ROADMAP_M0_M30.md` | CANON | KEEP | MEDIUM | 專案規範/入口 |
| 41 | `docs/DOCUMENT_GOVERNANCE_ZH_TW.md` | CANON | KEEP | MEDIUM | 專案規範/入口 |
| 42 | `docs/ES2_KING_REPOSITORY_GUIDE_ZH_TW.md` | CANON | KEEP | MEDIUM | 專案規範/入口 |
| 43 | `docs/SOURCES.md` | CANON | KEEP | MEDIUM | 專案規範/入口 |
| 44 | `docs/history/m30/M30_ALPHA_FINAL_AUDIT.md` | HISTORICAL | KEEP | LOW | 已完成第一批搬移；M30 歷史紀錄 |
| 45 | `docs/history/m30/M30_DEPLOYMENT_READINESS.md` | HISTORICAL | KEEP | LOW | 已完成第一批搬移；M30 歷史紀錄 |
| 46 | `docs/history/m30/M30_PLAYABLE_ALPHA_ENTRY.md` | HISTORICAL | KEEP | LOW | 已完成第一批搬移；M30 歷史紀錄 |
| 47 | `docs/migration/REPOSITORY_MIGRATION_MAP.md` | CANON | KEEP | LOW | 完整遷移清冊 |
| 48 | `docs/status/CURRENT_M30_STATUS.md` | CURRENT | KEEP | LOW | 唯一即時狀態 |
| 49 | `es2_king_expansion/admin_rooms/wuji_realm.md` | CANON | KEEP | MEDIUM | Expansion 正式內容 |
| 50 | `es2_king_expansion/characters/liu_yi_wangxuan.md` | CANON | KEEP | MEDIUM | Expansion 正式內容 |
| 51 | `es2_king_expansion/characters/mei_yingfeng.md` | CANON | KEEP | MEDIUM | Expansion 正式內容 |
| 52 | `es2_king_expansion/martial_arts/yijinjing.md` | CANON | KEEP | MEDIUM | Expansion 正式內容 |
| 53 | `es2_king_expansion/races/README.md` | CANON | KEEP | MEDIUM | Expansion 正式內容 |
| 54 | `es2_king_expansion/races/headless.md` | CANON | KEEP | MEDIUM | Expansion 正式內容 |
| 55 | `es2_king_expansion/research/m26_king_admin_creation.md` | CANON | KEEP | MEDIUM | Expansion 設計/邊界 |
| 56 | `es2_king_expansion/research/m27_wuji_realm_runtime.md` | CANON | KEEP | MEDIUM | Expansion 設計/邊界 |
| 57 | `es2_king_expansion/research/m28_yijinjing_batian.md` | CANON | KEEP | MEDIUM | Expansion 設計/邊界 |
| 58 | `es2_king_expansion/research/m29_huntian_rulai_boundary.md` | CANON | KEEP | MEDIUM | Expansion 設計/邊界 |
| 59 | `es2_king_expansion/research/m30_king_owner_authorization.md` | CANON | KEEP | MEDIUM | Expansion 設計/邊界 |
| 60 | `es2_king_expansion/runtime/m26_king_admin_result.md` | HISTORICAL | KEEP | LOW | Expansion Runtime 歷史結果 |
| 61 | `es2_king_expansion/runtime/m27_wuji_realm_result.md` | HISTORICAL | KEEP | LOW | Expansion Runtime 歷史結果 |
| 62 | `es2_king_expansion/runtime/m28_martial_result.md` | HISTORICAL | KEEP | LOW | Expansion Runtime 歷史結果 |
| 63 | `es2_king_expansion/runtime/m29_canon_result.md` | HISTORICAL | KEEP | LOW | Expansion Runtime 歷史結果 |
| 64 | `es2_king_expansion/runtime/m30_alpha_result.md` | HISTORICAL | KEEP | LOW | Expansion Runtime 歷史結果 |
| 65 | `es2_king_expansion/runtime/mudlib/adm/daemons/kingcanon_d.c` | CANON | KEEP | HIGH | Expansion 正式 Runtime 程式 |
| 66 | `es2_king_expansion/runtime/mudlib/adm/daemons/kingd.c` | CANON | KEEP | HIGH | Expansion 正式 Runtime 程式 |
| 67 | `es2_king_expansion/runtime/mudlib/adm/daemons/kingmartiald.c` | CANON | KEEP | HIGH | Expansion 正式 Runtime 程式 |
| 68 | `es2_king_expansion/runtime/mudlib/cmds/adm/kingcanon.c` | CANON | KEEP | HIGH | Expansion 正式 Runtime 程式 |
| 69 | `es2_king_expansion/runtime/mudlib/cmds/adm/kingcreate.c` | CANON | KEEP | HIGH | Expansion 正式 Runtime 程式 |
| 70 | `es2_king_expansion/runtime/mudlib/cmds/adm/kingmartial.c` | CANON | KEEP | HIGH | Expansion 正式 Runtime 程式 |
| 71 | `es2_king_expansion/runtime/mudlib/cmds/adm/kingrealm.c` | CANON | KEEP | HIGH | Expansion 正式 Runtime 程式 |
| 72 | `es2_king_expansion/runtime/mudlib/d/king/wuji_realm.c` | CANON | KEEP | HIGH | Expansion 正式 Runtime 程式 |
| 73 | `es2_king_expansion/runtime/mudlib/obj/king/creation_mark.c` | CANON | KEEP | HIGH | Expansion 正式 Runtime 程式 |
| 74 | `king_library/README.md` | CANON | KEEP | LOW | KING 設定資料庫 |
| 75 | `king_library/characters/gu_feiyang_li_yunxiao.md` | CANON | KEEP | LOW | KING 設定資料庫 |
| 76 | `king_library/martial_arts/batian_lianti_jue.md` | CANON | KEEP | LOW | KING 設定資料庫 |
| 77 | `king_library/martial_arts/huntian_baojian.md` | CANON | KEEP | LOW | KING 設定資料庫 |
| 78 | `king_library/martial_arts/rulai_shenzhang.md` | CANON | KEEP | LOW | KING 設定資料庫 |
| 79 | `king_library/martial_arts/yijinjing.md` | CANON | KEEP | LOW | KING 設定資料庫 |
| 80 | `king_library/weapons/feiyun.md` | CANON | KEEP | LOW | KING 設定資料庫 |
| 81 | `king_library/weapons/guxiao.md` | CANON | KEEP | LOW | KING 設定資料庫 |
| 82 | `legacy_sources/gemini/README.md` | EVIDENCE | KEEP | LOW | Legacy 外部參考 |
| 83 | `legacy_sources/gemini/characters/summary.md` | EVIDENCE | KEEP | LOW | Legacy 外部參考 |
| 84 | `legacy_sources/gemini/corrections/exclusions.md` | EVIDENCE | KEEP | LOW | Legacy 外部參考 |
| 85 | `legacy_sources/gemini/martial_arts/summary.md` | EVIDENCE | KEEP | LOW | Legacy 外部參考 |
| 86 | `legacy_sources/gemini/narrative/combat_style.md` | EVIDENCE | KEEP | LOW | Legacy 外部參考 |
| 87 | `original_es2/characters/liu_yi_wangxuan.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 88 | `original_es2/characters/mei_yingfeng.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 89 | `original_es2/data/historical_race_registry.json` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 90 | `original_es2/data/m15_lengmei_mei_yingfeng.json` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 91 | `original_es2/races/README.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 92 | `original_es2/races/headless.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 93 | `original_es2/research/development_acceleration_status.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 94 | `original_es2/research/es2_google_sites_index.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 95 | `original_es2/research/m10_m12_next_execution.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 96 | `original_es2/research/m10_original_race_baseline_result.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 97 | `original_es2/research/m12_study_runtime_result.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 98 | `original_es2/research/m15_lengmei_runtime_plan.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 99 | `original_es2/research/m16_npc_item_evidence_registry.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 100 | `original_es2/research/m16_npc_item_runtime_plan.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 101 | `original_es2/research/m17_world_evidence_registry.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 102 | `original_es2/research/m17_world_runtime_plan.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 103 | `original_es2/research/m18_quest_closure.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 104 | `original_es2/research/m18_quest_evidence_registry.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 105 | `original_es2/research/m18_quest_runtime_plan.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 106 | `original_es2/research/m19_lifecycle_evidence_registry.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 107 | `original_es2/research/m19_lifecycle_runtime_plan.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 108 | `original_es2/research/m21_world_content_evidence_registry.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 109 | `original_es2/research/m21_world_content_runtime_plan.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 110 | `original_es2/research/m22_npc_item_evidence_registry.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 111 | `original_es2/research/m22_npc_item_runtime_plan.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 112 | `original_es2/research/m23_core_gameplay_integration.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 113 | `original_es2/research/m24_system_data_integrity.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 114 | `original_es2/research/m25_release_candidate.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 115 | `original_es2/research/m30_completion_matrix.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 116 | `original_es2/research/m5_evidence_closure.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 117 | `original_es2/research/original_apprentice_m14.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 118 | `original_es2/research/original_class_reconstruction_m11.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 119 | `original_es2/research/original_class_school_evidence.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 120 | `original_es2/research/original_google_sites_ingestion_status.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 121 | `original_es2/research/original_martial_force_m13.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 122 | `original_es2/research/original_race_google_sites_evidence.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 123 | `original_es2/research/original_race_reconstruction_phase2.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 124 | `original_es2/research/original_race_runtime_baseline_m10.tsv` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 125 | `original_es2/research/original_race_runtime_reconstruction_plan.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 126 | `original_es2/research/original_skill_reconstruction_m12.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 127 | `original_es2/research/original_study_formula_m12.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 128 | `original_es2/research/original_study_learning_m12.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 129 | `original_es2/research/original_study_runtime_plan_m12.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 130 | `original_es2/research/original_world_map_google_sites_evidence.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 131 | `original_es2/research/score_interface_spec.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 132 | `original_es2/runtime/README.md` | HISTORICAL | KEEP | MEDIUM | Original Runtime 歷史結果；保留證據 |
| 133 | `original_es2/runtime/m12_study_learning_result.md` | HISTORICAL | KEEP | MEDIUM | Original Runtime 歷史結果；保留證據 |
| 134 | `original_es2/runtime/m21_world_content_result.md` | HISTORICAL | KEEP | MEDIUM | Original Runtime 歷史結果；保留證據 |
| 135 | `original_es2/runtime/m22_npc_item_result.md` | HISTORICAL | KEEP | MEDIUM | Original Runtime 歷史結果；保留證據 |
| 136 | `original_es2/runtime/m23_core_gameplay_result.md` | HISTORICAL | KEEP | MEDIUM | Original Runtime 歷史結果；保留證據 |
| 137 | `original_es2/runtime/m24_data_integrity_result.md` | HISTORICAL | KEEP | MEDIUM | Original Runtime 歷史結果；保留證據 |
| 138 | `original_es2/runtime/m25_release_candidate_result.md` | HISTORICAL | KEEP | MEDIUM | Original Runtime 歷史結果；保留證據 |
| 139 | `original_es2/runtime/m2_character_attribute_plan.md` | HISTORICAL | KEEP | MEDIUM | Original Runtime 歷史結果；保留證據 |
| 140 | `original_es2/runtime/m3_persistence_relogin_result.md` | HISTORICAL | KEEP | MEDIUM | Original Runtime 歷史結果；保留證據 |
| 141 | `original_es2/runtime/m4_combat_skills_result.md` | HISTORICAL | KEEP | MEDIUM | Original Runtime 歷史結果；保留證據 |
| 142 | `original_es2/runtime/m5_race_framework_result.md` | HISTORICAL | KEEP | MEDIUM | Original Runtime 歷史結果；保留證據 |
| 143 | `original_es2/runtime/m6_m9_race_phase2_result.md` | HISTORICAL | KEEP | MEDIUM | Original Runtime 歷史結果；保留證據 |
| 144 | `original_es2/source_manifest.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 145 | `original_es2/systems/character_foundation.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 146 | `original_es2/tests/m20_original_alpha_acceptance.md` | EVIDENCE | KEEP | HIGH | Original 驗收規格/證據；可能被測試引用 |
| 147 | `original_es2/tests/minimum_playable_milestone.md` | EVIDENCE | KEEP | HIGH | Original 驗收規格/證據；可能被測試引用 |
| 148 | `original_es2/ui/score_interface.md` | EVIDENCE | KEEP | MEDIUM | Original ES2 證據/研究；禁止刪除 |
| 149 | `render.yaml` | CANON | KEEP | HIGH | 部署/Repository 固定位置 |
| 150 | `scripts/apply_es2_king_expansion.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 151 | `scripts/apply_race_phase2_runtime.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 152 | `scripts/assert_m30_final_runtime.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 153 | `scripts/bootstrap_original_es2.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 154 | `scripts/healthcheck_es2_king.mjs` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 155 | `scripts/prepare_es2_persistence.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 156 | `scripts/start_es2_king_web.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 157 | `scripts/test_apprentice_m14_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 158 | `scripts/test_class_m11_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 159 | `scripts/test_class_school_m11_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 160 | `scripts/test_es2_cn_standard.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 161 | `scripts/test_king_owner_authorization_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 162 | `scripts/test_lengmei_m15_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 163 | `scripts/test_lengmei_m15_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 164 | `scripts/test_m16_npc_item_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 165 | `scripts/test_m16_npc_item_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 166 | `scripts/test_m17_world_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 167 | `scripts/test_m18_quest_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 168 | `scripts/test_m19_lifecycle_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 169 | `scripts/test_m19_lifecycle_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 170 | `scripts/test_m20_original_alpha.py` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 171 | `scripts/test_m20_original_alpha_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 172 | `scripts/test_m21_world_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 173 | `scripts/test_m21_world_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 174 | `scripts/test_m22_npc_item_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 175 | `scripts/test_m22_npc_item_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 176 | `scripts/test_m23_core_gameplay_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 177 | `scripts/test_m23_core_gameplay_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 178 | `scripts/test_m24_data_integrity_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 179 | `scripts/test_m24_data_integrity_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 180 | `scripts/test_m25_release_candidate_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 181 | `scripts/test_m25_release_candidate_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 182 | `scripts/test_m26_king_admin_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 183 | `scripts/test_m26_king_admin_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 184 | `scripts/test_m27_wuji_realm_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 185 | `scripts/test_m27_wuji_realm_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 186 | `scripts/test_m28_martial_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 187 | `scripts/test_m28_martial_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 188 | `scripts/test_m29_canon_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 189 | `scripts/test_m29_canon_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 190 | `scripts/test_m30_alpha_runtime_gate.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 191 | `scripts/test_m30_alpha_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 192 | `scripts/test_m30_character_browser_input.mjs` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 193 | `scripts/test_m30_claim_browser_input.mjs` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 194 | `scripts/test_m30_deployment_smoke.mjs` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 195 | `scripts/test_m30_deployment_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 196 | `scripts/test_m30_desktop_centering.mjs` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 197 | `scripts/test_m30_final_audit.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 198 | `scripts/test_m30_final_runtime_permissions.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 199 | `scripts/test_m30_king_claim_e2e.mjs` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 200 | `scripts/test_m30_king_claim_e2e.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 201 | `scripts/test_m30_king_reservation_e2e.mjs` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 202 | `scripts/test_m30_king_reservation_e2e.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 203 | `scripts/test_m30_mobile_responsive.mjs` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 204 | `scripts/test_m30_persistence_paths.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 205 | `scripts/test_m30_production_equivalent_king_reservation.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 206 | `scripts/test_m30_webtelnet_display.mjs` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 207 | `scripts/test_m5_m18_closure.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 208 | `scripts/test_martial_force_m13_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 209 | `scripts/test_race_original_baseline_m10.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 210 | `scripts/test_race_original_evidence_m10.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 211 | `scripts/test_race_phase2_regression.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 212 | `scripts/test_race_phase2_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 213 | `scripts/test_roadmap_m21_m30.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 214 | `scripts/test_skill_m12_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 215 | `scripts/test_study_m12_static.sh` | CANON | KEEP | HIGH | 工程腳本；M30 前不搬移 |
| 216 | `webtelnet/README.md` | CANON | KEEP | HIGH | Public Web Runtime；部署引用 |
| 217 | `webtelnet/package-lock.json` | CANON | KEEP | HIGH | Public Web Runtime；部署引用 |
| 218 | `webtelnet/package.json` | CANON | KEEP | HIGH | Public Web Runtime；部署引用 |
| 219 | `webtelnet/public/character-input.mjs` | CANON | KEEP | HIGH | Public Web Runtime；部署引用 |
| 220 | `webtelnet/public/claim-input.mjs` | CANON | KEEP | HIGH | Public Web Runtime；部署引用 |
| 221 | `webtelnet/public/index.html` | CANON | KEEP | HIGH | Public Web Runtime；部署引用 |
| 222 | `webtelnet/server.mjs` | CANON | KEEP | HIGH | Public Web Runtime；部署引用 |
| 223 | `webtelnet/telnet.mjs` | CANON | KEEP | HIGH | Public Web Runtime；部署引用 |

## 已完成的實體整理

根目錄三份舊 M30 報告已移至 `docs/history/m30/`，相關 Current／Governance／Guide 引用已同步校正。Original ES2 證據未刪除、Runtime 程式未搬動、Workflow 未搬動。

## 下一批候選

下一批先做「邏輯分類索引」，不搬動 `scripts/`、`.github/workflows/`、`webtelnet/` 或 Runtime 程式。原因是這些屬 HIGH 引用風險；若要實體重構，需在 M30 Public Acceptance 後另做路徑依賴遷移。


## 第三階段 3B — Original Research 實體分流

2026-09-19 完成逐份檔名引用檢查。14 份候選在 Repository 內未發現其他檔案引用，因此安全搬移：`plans/` 10 份、`results/` 2 份、`status_history/` 2 份。Original EVIDENCE 共 19 份維持原位，不刪除、不任意合併；CLOSURE 本輪亦維持原位。未執行 Runtime、Regression Test 或 GitHub Actions。


## 第三階段 3C — Original Closure 分類

2026-09-19 完成 6 份 Closure 逐份內容與 Repository 檔名引用檢查；未發現其他檔案引用舊路徑，因此搬入 `original_es2/research/closure/`。

- Original Baseline Closure（仍有效的 Original 基線）：M5、M18、M23、M24、M25，共 5 份。其證據邊界仍有效，但不代表目前 Public Acceptance。
- Historical Closure（歷史結案、Current 已取代目前狀態判定）：M30 Completion Matrix，共 1 份。保留歷史內容，但目前 M30 狀態必須以 `docs/status/CURRENT_M30_STATUS.md` 為準。
- 所有 Closure 原始正文均保留；僅新增治理 Banner（分類提示）並調整路徑。
- 未刪除／合併 Original Evidence；未執行 Runtime、Regression Test 或 GitHub Actions。


## 第四階段 4A — Original Evidence 治理

2026-09-19 完成 Original Research Evidence 第一輪來源分級與交叉關係盤點，建立 `original_es2/research/EVIDENCE_MASTER_INDEX.md`。原 19 份候選中，18 份確認為 Original Evidence 並原位保守保存；沒有任何 Evidence 因內容相似而刪除或合併。

辨識出 `score_interface_spec.md` 本身明確標示 `[PROJECT-CANON]`，屬 ES2-KING 正式介面模板而非 Original 歷史證據；Repository 搜尋未發現其他檔案引用舊檔名後，已安全移至 `es2_king_expansion/canon/interface/score_interface_spec.md`，正文保留並加上歸屬提示。

本輪未執行 Runtime、Regression Test 或 GitHub Actions；PR #13 維持 Open，未進 M31。


## 第四階段 4B — Evidence 衝突治理

建立 `original_es2/research/EVIDENCE_CONFLICT_REGISTER.md`。目前辨識 5 類：刑天/形天命名衝突、黑齒業力 3/5、夜叉業力 35/30、cor/cps 中文欄位映射衝突、人類族 Original ID 待考證。所有來源正文維持不變；未因衝突刪除或合併 Evidence。

其中 cor/cps 為高風險核心欄位映射，暫不自動校正，待直接 Original Source／實機證據確認；其他歷史衝突以版本差異並存方式治理。


## 第四階段 4C — Attribute Mapping 一致性校正

Owner 確認 Original 正確欄位為 `cor=膽識`、`cps=定力`。已校正 `original_es2/data/historical_race_registry.json`、`original_es2/systems/character_foundation.md` 與 `original_es2/races/headless.md` 中的反向／舊標示；`original_es2/ui/score_interface.md` 與 `es2_google_sites_index.md` 原本即為正確映射，未改動。此為資料一致性修正，未執行 Runtime 或 Regression Test。


## 第四階段 4D — Evidence Status Standard

建立 `original_es2/research/EVIDENCE_STATUS_STANDARD.md`，統一 Original Research 證據狀態：`CONFIRMED_SOURCE`、`CONFIRMED_RUNTIME`、`ARCHIVED_SOURCE`、`ARCHIVED_GAMEPLAY`、`PLAYER_RECORD`、`RECONSTRUCTION`、`UNKNOWN`、`SOURCE_PENDING`、`CONFLICT`。舊標籤保留相容映射，不為改標籤而重寫歷史 Evidence。

優先修正三份 Google Sites／截圖型 Evidence 的頂層狀態：Class/School、Race、World Map 均明確列為 `ARCHIVED_SOURCE`，避免舊 `[Confirmed Source]` 被誤讀為 Original LPC Source Code。Evidence 事實正文未刪除、未合併；未執行 Runtime、Regression Test 或 GitHub Actions。


## 第四階段 4E — Evidence → Runtime Usability Matrix

建立 `original_es2/research/EVIDENCE_RUNTIME_USABILITY_MATRIX.md`，以 `IMPLEMENTABLE`、`PARTIAL_IMPLEMENTABLE`、`REFERENCE_ONLY`、`SOURCE_REQUIRED`、`CONFLICT_BLOCKED` 區分 Evidence 對 Original Runtime 重建的可用程度。

可直接依現存證據維護的核心包括 Skill、Study、Apprentice、Snow World、Snow NPC/Item；Character/Score、Class、Force、Lifecycle、Race Framework 僅能重建已確認部分。Quest、未保存歷史 World/NPC、遺失 Race initializer 與人類族 Original ID 仍需 Evidence Recovery。Race 業力版本衝突保持並存，不選定單一 Original 真值。本輪未修改 Runtime，未執行 Regression Test 或 GitHub Actions。


## 第四階段 4F — Evidence Recovery Backlog + Actions Failure Review

建立 `original_es2/research/EVIDENCE_RECOVERY_BACKLOG.md`，依 P0/P1/P2 排定 Quest、人類族 Original ID、Race initializer、冷梅莊／NPC、世界地圖與遺失 Class Daemon 的證據補完順序。

另確認 4E 後 GitHub PR event 自動觸發大量 Actions run 並標示 failure；抽查 M30 Alpha `35439403202`、M21-M30 Roadmap `35439403256`、Driver Build `35439403040`，均在約 5–10 秒內結束。4E 僅為 docs 變更，且專案既有零付費 Actions infrastructure block；不 rerun、不提高 Budget。Job log 端目前無可用 blob，因此不把這批結果解讀成 Runtime regression。
