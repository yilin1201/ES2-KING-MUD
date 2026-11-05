# M11–M25 Runtime Gate Semantics Audit（實機閘門語意稽核）

> 第五階段 5T。目的：區分「真正核對指定 Source 行為的 PASS」與「只做關鍵字探索的 Candidate」，避免歷史狀態被假 PASS 污染。

| Gate | Type | Current semantic verdict |
|---|---|---|
| M16 NPC/Item | discovery search | 已修正：UNKNOWN / CANDIDATE，不可 PASS |
| M17 World | discovery search | 已修正：UNKNOWN / CANDIDATE，不可 PASS |
| M18 Quest | discovery search | 已修正：UNKNOWN / CANDIDATE，不可 PASS |
| M19 Lifecycle | exact source assertions | PASS 可保留；直接核對 char/temple/user 函式與呼叫 |
| M21 World | exact source assertions | PASS 可保留；鎖定 snow tree、檔案數與代表性 exits |
| M22 NPC/Item | exact source assertions | PASS 可保留；鎖定 NPC/obj 數量、inherit、room clone |
| M23 Core Gameplay | exact source assertions | PASS 可保留；鎖定 Class→Apprentice→Skill→Study/Enable→Combat 介面 |
| M24 Data Integrity | exact source assertions | PASS 可保留；鎖定 save/restore/death/score/economy/item protection |
| M25 Release Candidate | interface readiness assertions | PASS 只能解讀為「RC 所需介面存在」，不能單獨代表 Public E2E 驗收 |

## PASS 使用規則

1. Discovery Search（探索搜尋）不得使用 PASS；只能 UNKNOWN/CANDIDATE。
2. Exact Source Assertion（指定原始碼斷言）可以 PASS，但 PASS 範圍只等於腳本實際檢查內容。
3. Interface PASS 不等於 Public Device E2E PASS（公開裝置端到端驗收）。
4. Milestone PASS 必須由該 milestone 定義的所有必要 Gate 組合判定，不可引用單一腳本擴大結論。

## Audit result

M16/M17/M18 是本輪確認的 discovery gate 語意風險，現已全部校正。M19/M21/M22/M23/M24 為直接 Source assertion，不需為了統一文字而降級。M25 保留 PASS，但在文件治理上限定為 RC interface readiness，避免與 M30 Public Acceptance 混用。
