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
