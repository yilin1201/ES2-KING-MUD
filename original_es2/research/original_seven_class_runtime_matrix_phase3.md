# Original ES2 七職業 Runtime Matrix — Phase 3

> Audit Date：2026-09-27  
> 目標版本：taedlar／Neolith upstream `cc45c06af4852380e5148dad3c9d53ff06854f2c`，並交叉檢查其全部可達 Git history。  
> 原則：只有同版本 Source 或已完成的隔離真 Driver Journey 能提升 Runtime；外部 ES2 family Source 只作 lineage 線索。

## 1. 結論

歷史資料所稱「七職業」是 `fighter`、`soldier`、`scholar`、`taoist`、`thief`、`alchemist`、`bonze`；`commoner` 是角色建立時的預設基礎職業，因此本表共列八列。

目標版本目前只保存 `daemon/class/commoner.c` 與 `daemon/class/fighter.c`。全 Git history 中，class daemon 也只有：

- `55b67a64834d6d98e69c6eef3660a209e8259665`：新增 `commoner.c`；
- `7b7cf42220928d0fe83b7e98cc0b076ced627860`：新增 `fighter.c`；
- `3b2aa2e7b8edee55bf28dccaaf66b6b5277e7f74`：只移動 `commoner.c` 文件。

沒有可達 commit 保存 scholar／taoist／thief／alchemist／bonze／soldier 的目標版本 class daemon。此為 negative evidence（否定性證據），只證明「目前保存範圍內未找到」，不代表這些 Original 內容從未存在。

## 2. Runtime Matrix

| Class ID | 中文名 | Original Source | Class Daemon | Entry NPC / Apprentice Path | `set_class` Trigger | `query_rank` | `initialize` | `advance_level` | Skill Mapping | Equipment Restriction | Persistence | Runtime Journey | Evidence Grade | Current Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `commoner` | 平民 | `logind.c` 建角預設；`commoner.c` | 目標 Original `commoner.c` | 建角／`CHAR_D` 預設，非師父路線 | `init_new_body()` 與 `setup_char()` | Original 回傳「平民」 | daemon 未定義；`DAEMON_D` fallback 空呼叫 | daemon 未定義 | UNKNOWN | UNKNOWN | 一般玩家 dbase save／restore | M31 隔離角色確認 rank，並作 alchemist chain 起點 | CONFIRMED_RUNTIME | CONFIRMED_RUNTIME |
| `fighter` | 武者 | Target `fighter.c`＋Historical mudchina guild `join` | 目標 Original `fighter.c` | `[ES2-KING Reconstruction]` 隔離武者同盟入口；不宣稱 Target Waterfog topology | Historical `join` 適配為 Target `set_class("fighter")` | Original 回傳「武者」 | daemon 未定義；未補造 | daemon 未定義；未補造 | UNKNOWN | UNKNOWN | 真 Driver save／quit／relogin 已確認 | `ORIGINAL_FIGHTER_CLASS_RUNTIME_PASS` | RECONSTRUCTION | RECONSTRUCTION_RUNTIME_PASS |
| `alchemist` | 方士 | Snow 陳維俠 NPC；`who -at` | RECONSTRUCTION：只有 `[ES2-KING Reconstruction]` rank compatibility | 陳維俠；兩段 apprentice confirmation | Original NPC 直接 `set_class("alchemist")` | Reconstruction 回傳「方士」 | UNKNOWN | UNKNOWN | 陳維俠可教授的部分技能由目標 Source 保存；不等同完整 class mapping | UNKNOWN | 真 Driver save／quit／relogin 已確認 | `M31_CLASS_RUNTIME_PASS` | CONFIRMED_RUNTIME | CONFIRMED_RUNTIME |
| `scholar` | 書生 | Snow 王懷芝 NPC；`who -sc` | 目標 daemon 未保存 | 私塾 `sit`／literate 前置／回答 | Original NPC 直接 `set_class("scholar")` | SOURCE_REQUIRED | UNKNOWN | UNKNOWN | 只確認私塾 literate progress；外部 scholar school 不倒灌 | UNKNOWN | 真 Driver save／quit／relogin 已確認 | `ORIGINAL_SCHOLAR_RUNTIME_PASS`（BOUNDED） | CONFIRMED_RUNTIME | CONFIRMED_RUNTIME |
| `thief` | 盜賊／小偷 | Snow 阿寶→瞎眼老太婆；`who -tf`；其他 Original NPC ID | 目標 daemon 未保存 | food→comb→gammer→口令 | Original NPC 直接 `set_class("thief")` | SOURCE_REQUIRED | UNKNOWN | UNKNOWN | 目標鏈直接保存 sneak／stealing learning progress | UNKNOWN | 真 Driver save／quit／relogin 已確認 | `ORIGINAL_THIEF_PROGRESSION_RUNTIME_PASS` | CONFIRMED_RUNTIME | CONFIRMED_RUNTIME |
| `taoist` | 道士 | `who -tt`；歷史 Help／七職業資料 | RECONSTRUCTION：只有 `[ES2-KING Reconstruction]` rank compatibility | 目標 Entry NPC／拜師路線未保存 | 目標 tree/history 無玩家 trigger | Reconstruction 回傳「道士」 | UNKNOWN | UNKNOWN | Help 只作 Evidence；禁止建立 Runtime skill | UNKNOWN | 無合法玩家 entry 可驗證 | 無；不得把 rank compatibility 當 Journey | ARCHIVED_SOURCE | SOURCE_REQUIRED |
| `bonze` | 僧侶／和尚 | 歷史七職業資料、legacy 設計文字 | 目標 daemon 未保存 | 外部 family 有出家／剃度鏈，但不是目標同版本 | 目標 tree/history 無 trigger | SOURCE_REQUIRED | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | 無目標角色狀態可驗證 | 無 | ARCHIVED_SOURCE | EVIDENCE_EXHAUSTED |
| `soldier` | 軍人 | `who -sr`；黑白無常 NPC 使用 ID；`feature/npc/soldier.c` | 目標 daemon 未保存 | 只找到 NPC soldier 行為，沒有玩家 Entry NPC | 只找到 NPC `set_class("soldier")` | SOURCE_REQUIRED | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | 架構可保存 class，但無玩家 entry proof | 無完整 Player→NPC→set_class Journey | CONFIRMED_SOURCE | EVIDENCE_EXHAUSTED |

