> [HISTORICAL CLOSURE / CURRENT STATUS SUPERSEDES]
> 本文件保存 M30 當時的結案矩陣與歷史判定；**不得用來代表目前 Public Acceptance 狀態**。目前狀態以 `docs/status/CURRENT_M30_STATUS.md` 為唯一入口。

# M30 ES2-KING Alpha Completion Matrix

Milestone IDs covered individually: M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12, M13, M14, M15, M16, M17, M18, M19, M20, M21, M22, M23, M24, M25, M26, M27, M28, M29, M30. Original ES2 and ES2-KING Expansion remain permanently separated.

| Milestone | 功能 | Original 保留內容 | Expansion 內容 | Static Gate | Runtime Gate | Regression | 狀態 |
|---|---|---|---|---|---|---|---|
| M1 | 保存區／分層 | Original source manifest | Expansion 目錄 | repository boundary | bootstrap | roadmap | PASS |
| M2 | Driver／Mudlib | Neolith + Original mudlib | 無 | driver workflow | boot | M2 result | PASS |
| M3 | Bootstrap | 乾淨執行樹 | overlay 不混入 | bootstrap script | boot | persistence | PASS |
| M4 | Persistence | 帳號／角色 Save-Load | 無 | data paths | relogin | M4 result | PASS |
| M5 | 證據框架 | historical registry | Canon labels | evidence tests | N/A | source manifest | PASS |
| M6-M9 | 種族與回歸 | 11 種族、Human／Avatar 基準 | 不覆蓋 Original | race tests | race runtime | phase2 regression | PASS |
| M10 | 種族 baseline | 11-row TSV | 無 | baseline test | login acceptance | race regression | PASS |
| M11 | 職業／門派 | class and school interface | 無 | class tests | class runtime | class regression | PASS |
| M12 | Skill／Study | skill cap 200、研讀公式 | 無 | skill/study tests | study runtime | gameplay regression | PASS |
| M13 | Force／Exert | Original force mapping | 無 | force tests | force runtime | combat regression | PASS |
| M14 | 師徒 | apprentice relation | 無 | apprentice tests | apprentice runtime | relation regression | PASS |
| M15 | 冷梅莊 | Original NPC／武學證據 | 無 | Lengmei tests | Lengmei runtime | NPC regression | PASS |
| M16 | NPC／物品 | Original paths and interfaces | 無 | NPC/item tests | load runtime | item regression | PASS |
| M17 | 世界／房間 | Original exits and rooms | 無 | world tests | movement | world regression | PASS |
| M18 | 任務 | evidence boundary; incomplete chain UNKNOWN | 無 | quest tests | available runtime | quest regression | PASS／UNKNOWN 保留 |
| M19 | 生命週期 | death/revive/experience | 無 | lifecycle tests | lifecycle runtime | save regression | PASS |
| M20 | Original Alpha | Original playable baseline | 無 | alpha static | alpha runtime | M1-M19 | PASS |
| M21 | 世界完整化 | evidence-backed world | 無 | world static | world runtime | M20 regression | PASS |
| M22 | NPC／裝備 | evidence-backed NPC/items | 無 | NPC static | NPC runtime | M21 regression | PASS |
| M23 | 核心玩法 | class→apprentice→skill→combat | 無 | core static | core runtime | gameplay | PASS |
| M24 | 資料完整性 | save/load/death/economy | 無 | integrity static | integrity runtime | data | PASS |
| M25 | Release Candidate | Original封版基準 | 無 | RC static | real Driver journey | M21-M24 | PASS／Actions blocked |
| M26 | KING 管理員 | Original security reused | allowlisted creation | admin static | admin Driver | security | PASS |
| M27 | 無極之境 | `/d/snow/square` unchanged | admin room + down | realm static | realm Driver | M26 | PASS |
| M28 | 易筋經／霸天 | Original skill cap unchanged | 300 progression + 兆／極 | martial static | martial Driver | M26-M27 | PASS |
| M29 | 渾天／如來 | Original skill/combat unchanged | 10 layers, 11 forms, 11 weapons, 4 turns | Canon static | Canon Driver | M28 | PASS |
| M30 | Alpha integration | all Original baselines retained | M26-M29 overlay integrated | this matrix + scan | full smoke | full regression | PASS／ACTIONS-INFRA-BLOCKED |

## Gaps and limits／缺口與限制

- M18 任務完整歷史鏈仍為 `UNKNOWN`；已有可證明的 Runtime 介面不等同完整歷史內容。
- M28／M29 未定義的傷害、命中、消耗、冷卻與絕對效果仍為 `UNKNOWN`。
- GitHub Actions Runner 因免費額度／US$0 Spending Budget 受阻，所有本機結果不得改稱 Actions PASS；標記 `ACTIONS-INFRA-BLOCKED`。
- 本矩陣不把文件存在誤當成程式功能；Alpha Gate 另檢查實際 Expansion 原始碼、Original 核心檔及 Driver Smoke 證據。
