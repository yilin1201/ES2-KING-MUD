# Original ES2 Remaining Content Gap List

> Updated：2026-09-29  
> Scope：K Admin Runtime Validation 後的 Original Content Remaining Completion  
> Rule：Evidence First；已達 Evidence Exhausted 的項目不重搜同一批來源，UNKNOWN 不補造。

## Priority Matrix

| Priority | Item | Current Status | Missing Evidence | Runtime Impact | Recovery Source | Next Action |
|---|---|---|---|---|---|---|
| P0 | Quest Track A — Random Task Quest | PARTIAL / SOURCE_REQUIRED | 目標版本 quest daemon、派發 NPC、completion/reward 與正式欄位鏈 | `doc/wiz/quest` 只確認 Story／Area Quest 設計模型；無法宣告 Random Task Quest 可玩 | 新的同版本 Original LPC／可證明 lineage archive | 取得直接 Source 前不移植外部 qlist 數值；不得把 Story Quest 文件當 Random Task daemon |
| P1 | Snow 英雄帖 → Snowkeep | PARTIAL / CONFIRMED_SOURCE / UNREACHABLE | `/d/snowkeep/entrance` 及後續 Room／NPC／Quest chain | `girl.c` 產出英雄帖，`guard.c` 收帖並移動玩家，`ebridge.c` 亦直連缺失入口；目的區域仍不可達 | `es2.xor.tw` Original Source 已閉合 invitation 前置鏈；仍需同版本 Snowkeep LPC | 保留已確認觸發鏈；禁止建立推測 Room |
| P1 | Taoist 玩家職業鏈 | PARTIAL / SOURCE_REQUIRED | Target Original daemon、initialize／advance boundary、entry placement、Target recruitment protocol | `es2.xor.tw/doc/wiz/taoist-plan` 與 `taoism-spells` 確認職業／技能規劃；MANIFEST 無 class daemon／entry LPC | Target-compatible Taoist daemon＋entry/recruit LPC | 維持 rank compatibility；Original 文件不足以建立 Runtime，不得套用 Fighter 模式 |
| P1 | Bonze 玩家職業鏈 | PARTIAL / SOURCE_REQUIRED | Target entry、daemon、trigger、rank／progress rules | `doc/wiz/bonze` 與 Legacy 山煙寺資料確認設計／師父技能，但無 Target player-class LPC | 新的同版本 Entry＋daemon LPC | Legacy／聊天紀錄只作 corroboration，不建立玩家入口 |
| P1 | Soldier 玩家職業鏈 | PARTIAL / SOURCE_REQUIRED | Player entry NPC、daemon、合法 set_class trigger | Original `feature/npc/soldier.c` 與官兵 NPC 已確認，但屬 NPC 行為；玩家職業不可閉環 | 新的同版本 Player Entry＋class daemon LPC | 保留 NPC Evidence，不把 `F_SOLDIER` 冒充 player class |
| P1 | Race initializer／Human-clan Original ID | CONFIRMED_SOURCE / DEPENDENCY_CLOSED（Human＋Avatar）；PARTIAL / SOURCE_REQUIRED（其餘） | Human／Avatar 以外種族各自 daemon／initialize／advance_level 仍須逐種族 Source | Target `who.c` 確認九個歷史 race ID；`steal.c`／`combatd.c`／`teacher.c` 保存 jiaojao、rainnar、ashura 等局部行為，但不含 birth formula | Target pinned race references；仍需各 `daemon/race/<id>.c` | Human／Avatar 不重做；其餘只保留直接行為片段，不把 temporary baseline 當 Original |
| P2 | 城隍 `register`／輪迴／轉生 | CONFIRMED_SOURCE / SOURCE_REQUIRED / CONFLICT | 城隍 NPC、command、Room path、旗標、費用、公式 | Target `chard.c → LOGIN_D->reincarnate()` 已確認 body recreation／race reselection；城隍 world entry 缺失 | 同版本 lifecycle LPC；外部 family death-world 只作 conflict cross-check | 不拼接外部「解除 ghost＋恢復 stats」API；等待 Target-compatible 城隍 entry Source |
| P2 | `wine_pot` → `red_wine` | CONFIRMED_SOURCE / BROKEN DEPENDENCY | `wine_pot.c` 已直接 spawn `/d/choyin/npc/obj/red_wine`；真正缺少的是該 object LPC | 大酒缸載入時會呼叫缺失 object，非核心飲酒物件鏈不完整 | Target tree/history 與兩個 family mirror 均無 `red_wine.c`；仍需同版本 object Source | 保留已確認 spawn／volume 行為，不建立紅酒替代物 |
| P2 | Original 冷梅莊 Room／NPC topology | SOURCE_REQUIRED / REFERENCE_ONLY | 可驗證 Room path、出口、NPC clone 與 Original NPC LPC | ES2-KING Arena 可玩；不得倒灌為 Original 世界 | Original／同 lineage 冷梅莊 Source | 武功凍結；只收直接 Evidence |
| P3 | blackteeth／yaksa 業力與刑天／形天 | CONFLICT / VERSION-CANON CONFLICT | 可鎖定版本的直接 Source | 不阻斷 Runtime；影響歷史精確值 | 版本可判定的 Original Source | 並列保存，不自行融合 |

## Closure Result

- K Admin／Wizard Runtime：`K_ADMIN_RUNTIME_PASS`、`K_HELP_RUNTIME_PASS`、`K_PERMISSION_REGRESSION_PASS`。
- Original Playability：維持 `PLAYABLE PASS`。
- Original Historical Content Completion：維持 `PARTIAL`。
- Remaining safe implementation：目前沒有新的 `CONFIRMED_SOURCE / RECONSTRUCTION_READY` gap 可直接進 Runtime。
- 下一步只有在取得上表新的直接 Source 後，才重開單一 Evidence-bounded Restoration。

## Closed / Exhausted Items（非活動待辦）

| Item | Final boundary | Reason removed from active gap |
|---|---|---|
| Snow `try/fon` 殘鏈 | UNKNOWN / EVIDENCE_EXHAUSTED | Repository、History、Archive 與公開精準搜尋均未取得狀態轉移／completion Source；無新直接 Source 不重搜 |
| `__ID_CHALLIE__` | UNKNOWN / EVIDENCE_EXHAUSTED | 已證明不是可硬補的 missing macro；缺原物件 LPC 與生成／使用鏈 |
| Inventory 非 autoload 裝備保存 | CONFIRMED / N/A | Original 已確認採 autoload opt-in；「任意裝備通用保存」不是待實作功能 |

實作交接與精確缺檔清單集中於 `original_content_implementation_packages.md`；本節保留歷史結論，但不再把已耗盡或 N/A 項目當成可執行 Pending。
