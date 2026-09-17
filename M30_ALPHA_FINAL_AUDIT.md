# M30 ES2-KING Alpha 最終完整性稽核

稽核基準：`f5cc94a05fe57b4f7125122cc1bc0297ff5021b6`（`build/original-es2-races-phase2`）。

## 1. M0～M30 完整驗收矩陣

狀態只使用：`IMPLEMENTED + LOCAL PASS`、`PARTIAL`、`UNKNOWN`、`ACTIONS-INFRA-BLOCKED`。

| Milestone | 實際程式／來源 | Static | Runtime | Regression | Work 本機判定 | 稽核結論 |
|---|---|---|---|---|---|---|
| M0 | `.github/workflows/`、`ROADMAP_M0_M30.md` | roadmap test | N/A | roadmap | 可核對 | IMPLEMENTED + LOCAL PASS |
| M1 | `original_es2/source_manifest.md`、`scripts/bootstrap_original_es2.sh` | boundary | bootstrap | source manifest | 已核對 | IMPLEMENTED + LOCAL PASS |
| M2 | 上游 `taedlar/es2_mudlib` + Neolith；`original_es2/runtime/README.md` | driver workflow | Driver boot | M2 result | Driver 實機 | IMPLEMENTED + LOCAL PASS |
| M3 | `scripts/bootstrap_original_es2.sh` | bootstrap | clean tree | persistence | 已實跑 | IMPLEMENTED + LOCAL PASS |
| M4 | 上游 `feature/save.c`、`obj/login.c`、`obj/user.c` | `original_es2/runtime/m4_combat_skills_result.md` | combat/relogin | M4 workflow | 已實跑 | IMPLEMENTED + LOCAL PASS |
| M5 | `original_es2/research/*evidence*`、`historical_race_registry.json` | evidence tests | 無獨立玩法 | registry | 證據框架 | PARTIAL |
| M6 | `scripts/apply_race_phase2_runtime.sh`、上游 race daemon | race static | race runtime | phase2 regression | 歷史結果＋本機回歸 | IMPLEMENTED + LOCAL PASS |
| M7 | 上游 race attribute implementation | race static | race runtime | race regression | 歷史結果＋本機回歸 | IMPLEMENTED + LOCAL PASS |
| M8 | 上游 login／race acceptance | race static | real login | race regression | M25/M30 smoke | IMPLEMENTED + LOCAL PASS |
| M9 | `scripts/test_race_phase2_regression.sh` | regression | N/A | PASS evidence | 已核對 | IMPLEMENTED + LOCAL PASS |
| M10 | `original_es2/research/original_race_runtime_baseline_m10.tsv` + upstream | baseline | login baseline | `test_race_original_baseline_m10.sh` | 已核對 | IMPLEMENTED + LOCAL PASS |
| M11 | upstream class／school daemons；`scripts/test_class_m11_static.sh` | PASS | workflow runtime | class regression | 歷史 Runtime evidence | IMPLEMENTED + LOCAL PASS |
| M12 | upstream `feature/char/skill.c`、`feature/study.c` | skill/study static | study runtime | study regression | M23/M30 core Gate | IMPLEMENTED + LOCAL PASS |
| M13 | upstream force daemon／`cmds/std/exert.c` | `test_martial_force_m13_static.sh` | force workflow | force regression | M30 Original core Gate | IMPLEMENTED + LOCAL PASS |
| M14 | upstream apprentice relation／commands | apprentice static | apprentice workflow | relation regression | M23 core Gate | IMPLEMENTED + LOCAL PASS |
| M15 | `original_es2/data/m15_lengmei_mei_yingfeng.json`、upstream NPC | Lengmei static | Lengmei runtime | NPC regression | 歷史結果 | IMPLEMENTED + LOCAL PASS |
| M16 | upstream NPC／item source | NPC/item static | load runtime | item regression | M22/M30 | IMPLEMENTED + LOCAL PASS |
| M17 | upstream `/d/snow` world | world static | movement runtime | world regression | M21/M25/M30 | IMPLEMENTED + LOCAL PASS |
| M18 | upstream quest interfaces；`original_es2/research/m18_quest_*` | quest static | partial quest runtime | quest Gate | 完整歷史鏈未證實 | PARTIAL |
| M19 | upstream lifecycle；`scripts/test_m19_lifecycle_*` | PASS | PASS | PASS | 本機 PASS | IMPLEMENTED + LOCAL PASS |
| M20 | `scripts/test_m20_original_alpha.py`、`original_es2/tests/m20_original_alpha_acceptance.md` | PASS | real Original journey | M1-M19 | 本機／歷史結果 | IMPLEMENTED + LOCAL PASS |
| M21 | `original_es2/research/m21_*`、`scripts/test_m21_*` | PASS | PASS | PASS | 本機 PASS | IMPLEMENTED + LOCAL PASS |
| M22 | `original_es2/research/m22_*`、`scripts/test_m22_*` | PASS | PASS | PASS | 本機 PASS | IMPLEMENTED + LOCAL PASS |
| M23 | `original_es2/research/m23_core_gameplay_integration.md`、`scripts/test_m23_*` | PASS | PASS | PASS | 本機 PASS | IMPLEMENTED + LOCAL PASS |
| M24 | `original_es2/research/m24_system_data_integrity.md`、`scripts/test_m24_*` | PASS | PASS | PASS | 本機 PASS | IMPLEMENTED + LOCAL PASS |
| M25 | `original_es2/research/m25_release_candidate.md`、`scripts/test_m25_*` | PASS | PASS | PASS | Driver journey PASS | IMPLEMENTED + LOCAL PASS |
| M26 | `es2_king_expansion/runtime/mudlib/adm/daemons/kingd.c`、`kingcreate.c` | PASS | PASS | security regression | Driver PASS | IMPLEMENTED + LOCAL PASS |
| M27 | `es2_king_expansion/runtime/mudlib/d/king/wuji_realm.c`、`kingrealm.c` | PASS | PASS | M26 regression | Driver PASS | IMPLEMENTED + LOCAL PASS |
| M28 | `kingmartiald.c`、`kingmartial.c`、`m28_*` | PASS | PASS | cap regression | Driver PASS | IMPLEMENTED + LOCAL PASS |
| M29 | `kingcanon_d.c`、`kingcanon.c`、`m29_*` | PASS | PASS | Canon regression | Driver PASS | IMPLEMENTED + LOCAL PASS |
| M30 | `M30_ALPHA_FINAL_AUDIT.md`、`m30_*` | PASS | PASS | full available set | Alpha smoke PASS | IMPLEMENTED + LOCAL PASS |

