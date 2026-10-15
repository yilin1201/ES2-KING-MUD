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


## 後續整合更新（2026-10-15）

- 已確認 ES2M 參考來源 wolfer168/es2-webmud/main 的 HEAD 為 f21f59cecb55e5c3e31d2e97a7ef6d43783ecdcb，與先前盤點記錄一致；這是第三方 ES2M 來源，不等同 Original ES2。
- 已同步 yenhold/breathe 的裝備火焰傷害加成，並新增 human/resurge 與 avatar/radiate 參考指令。
- 已將 resurge/radiate 接入 race overlay，並更新靜態、回歸及玩家 E2E 測試。
- 本輪尚未執行完整 Repository 測試、Docker、Neolith 或玩家 E2E；目前不能宣稱 Runtime PASS。Render 維持暫停，PR #13 不合併。

## 新增靜態測試

從 Repository 根目錄執行：

```bash
python3 scripts/test_es2m_birth_attribute_contract.py
```

預期成功標記：

```text
ES2M_BIRTH_ATTRIBUTE_CONTRACT_STATIC_PASS: 12 races x 8 attributes; NOT RUNTIME PASS
```

此測試只比對保存的 ES2M race daemon 與 E2E 腳本的範圍定義。它不是 LPC 編譯、Neolith 執行、真實創角或存檔／重登通過證據。

## 下一步順序

1. 在可存取完整 Repository 的執行環境實際執行新增靜態測試，保存命令與結果；若出現 mismatch，先修正測試規格或查證來源，不直接改種族邏輯。
2. 執行現有 `scripts/test_race_phase2_static.sh` 與 `scripts/test_race_phase2_regression.sh`，保存結果。
3. 在不使用 Render 的前提下，使用可用的 Docker／Neolith 環境完成建置與 Runtime gate；如果環境無法執行，標記 `BLOCKED`，不宣稱通過。
4. 執行玩家 E2E：12 種族出生屬性、種族指令可達性、存檔、登出與重登。
5. 再做 class／score progression 與凍結功能回歸。
6. 測試證據齊全後，才提出整合審查；本紀錄本身不授權合併 PR 或部署。

## 尚未證明的項目

- 新增的 Python 靜態契約測試尚未在完整 Repository 工作目錄實際執行；本輪已透過 GitHub 讀取到的 12 個來源檔與 E2E 範圍表做等價靜態比對，12×8 項均一致，但這不等於 Python 測試程式或 Docker 建置已實際執行。
- 種族 E2E 尚未執行。
- Docker／Neolith Runtime 尚未取得本輪執行結果。
- ES2M 上游 commit 已獨立確認：wolfer168/es2-webmud/main = `f21f59cecb55e5c3e31d2e97a7ef6d43783ecdcb`；該來源仍屬第三方 ES2M，不代表 Original ES2。
- `yenhold/breathe.c`、human `resurge`、avatar `radiate` 的上游來源差異已確認並完成快照／接線更新；實際 LPC 載入、登入／指令契約與玩家 Runtime 結果仍待測試。
