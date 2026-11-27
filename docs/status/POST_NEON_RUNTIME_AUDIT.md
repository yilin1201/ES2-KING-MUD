# ES2-KING Post-Neon Repository / Runtime Audit

> Audit baseline：`15e27c606886f1b96c2bbe5bda037989c767becb`  
> Branch：`build/original-es2-races-phase2`  
> Scope：正式 Runtime、部署入口、測試／里程碑保留檔與 Original Evidence 邊界。

## 結論

- `cleanup_nonking_test_accounts.sh` 已不存在；Repository 內沒有同名引用或 `start_es2_king_web.sh` cleanup hook。
- 未執行、也未新增任何玩家帳號清除機制；KING 保存路徑保持不變。
- 正式啟動鏈只有 `Dockerfile → start_es2_king_web.sh → prepare_es2_persistence.sh → Neolith + WebTelnet`。
- Persistence 只有一條有效實作：Neolith 寫入實體 `mudlib/data`，local backing 保留程序重啟相容性，Neon bridge 提供跨容器永久快照。
- 25 份已完成 Milestone Workflow 仍位於 `docs/archive/workflows/`，只保存歷史，不會被 GitHub Actions 自動執行。
- 舊 Race compatibility overlay 仍由 Docker build 與 Runtime assertion 直接引用，屬必要相容層，不是 orphan workaround。
- 未找到相同 Git blob SHA 的重複檔、已追蹤建置產物、秘密、臨時帳號資料或可安全刪除的 runtime orphan。

## 最終分類

| 分類 | 數量 | 判定 |
|---|---:|---|
| KEEP | 246 | Runtime、Source、Evidence、Canon、Deployment、Regression 或治理索引所需 |
| ARCHIVE | 25 | 已完成 Workflow 的歷史原文；不會自動觸發 |
| DELETE | 0 | 沒有同時滿足「Runtime 不需要、無引用、非 Evidence／History」的檔案 |
| UNKNOWN | 0 | 每份受管檔案均能由 Runtime、測試或治理用途判定 |

總計 271 份受管檔案。`docs/archive`、Original Source、Evidence、Canon 與研究資料均保留。

## 引用與 Dead Code 判定

| 檢查 | 結果 | 證據 |
|---|---|---|
| 帳號 cleanup 殘留 | PASS | Docker、active workflows、scripts 與 Web Runtime 的程式引用掃描為空；本 Audit 僅保留檔名作移除證據 |
| Runtime entrypoint | PASS | Docker `CMD` 唯一指向 `start_es2_king_web.sh` |
| Persistence duplication | PASS | prepare／sync 共用單一 `es2_neon_persistence.py` bridge |
| Active Workflow references | PASS | Active workflow 所引腳本均存在 |
| Archived Workflow isolation | PASS | 25 份檔案位於 `docs/archive/workflows`，不具 Actions 觸發效果 |
| Shell／Node／Python syntax | PASS | `bash -n`、`node --check`、Python compile gate |
| Broken repository references | PASS | Docker、active workflow 與 script-to-script 的直接路徑均存在 |

歷史 test gate 雖不在正式容器啟動鏈中，仍是可重現 Regression／Evidence gate，因此分類為 KEEP，不以「正式 runtime 未呼叫」誤判成 dead code。