## 2. Commit 證據鏈

M19 `c5e05dcf`；M20 `37c936ad`／`e1116df4`；M21 `566bfb9e`／`21333280`；M22 `2f678e82`；M23 `99a21c31`；M24 `3db4ffca`；M25 `6980f95a`；M26 `244319eb`；M27 `0eb2c063`；M28 `a31e5a37`；M29 `57d8a39a`；M30 `f5cc94a0`。

M0～M18 的歷史提交鏈可由 branch commit history 核對；本稽核不捏造不存在的單一 milestone SHA。

## 3. M30 Acceptance Criteria 逐條證據

| Acceptance Criteria | Repository path | 實際結果 |
|---|---|---|
| M1～M29 completion matrix | `original_es2/research/m30_completion_matrix.md` | Static PASS；逐項狀態已拆分 |
| Original／Expansion 相容性 | `scripts/test_m30_alpha_runtime_gate.sh` | Runtime PASS；Original 核心檔與 M26～M29 overlay 同時存在 |
| Original 200 skill cap | upstream `mudlib/feature/char/skill.c`；M30 runtime Gate | PASS，未改寫 |
| Expansion 300 progression | `es2_king_expansion/runtime/mudlib/adm/daemons/kingmartiald.c` | Driver PASS，Lv.300 顯示黑級無極境 |
| M29 ten layers／eleven forms／weapons | `kingcanon_d.c`、`kingcanon.c` | Driver PASS；越界拒絕 |
| Save／quit／relogin | `original_es2/runtime/m25_release_candidate_result.md`、upstream save source | Real Driver PASS |
| Driver Build／Boot | `.github/workflows/es2-king-m30-alpha.yml`、Neolith preset | Work-local PASS |
| TODO／FIXME／placeholder／STUB scan | `scripts/test_m30_alpha_static.sh` | PASS；無實際命中 |
| M21～M25 Original Release Candidate | `original_es2/runtime/m21_*`～`m25_*`、`scripts/test_m21_*`～`test_m25_*` | Work-local PASS；未知任務內容保持 UNKNOWN |
| M26～M29 Runtime 化 | `es2_king_expansion/runtime/mudlib/**` | Work-local Driver PASS，不是僅 Markdown |

## 4. 缺口、Stub、Placeholder、UNKNOWN

- M5 是證據／來源框架，不是玩家玩法；狀態為 `PARTIAL`。
- M18 的完整歷史任務鏈沒有可靠證據；狀態為 `PARTIAL`，未補造。
- M28／M29 的實際傷害、命中、冷卻、消耗、絕對必殺等仍為 `UNKNOWN`。
- Original 原始碼由 bootstrap 從上游 `taedlar/es2_mudlib` 取得，repo 不複製其保存原始碼；這是分層設計，不是 Markdown 假實作。
- GitHub Actions 全部受帳號額度／US$0 Spending Budget 阻塞，只能標記 `ACTIONS-INFRA-BLOCKED`，不列為 PASS 或 FAIL。

## 5. 最終狀態

M30 Work-local Alpha Acceptance：`IMPLEMENTED + LOCAL PASS`。

正式 GitHub Actions Acceptance：`ACTIONS-INFRA-BLOCKED`。

PR #13：Open；未 Merge。未建立 M31，未新增大型 Expansion。
