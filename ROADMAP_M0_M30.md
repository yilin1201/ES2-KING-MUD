# ES2-KING M0～M30 正式 Roadmap

> **[PROJECT-CANON / ROADMAP-LOCKED]**
>
> 本文件為 ES2-KING-MUD 正式 M0～M30 開發路線。後續開發、ChatGPT Work 與 GitHub Actions（GitHub 自動測試流程）均以本文件為 Roadmap 基準。
>
> 核心原則：`preserve → understand → rebuild → expand`（保存 → 理解 → 重建 → 擴充）。Original ES2 與 ES2-KING Expansion 永久分離。Original ES2 找不到可靠證據時標記 `UNKNOWN`（未知），不得以推測補造。

## 固定開發規則

1. PR #13 保持 Open，**禁止 Merge（合併）**，除非專案擁有者日後明確改變指令。
2. 每個 Milestone（里程碑）依序執行：研究／證據核對 → 實作 → Commit（提交版本）→ Push（推送）→ GitHub Actions → PASS（測試通過）後進下一階段。
3. FAIL（測試失敗）時直接讀取 Log（測試紀錄）→ 分析 → 修正 → Commit → Push → 重測，不因一般技術錯誤停下詢問。
4. 只有 Original ES2 史實衝突、重大 Canon（正式設定）衝突、大量不可逆刪除、Merge 或其他重大不可逆決策才需要人工確認。
5. 遵守 ES2-CN：新增／修改的英文、英文縮寫與程式技術名詞第一次出現時附繁體中文名稱與白話用途；重要程式邏輯加入繁體中文註解。Original ES2 保存原始碼不得只為增加註解而修改。
6. GitHub 實際程式、測試與最新 Head（分支最前端版本）優先於舊聊天中的過期進度百分比。

## M0～M20：Original ES2 重建主線

| Milestone | 核心目標 | 正式定位 |
|---|---|---|
| M0 | 專案初始化、GitHub 架構 | 基礎 |
| M1 | Original ES2 保存區與 Expansion 分離 | 基礎 |
| M2 | Driver／Mudlib 基礎環境 | 基礎 |
| M3 | Bootstrap（建立乾淨 Original 執行樹） | 基礎 |
| M4 | Runtime／Persistence（實機執行／資料持久化）基礎 | 基礎 |
| M5 | Original ES2 歷史資料與證據框架 | Original |
| M6 | 第一階段種族資料 | Original |
| M7 | 種族屬性／能力 | Original |
| M8 | 種族 Runtime（實機執行）驗證 | Original |
| M9 | 種族 Regression Test（回歸測試，確認修改未破壞既有功能） | Original |
| M10 | Original ES2 種族完整 Baseline（基準線） | Original |
| M11 | 七大職業：武者、軍人、書生、道士、小偷、方士、和尚 | Original |
| M12 | Skill／Study（技能／研讀）系統 | Original |
| M13 | 武學／內功正式 Runtime | Original |
| M14 | 師徒／拜師／門派 Runtime | Original |
| M15 | 冷梅莊／梅影風證據與 Runtime Gate（實機證據閘門） | Original |
| M16 | NPC／裝備／物品 Runtime | Original |
| M17 | 世界／區域／房間／出口 Runtime | Original |
| M18 | Quest／任務 Runtime | Original |
| M19 | 死亡／復活／經驗／角色成長 | Original |
| M20 | **Original ES2 Alpha（第一個整體可玩測試版本）** | 第一大型驗收點 |

## M21～M25：Original ES2 完整化

M21～M25 的階段邊界正式固定為 Original ES2 完整化，不得導入 ES2-KING Expansion 設定。

### M21 — 世界內容完整化

完成 Original ES2 可考證的區域、城鎮、房間與移動網路。逐區建立 Evidence Registry（證據登錄表）、Runtime Gate 與 Regression Test；缺乏可靠 Original 證據的地圖保持 `UNKNOWN`。

### M22 — 角色／NPC／裝備／物品完整化

完成可考證 NPC（Non-Player Character，非玩家角色）、師父、怪物、商人、裝備與物品內容，核對出現位置、載入關係與可證明屬性；未知 HP、技能等級、掉落率與 path（程式路徑）不得補造。

### M23 — 核心玩法完整化

整合職業、門派、武學、內功、研讀、拜師、任務、戰鬥與角色成長，使 Original ES2 主要玩法形成完整可運作循環；跨系統行為必須加入 Regression Test。

### M24 — 系統整合與資料完整性

完成 Save／Load（存檔／讀檔）、Persistence、死亡／復活、經驗、經濟、掉落與跨系統資料一致性；建立長流程整合測試，確認重新登入、死亡、成長、取得物品與任務進度不破壞資料。

### M25 — Original ES2 Release Candidate

建立 Original ES2 Release Candidate（候選完整版本）：執行全系統 Runtime Gate、Regression Test、Driver Build（遊戲驅動程式建置）與整合驗收。M25 是 Original ES2 的封版基準；任何仍無可靠歷史證據的項目保持 `UNKNOWN`，不得為了達成完成率而虛構。

## M26～M30：ES2-KING Expansion

只有在 Original ES2 完整化基準建立後才進入本階段。Expansion 內容必須位於明確獨立的資料／程式層，不得反寫污染 Original ES2 證據。

### M26 — KING 管理員／創世系統

將既有 KING 管理員與創世概念 Runtime 化，包含管理權限、創世操作與相關安全邊界；沿用已確認 ES2-KING Canon，不自行創造衝突設定。

### M27 — 天神殿・無極之境

實作既有 ES2-KING Canon 的天神殿／無極之境內容與相關世界、NPC、試煉及系統連接；保持與 Original 世界層可識別分離。

### M28 — 易筋經＋霸天煉體訣

實作既有 ES2-KING Canon 的頂級內功／煉體系統。易筋經沿用既定七大境界與 Lv.300 MAX「黑級無極境」等正式設定；不得回寫成 Original ES2 武學。

### M29 — 渾天寶鑑＋如來神掌／十方佛兵

實作既有 ES2-KING Canon 的渾天寶鑑、如來神掌、十方佛兵及已確認的隱藏／終極內容，建立技能成長、戰鬥 Runtime 與 Regression Test；Expansion Canon 與 Original 證據永久分層。

### M30 — ES2-KING Alpha

整合已封版的 Original ES2 基準與 M26～M29 Expansion，建立 **ES2-KING Alpha（ES2-KING 第一個整體可玩測試版本）**。執行全專案 Driver Build、Runtime、Regression、資料邊界與整合驗收。

## 三大正式 Gate

- **M20：Original ES2 Alpha** — Original ES2 已形成整體可玩版本。
- **M25：Original ES2 Release Candidate** — Original ES2 完整化、穩定化並建立封版基準。
- **M30：ES2-KING Alpha** — Original ES2 + ES2-KING Expansion 完成第一階段整合可玩版本。

## Roadmap 變更規則

M21～M25 的「Original 完整化」與 M26～M30 的「ES2-KING Expansion」邊界，以及 M26～M30 上述核心主題，視為正式鎖定。一般開發可新增子任務、測試與證據文件，但不得自行重新命名或跨階段搬移核心 Milestone。若未來需要改變上述正式結構，必須由專案擁有者明確批准。
