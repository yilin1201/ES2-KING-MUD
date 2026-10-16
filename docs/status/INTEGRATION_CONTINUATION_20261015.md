# ES2-KING 整合續作紀錄（2026-10-15）

## 本輪範圍

- `admin.c`：暫緩修正；本輪不修改、不套用 Claude 尚未確認的版本。
- Render：維持暫停，不觸發部署。
- PR #13：維持未合併；不執行合併操作。
- 冷梅劍法、寒梅心法、明鏡止水、傲梅暗劍訣、如來神掌、KING 武學演出及 Score UI：維持凍結，只允許 Blocking Regression 最小修復。

## 本輪完成

1. 重新讀取 `admin.c` 在 `build/original-es2-races-phase2` 與 `audit/king-race-runtime-inventory-20261015` 的版本。兩者 Git blob SHA 相同，均為 `8488ecdf4ea69507c1ac43e2e589c03f5779cfb6`；這只能證明兩個已查分支相同，不能證明包含 Claude 尚未推送的修改。
2. 逐一核對 ES2M snapshot 的 12 個種族 daemon，確認其八大出生屬性來源使用 `init_attribute` 中的 `base + random(n)` 形式。
3. 新增 `scripts/test_es2m_birth_attribute_contract.py`，用靜態來源契約比對 12 個種族的 8 個屬性，避免 E2E 腳本中的出生範圍表與保存快照逐漸不一致；並已將此檢查加入 Dockerfile 的建置閘門，供下一次建置自動執行。
4. 新增此續作紀錄，明確保留尚未執行的測試與阻塞項目。
5. 已確認 ES2M 參考來源 `wolfer168/es2-webmud/main` 的 HEAD 為 `f21f59cecb55e5c3e31d2e97a7ef6d43783ecdcb)，並將 `yenhold/breathe.c` 的火焰傷害裝備加成與來源同步。
6. 新增 Human `resurge`、Avatar `radiate` 來源檔，接入種族指令 overlay；補強回歸檢查，要求 10 個種族指令實際複製到生成 Runtime 的 `mudlib/cmds/usr`，且內容與快照一致。
7. 新增 `scripts/test_es2m_race_command_contract.py`，檢查十組種族指令映射、來源檔、回歸檢查與 E2E 探測相互一致。

## 本階段新增：CI 診斷強化

原先兩次 GitHub Actions run（`38733693202`、`38733734480`）都回報 failure，但工作記錄 API 無法取得 logs（Logs 404 / BlobNotFound），而 job step 資訊也未提供可判讀輸出。因此不能把它們當成程式測試失敗的根因，也不能宣稱 PASS。

已更新 `.github/workflows/es2m-race-static.yml`（commit `1ddafbadecd89667bbf99012564c83957aef5886`）：
- 三項靜態閘門各自執行並保留 exit code，不讓第一個失敗直接遮住其餘測試結果。
- 無論測試成功或失敗，都產生 GitHub Actions Step Summary。
- 將各項測試輸出打包為短期診斷 artifact，保存 7 天。
- 最後仍會在任一閘門失敗時讓 job 失敗；沒有把失敗改成成功，也沒有放寬品質標準。
- 這個 workflow 僅執行靜態測試，不部署 Render，也不等同 Docker／Neolith／玩家 Runtime 驗證。

此修改是診斷可觀測性補強，**尚未有新 run 的可讀結果**；在拿到結果前，CI 狀態仍為 `INFRA/DIAGNOSTIC BLOCKED`。

## 驗證狀態與限制

- 已使用 GitHub 讀取的 12 個 race daemon 與 E2E 範圍表做等價靜態解析，12 種族 × 8 屬性，共 96 項範圍一致。這不是實際執行新增 Python 測試程式的證據。
- `human/resurge.c` 與 `avatar/radiate.c` 的保存快照內容已核對與指定 ES2M 上游來源一致；這不代表 LPC 已成功載入或玩家 Runtime 行為已通過。
- 本地容器無法解析 `github.com`，無法 clone 完整 Repository，故未在本工具環境執行完整 Repository 測試。
- Docker／Neolith 建置與 12 種族玩家 E2E（創角、出生屬性、指令、存檔、登出、重登）尚未執行；目前不能宣稱 Runtime PASS。
- ES2M 是第三方參考來源，不得直接視為 Original ES2 Canon。

## 下一步順序

1. 取得 CI 診斷強化後的新 run 結果；若仍無 step/log/artifact 資訊，繼續標記 `INFRA/DIAGNOSTIC BLOCKED`，不猜測根因。
2. 在可存取完整 Repository 的 Docker 環境執行新增 Python 靜態契約、`test_race_phase2_static.sh` 及 `test_race_phase2_regression.sh`，記錄原始輸出。
3. 若靜態閘門通過，再執行 Docker／Neolith 建置及 Runtime gate；環境不能執行時標記 `BLOCKED`，不把未執行當成 PASS。
4. 逐一執行 12 種族玩家 E2E，確認出生數值、種族指令可達性、存檔、登出與重登。
5. 完成證據後，再處理 class／score progression 與凍結功能的回歸審查。

## 保護規則

- `admin.c` 維持未修改。
- PR #13 維持 OPEN / NOT MERGED。
- Render 維持暫停，不部署。
- 冷梅、寒梅、明鏡止水、傲梅暗劍訣、如來神掌及 Score UI 不做非必要修改。
- Original ES2、第三方 ES2M 與 ES2-KING Expansion 持續分層標示；沒有來源證據的設定維持 UNKNOWN。


## 本機重播證據補充與低風險修正（2026-10-16）

使用者提供了本機重播結果。這些是本機環境觀察，不冒充 GitHub Actions 原始日誌；已逐項對照 audit 分支並先處理不涉及遊戲規則的阻塞：

1. **World delta 假陽性**：`test_apply_es2m_20261008_world_delta.py` 原本在整份程式原始文字中搜尋禁止 token，連 `apply_es2m_20261008_world_delta.py` 模組說明中的「WebSocket」都會判失敗。已改為先驗證 Python 語法，再排除模組 docstring 後檢查可執行來源，避免把說明文字當成程式操作。Commit：`eb9a10dcc8c06444f062362edae18aafc3a12b7e`。尚待 CI／本機實際執行確認。
2. **Shell 權限**：兩個 E2E 腳本不再直接執行可能沒有 executable bit 的 `apply_race_phase2_runtime.sh`，改為明確透過 `bash` 呼叫；同一段中的其他 overlay shell script 也統一透過 `bash` 呼叫。Commits：`ed7468f764e235a1a974d2c09e0d27e08c3eaeeb`、`121f5184c5358dcf1b635b15f0fe29d614bd582f`。
3. **重複套用 Overlay**：Dockerfile 的 E2E 目標原本已是套用 race／KING Expansion 的 Runtime，E2E 又將該 Runtime 複製到暫存目錄並重複套用，可能因受保護 NPC／世界檔案與目前來源不同而中止。新增明確環境旗標 `ES2_RUNTIME_ALREADY_OVERLAID=1`：Docker 建置中的兩個 E2E 使用已完成 overlay 的 Runtime 時略過重複套用；其他手動呼叫預設仍會套用 overlay。Commits：`b2440e460a947b6fddade9ef9b4b9d35aadb8a9b`、`1e7a455ea9862ef775a3476e443081dc137a1be7`、`e5740c5f286c96614ce65a9cf4bf7773a7909a84`。尚待完整 E2E 驗證。
4. **武學檔案缺失錯誤訊息**：`test_es2m_latest_martial_updates.py` 在缺失路徑不位於 Repository 之下時，原本 `relative_to(ROOT)` 會先丟出 `ValueError`，遮蔽真正的缺檔訊息。已加入可回退到絕對／原始路徑的顯示函式。Commit：`17fd2f929f30504baf0f0219e456f3c572e99f84`。
5. **靜態 CI 覆蓋**：新增 world delta 與 latest martial source contract 兩個獨立閘門，並把相關 E2E／契約檔納入 path filter；每個閘門都會輸出 exit code、Step Summary 及短期 artifact，失敗仍維持失敗。Commit：`e272c9054dff90e834e2b388b01e1131c8b0a8ac`。

### 尚未處理／需保留決策

- `test_original_race_roster_source_gate.sh` 原先將 Original Human／Avatar karma 規格套用到已由 ES2M daemon 覆蓋的 Runtime。已拆開來源層級：Original karma／稀有轉化規則只讀 `/build/es2m-original-mudlib` 的 pinned Original source；Runtime 種族名冊只確認 12 個 daemon 存在，逐檔 ES2M 一致性由 race regression gate 驗證。沒有改寫或選擇任何一方的 karma 數值。Commit：`8f8dd3448e9fe0479bc910010033b7078e7b4fc7`、`e8f22ade08bc5395d95a802e2c8eecea75e111f5`、`3129b9000e31b607d9b06ebf40ee63a562ac3981`。尚待 Docker final runtime gate 實際執行。
- 種族確認文字將非人類種族顯示成 Avatar，屬顯示錯誤；先列入待修清單，沒有混入本輪建置阻塞修正。
- 使用者本機表示 12 個可選種族皆可創角，並檢查了屬性、精氣神、防禦力、職業上限；這是每種族單次取樣，不能證明隨機範圍，也尚未由本輪 CI 獨立重現。
- `scripts/replay_dockerfile_steps.py` 尚未加入，因目前未取得使用者所指本機重播工具的實際檔案內容；不得假裝已整合該工具。
- 新增 CI 閘門已提交；後續 Run `38830538066` 已取得可判讀結果，五項靜態 gate 全部成功。

### 本輪驗證狀態

- 目前 audit 分支相較 `build/original-es2-races-phase2` 的基準 commit `25f5f2ac2daaa4e5ad130d0f3f79abccc1dea7a9` ahead 39 commits；所有本輪修正仍只在 audit 分支。
- 本輪修改尚未以可存取的完整 Repository 本機執行測試；不得標記 PASS。
- Docker／Neolith、12 種族實際隨機範圍、存檔／登出／重登，以及完整玩家 E2E 仍待新一輪建置驗證。
- PR #13 不合併、Render 不部署、`admin.c` 不修改，凍結武學與 Score UI 不做非必要變更。


## 最新 CI 結果（2026-10-16）

- Run 38830465015（commit e272c9054dff90e834e2b388b01e1131c8b0a8ac）首次實際取得可讀 log。出生屬性、種族指令、overlay 接線及 latest martial 四項通過；World delta 測試失敗原因是 Python 3.14 已移除 ast.Str，不是原本的 WebSocket 說明文字假陽性。
- 已將模組 docstring 範圍判斷改成只使用 ast.Constant，commit 0d60e36948fd0296e88cb21fe35bab241c8ce39e。
- 最新 Run 38830538066 已完成且 SUCCESS。五項靜態 gate 全部 success，Step Summary 與診斷 artifact 正常產生：https://github.com/yilin1201/ES2-KING-MUD/actions/runs/38830538066
- 此成功只代表五項靜態檢查通過；沒有執行 Dockerfile 完整建置、Neolith Driver、12 種族實際創角隨機範圍或玩家存檔／登出／重登旅程。

## E2E overlay 重複套用修正的驗證限制

- 兩個 E2E shell 腳本已改用 bash 呼叫 overlay，避免依賴 Git 檔案 executable bit。
- Dockerfile 現在透過 ES2_RUNTIME_ALREADY_OVERLAID=1 明確告知 E2E：來源 Runtime 已套用 race／Expansion，測試不應再重複套用；未設定旗標的手動呼叫仍保留原本建置暫存 Runtime 的流程。
- 本輪 CI 是靜態工作流程，不會執行這兩個 Driver E2E。因此這項修正尚未由實際玩家旅程驗證。


## Original／ES2M 名冊閘門分層

- `assert_m30_final_runtime.sh` 現在將 pinned Original mudlib 路徑作為第二參數傳入 race roster gate；Dockerfile 傳入建置早期封存的 `/build/es2m-original-mudlib`。
- Original gate 僅驗證固定原版來源；ES2M Runtime 的 12 種族名冊另做存在性檢查，完整內容一致性仍由 race phase2 regression gate 負責。
- 靜態 workflow 增加四個 shell 腳本的 `bash -n` 語法檢查，並把 gate／assert 腳本納入 path filter。該 workflow 只驗證靜態語法與來源契約，不會執行 Docker final runtime gate。


Latest CI Run 38830731827 (commit 011c889d2c08bf7d467d3dda7cace0da96a944a5) completed SUCCESS; all six static gates passed, including bash -n syntax checks for four shell scripts. This does not establish full Docker/Neolith/player E2E PASS. https://github.com/yilin1201/ES2-KING-MUD/actions/runs/38830731827


## 2026-10-16 Docker builder failure follow-up: Original/Runtime source-layer separation

- Run [38830821542](https://github.com/yilin1201/ES2-KING-MUD/actions/runs/38830821542) failed at Dockerfile step `[M30 BUILD 5/5] Assert final playable Runtime`. The first failing sub-gate was `test_original_human_runtime_fixture_static.sh`, called by `assert_m30_final_runtime.sh` at line 88.
- Root cause reported from user local replay: the fixture combined final Runtime creation-flow checks with Original-only numeric source assertions. The final Runtime had already received the ES2M race overlay, so Original whitespace and numeric expectations were invalid for that layer.
- Fix on audit branch: `test_original_human_runtime_fixture_static.sh` now requires the pinned Original mudlib as argument 2; creation/setup flow is checked against final Runtime `logind.c`/ `chard.c`, while Original Human/Avatar karma, attributes, GIN/KEE/SEN, armor, and Original Avatar registration are checked against pinned Original source. Missing Original path is a hard failure, never a silent skip.
- Fix on audit branch: `assert_m30_final_runtime.sh` passes both Runtime and pinned Original mudlib to the Human fixture and player training source gate.
- Fix on audit branch: `test_player_training_source_gate.sh` now checks Original enable/skills/study/perform, skill progression and sneak/steal call sites against pinned Original source; the KING-only skill cap is checked separately against final Runtime. This addresses the reported likely next blocker in `cmds/std/sneak.c` without treating the unconfirmed local replay prediction as a confirmed Docker failure.
- Fix on audit branch: `test_race_phase2_regression.sh` now explicitly asserts that ES2M snapshot and Runtime human/avatar both contain `set("karma", 5);`. The separate Original roster gate continues to assert Original Avatar karma=100. This is a source-layer contract, not a gameplay test.
- Workflow review: `.github/workflows/es2m-race-static.yml` declares `permissions: contents: read`; the Docker validation job only runs `docker build --target builder -t es2-king-validation:ci .`. It has no registry login, no image push, no deploy action, and does not request write permissions. Static shell syntax checks now include the Human fixture and player training source gate.
- Still open: the user-reported difference between final Runtime `may_yin_fong.c` and its snapshot must be reviewed as a genuine source/runtime delta. Skipping duplicate overlay application prevents a false collision but does not resolve or explain this content difference. Keep it in the unresolved audit list until a three-way Original/ES2M snapshot/Runtime comparison determines whether it is expected, accidental, or requires Owner decision.
- Still open: 12-race randomized attribute ranges have not been proven by one-character-per-race samples; full distribution/range and player lifecycle E2E must remain pending until the next full Docker builder run supplies evidence.
- No PR merge, Render deploy, `admin.c` edit, or frozen martial/Score UI changes were made. Changes remain on the audit branch only.
