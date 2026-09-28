# Original ES2 Remaining Content Gap List

> Updated：2026-09-28  
> Scope：K Admin Runtime Validation 後的 Original Content Remaining Completion  
> Rule：Evidence First；已達 Evidence Exhausted 的項目不重搜同一批來源，UNKNOWN 不補造。

## Priority Matrix

| Priority | Item | Current Status | Missing Evidence | Runtime Impact | Recovery Source | Next Action |
|---|---|---|---|---|---|---|
| P0 | Quest Track A — Random Task Quest | SOURCE_REQUIRED / CORROBORATED_RUNTIME_CANDIDATE | 目標版本 quest daemon、派發 NPC、completion/reward 與正式欄位鏈 | 無法宣告目標 Original 隨機任務可玩 | 新的同版本 Original LPC／可證明 lineage archive | 取得直接 Source 前不移植外部 qlist 數值 |
| P1 | Snow 英雄帖 → Snowkeep | BROKEN / UNREACHABLE / EVIDENCE_EXHAUSTED | `/d/snowkeep/entrance` 及後續 Room／NPC／Quest chain | 歷史區域流程在缺檔位置中止；不阻斷核心 Snow | 只接受新的同版本 Snowkeep Source | Discover / Report；禁止建立推測 Room |
| P1 | Snow `try/fon` 殘鏈 | UNKNOWN / INCOMPLETE / EVIDENCE_EXHAUSTED | 遺失的狀態轉移呼叫端、completion、reward、save boundary | 阿寶／老太婆部分歷史對話無法完整閉環 | 新的目標版本 NPC／Room／command Source | 無新 Source 不重啟 Recovery |
| P1 | `__ID_CHALLIE__` object identity | UNKNOWN / EVIDENCE_EXHAUSTED | 原始物件 Source 與生成／使用鏈 | 無法確認歷史物件內容；不是 missing macro | 新的同版本 object LPC | 禁止新增 `#define` 或推測物件 |
| P1 | Taoist 玩家職業鏈 | SOURCE_REQUIRED | Target Original daemon、initialize／advance boundary、entry placement、Target recruitment protocol | 無合法 `Player→Entry→Class→Rank→Persistence` Journey | Target-compatible Taoist daemon＋entry/recruit LPC | 維持 rank compatibility；不得套用 Fighter 模式 |
| P1 | Bonze 玩家職業鏈 | EVIDENCE_EXHAUSTED | Target entry、daemon、trigger、rank／progress rules | 七職業內容仍不完整 | 新的同版本直接 Source | 無新 pointer 不重搜既有 family mirror |
| P1 | Soldier 玩家職業鏈 | EVIDENCE_EXHAUSTED | Player entry NPC、daemon、合法 set_class trigger | NPC identity 存在，但玩家職業不可閉環 | 新的同版本 Entry＋daemon LPC | 保留 NPC Evidence，不建立玩家入口 |
| P1 | Race initializer／Human-clan Original ID | PARTIAL / SOURCE_PENDING | Original race selection mapping、initialize、advance_level | 種族 compatibility 可玩，但歷史精確內容不完整 | Original race daemon／可靠歷史實機 | 新 Evidence 才更新；不把 `human_clan` 冒充 Original ID |
| P2 | Inventory 非 autoload 任意裝備保存 | UNKNOWN / PARTIAL | Original save policy 對 non-autoload equipment 的直接證據 | 已證明 money autoload；不能宣告所有裝備跨登入 | Original object autoload/save Source 或歷史 Runtime | 不新增泛用裝備保存規則 |
| P2 | 城隍 `register`／輪迴／轉生 | CONFIRMED_TEXT / SOURCE_REQUIRED | 城隍 NPC、command、Room path、旗標、費用、公式 | 死亡→鬼魂→寺廟 recovery 可玩；完整輪迴缺失 | 同版本 lifecycle LPC | 保持 UNKNOWN，不依文字反推公式 |
| P2 | `wine_pot` → `red_wine` | UNREACHABLE / BROKEN DEPENDENCY | 缺少 `/d/choyin/npc/obj/red_wine` 且 `wine_pot` 無 spawn reference | 非核心物件鏈不可達 | 新的同版本 object／spawn Source | 不建立紅酒替代物 |
| P2 | Original 冷梅莊 Room／NPC topology | SOURCE_REQUIRED / REFERENCE_ONLY | 可驗證 Room path、出口、NPC clone 與 Original NPC LPC | ES2-KING Arena 可玩；不得倒灌為 Original 世界 | Original／同 lineage 冷梅莊 Source | 武功凍結；只收直接 Evidence |
| P3 | blackteeth／yaksa 業力與刑天／形天 | CONFLICT / VERSION-CANON CONFLICT | 可鎖定版本的直接 Source | 不阻斷 Runtime；影響歷史精確值 | 版本可判定的 Original Source | 並列保存，不自行融合 |

## Closure Result

- K Admin／Wizard Runtime：`K_ADMIN_RUNTIME_PASS`、`K_HELP_RUNTIME_PASS`、`K_PERMISSION_REGRESSION_PASS`。
- Original Playability：維持 `PLAYABLE PASS`。
- Original Historical Content Completion：維持 `PARTIAL`。
- Remaining safe implementation：目前沒有新的 `CONFIRMED_SOURCE / RECONSTRUCTION_READY` gap 可直接進 Runtime。
- 下一步只有在取得上表新的直接 Source 後，才重開單一 Evidence-bounded Restoration。
