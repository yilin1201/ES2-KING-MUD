# ES2-KING 文件治理與狀態校正規範

> [PROJECT-DOC-CANON]  
> 建立日期：2026-09-19  
> 目的：避免歷史報告、舊驗收狀態與目前 Runtime 狀態互相覆蓋，並降低重複測試。

## 1. 文件只分四種

| 類型 | 定義 | 可否代表「目前狀態」 |
|---|---|---|
| CURRENT | 現行狀態與目前工作入口 | 是 |
| CANON | 正式規範、Roadmap、證據規則 | 是，但不是即時測試結果 |
| EVIDENCE | Original ES2 證據、研究、來源登錄 | 只代表證據 |
| HISTORICAL | 過去某次 Runtime／測試／部署結果 | 否 |

## 2. 目前唯一 Current Status

目前即時狀態統一以：
`docs/status/CURRENT_M30_STATUS.md`

為 Owner 與後續開發工具的第一入口。

舊的 `M30_ALPHA_FINAL_AUDIT.md`、`M30_PLAYABLE_ALPHA_ENTRY.md`、`M30_DEPLOYMENT_READINESS.md` 保留作歷史證據，不再單獨用來判斷「現在是否完成」。

## 3. 去重原則

1. 不刪除 Original ES2 證據。
2. 不因內容相似就合併 Evidence Registry。
3. Runtime Result 是「當時測試結果」，不複製成 Canon。
4. 同一狀態只在 CURRENT 文件維護一次；其他文件以連結引用。
5. 過時文件先標記 Historical，不立即大量搬路徑，以免破壞 Script／Workflow 引用。
6. M30 Public Acceptance 完成後，再執行實體路徑重構。

## 4. 建議閱讀順序

`README.md`
→ `docs/status/CURRENT_M30_STATUS.md`
→ `ROADMAP_M0_M30.md`
→ `docs/ES2_KING_REPOSITORY_GUIDE_ZH_TW.md`
→ 任務相關 Original / Expansion 文件。

## 5. 測試去重

小型修正只執行直接相關的最小測試。已經由 Owner Public Device 驗收 PASS 的 Claim Token、Password、Email，不因其他 UI 小修正重跑。全套 Regression 只保留給正式 Gate／封版驗收。
