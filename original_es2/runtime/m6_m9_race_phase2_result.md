# Original ES2 M6–M9 歷史種族第二階段驗證結果

## 結論

**PASS／通過。** GitHub Actions Run #25（Run ID `35039712208`）已在實際 Neolith + Original ES2 Mudlib Runtime 完成歷史種族第二階段驗證。

> 本文件記錄的是 ES2-KING 重建層與 Runtime 驗證結果，不代表已考證出 Original ES2 遺失的歷史種族原始屬性公式。

## 驗證範圍

- Static Verification／靜態驗證：歷史種族設定、八項屬性欄位與暫定數值存在。
- Runtime Overlay／執行環境覆蓋層：保留 Original Human、Avatar，新增遺失的歷史種族重建 Daemon（常駐系統物件）。
- Login Registry／登入種族清單：歷史種族可在建立角色流程中被選取。
- Race Acceptance／種族接受邏輯：`get_race()` 實際接受歷史種族，不會選完後退回選單。
- Live Character Creation／真實角色建立：透過 Telnet（文字連線協定）走完整玩家建立流程。
- Combat／戰鬥：使用 Original ES2 `fight` 指令與 Runtime-only 木樁武者產生實際戰鬥交換。
- Persistence／資料保存：`quit` 後重新登入，種族、出生屬性與精氣神最大值仍正確保存。
- Regression Test／回歸測試：保護已完成的 Human M2 與 Avatar M5 基準。

## 實際 Runtime 通過種族

| 種族 ID | 中文名稱 | ES2-KING 暫定八項出生屬性 | Live | Combat | Persistence |
|---|---|---:|---|---|---|
| blackteeth | 黑齒 | 25 | PASS | PASS | PASS |
| yenhold | 厭火 | 25 | PASS | PASS | PASS |
| woochan | 無腸 | 25 | PASS | PASS | PASS |
| dingling | 釘靈 | 25 | PASS | PASS | PASS |
| jiaojao | 焦僥 | 25 | PASS | PASS | PASS |
| rainnar | 雨師妾 | 50 | PASS | PASS | PASS |
| ashura | 阿修羅 | 50 | PASS | PASS | PASS |
| headless | 形天 | 50 | PASS | PASS | PASS |
| yaksa | 夜叉 | 50 | PASS | PASS | PASS |
| malik | 巫首 | 25 | PASS | PASS | PASS |

八項屬性依 ES2-KING 現行對應：`str` 臂力、`cps` 膽識、`int` 悟性、`spi` 靈性、`cor` 定力、`dex` 機敏、`con` 根骨、`wis` 慧根。

## Original 保護

- Human：仍使用 Original `13 + random(6)` 出生屬性邏輯，不套用歷史種族暫定 25/50。
- Avatar：仍使用 Original 種族程式，不由歷史種族 Runtime overlay 重新產生。
- Repository（程式庫）保存的 Original ES2 原始碼不因本階段加入中文註解或歷史種族重建而被竄改；變更放在 ES2-KING 重建層、測試與 Runtime overlay。

## 數值證據標記

`headless`、`yaksa`、`ashura`、`rainnar` 的八項出生屬性 = 50，以及其他重建歷史種族 = 25，均屬 **[ES2-KING Design] 暫定值**。在找到可信 Original ES2 原始公式前，不應標示為 Original 數值。

## GitHub Actions 證據

Run #25 / Run ID `35039712208`：Static、Runtime overlay、Human/Avatar Regression、Neolith Build、MUD Boot、10 個歷史種族 Live + Combat + Persistence 全部 PASS。

下一階段可在此基礎上進入 Original 歷史種族收尾與職業／技能系統重建；在使用者明確授權前，本階段不得 Merge 到 `main`。
