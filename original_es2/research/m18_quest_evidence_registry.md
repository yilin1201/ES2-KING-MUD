# M18 任務系統證據登錄表

## 證據分級

- `CONFIRMED_TEXT`（文字證據已確認）：歷史資料支持，但尚未取得完整實機程式鏈。
- `CONFIRMED_RUNTIME`（實機原始碼已確認）：已由乾淨 Original ES2 上游逐檔核對。
- `UNKNOWN`（未知）：證據不足，不補造。

## 系統盤點

| 項目 | 狀態 | 升級條件 |
|---|---|---|
| 任務主控／daemon | `UNKNOWN` | 找到實際 LPC 並確認其任務職責 |
| NPC 任務觸發 | `UNKNOWN` | 核對 NPC path、觸發條件與任務旗標 |
| 任務進度保存 | `UNKNOWN` | 找到玩家資料欄位／save 邏輯 |
| 任務完成判定 | `UNKNOWN` | 核對完整條件判斷 |
| 經驗／金錢／物品獎勵 | `UNKNOWN` | 找到與任務完成直接相連的獎勵程式 |

## 禁止事項

- 不以 ES2-KING Expansion（擴充設定）任務反推 Original。
- 不因檔名含 `quest` 就宣告它是完整任務系統。
- 不自行設定任務經驗值、掉落率、擊殺數或 NPC path。