## 3. Call-chain 與 callback 邊界

目標 `feature/char/score.c` 證明：

`set_class()` → `CLASS_D(class)->initialize()`  
`gain_score()` → `CLASS_D(class)->advance_level()`

但 `adm/daemons/daemond.c` 在 class daemon 缺檔時回傳自身；未定義 callback 會成為空呼叫。這可解釋 scholar／thief 為何仍能保存 class ID，但**不等於遺失的 class 公式已恢復**。

## 4. Source cross-check

| 來源 | 結果 | 可用邊界 |
|---|---|---|
| Current ES2-KING／pinned target tree | 兩個 Original daemon；三條目標 player transition：alchemist、scholar、thief | CONFIRMED_SOURCE／CONFIRMED_RUNTIME |
| Target upstream Git history／all refs | 未找到其他 class daemon；未找到玩家 `set_class("taoist")`／`set_class("bonze")`／`set_class("soldier")` | EVIDENCE_EXHAUSTED（目前保存範圍） |
| Existing Original archive／legacy docs | 保存七職業名稱、ID、門派，以及 bonze／taoist 設計文字 | ARCHIVED_SOURCE；不可當可執行 LPC |
| es2.xor.tw MUDLIB／Tips | 保存 Snow Source 索引、七職業／師父／Help 歷史；未取得缺失的同版本 daemon／entry LPC | ARCHIVED_SOURCE／SOURCE_REQUIRED |
| mudchina/es2、MudRen ES2-big5／ES2-utf8 | 保存 bonze／taoist／scholar 等另一 ES2 family 的 master／area／skill Source | CORROBORATED；API、地圖與 class 結構不同，不直接倒入目標 Runtime |
| 公開精確檔名搜尋 | 未找到 es2.xor.tw 可索引的 soldier／bonze／taoist class daemon | 不以搜尋無結果證明「從未存在」 |
| Fighter R4 Historical Reconstruction | mudchina guild `join→fighter` 轉譯為 Target `set_class("fighter")`，沿用 Original fighter daemon | RECONSTRUCTION_RUNTIME_PASS；未接 Target 正式地圖 |

## 5. Quest Track boundary

- **Track A — Random Task Quest**：外部 qlist／朱鴻雪鏈仍是 `CORROBORATED`；目標 branch 沒有可執行 daemon／NPC／completion chain，狀態 `SOURCE_REQUIRED`。
- **Track B — Story / Area Quest**：目標 Snow thief、貨棧工錢、私塾 scholar 三條既有 Runtime chain 保持 `CONFIRMED_RUNTIME`。本輪沒有找到新的同版本完整鏈，不新增 Quest Runtime。
- Snowkeep、`try/fon`、`__ID_CHALLIE__` 沒有新直接 Source，依既定結論維持 `EVIDENCE_EXHAUSTED / UNKNOWN`，不重新 Recovery。

## 6. Continuous execution decision

Fighter 已由 R4 `RECONSTRUCTION_READY` 提升為 `RECONSTRUCTION_RUNTIME_PASS`。尚未 Runtime 閉環的 taoist、bonze、soldier 仍缺少可安全轉譯的完整證據鏈；Quest Track A 仍是外部 family candidate，Track B 的目標 Snow 可閉合鏈均已驗證。

因此除 Fighter 已核准 adapter 外，不建立新 daemon、不新增 initialize／advance_level／屬性／HP／技能／裝備限制，也不把外部 family Source 拼成目標 Canon。下一個安全動作是取得 Taoist／Bonze／Soldier 任一項新的決定性 Target-compatible Source 後，再重開單一 Runtime Journey。
