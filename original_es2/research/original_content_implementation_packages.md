# Original ES2 Content Implementation Packages

> 目的：把已確認依賴與真正缺失 Source 分開，讓取得新 LPC 後能立即做最小 Restoration。本文不建立 Runtime Canon，也不把 Static PASS 當成 Runtime PASS。

## Human Original Runtime Fixture

- **Confirmed**：`logind.c::get_race()` 接受 `human`，`get_gender()` 寫入 race，`init_new_body()` 設為 `commoner`／Lv.1，再呼叫 `CHAR_D->setup_char()`。
- **Dependency closed**：`chard.c` 依序呼叫 `RACE_D(query_race())->setup()` 與 `CLASS_D(query_class())->setup()`。
- **Original values**：karma 5；八屬性各為 `13 + random(6)`；gin／kee／sen 各 30；natural armor 3。
- **Static fixture**：`scripts/test_original_human_runtime_fixture_static.sh`。
- **Runtime handoff**：隔離新角色創建後讀取 race／class／level／八屬性／精氣神／armor，再 save→quit→relogin 驗證；Work 不重跑完整 Journey。

## Snowkeep Implementation Package

| 類別 | 已確認 | 缺失／邊界 |
|---|---|---|
| Entry path | `d/snow/npc/girl.c` 產生 `npc/obj/invitation.c`；`guard.c::accept_object()` 接受 invitation 後移動至 `/d/snowkeep/entrance` | `/d/snowkeep/entrance.c` 與後續區域 LPC 未保存 |
| Exit path | `d/snow/ebridge.c` 保存指向 `/d/snowkeep/entrance` 的註解出口 | 不得在缺 Source 時啟用或推造出口 |
| NPC / Object | girl、guard、invitation 的前置鏈已確認 | Snowkeep 內 NPC／物件未確認 |
| Quest / Reward | invitation 是可確認的進入憑證 | Snowkeep 內 trigger／quest state／completion／reward 未確認 |

**Status：SOURCE_REQUIRED / UNREACHABLE。** 取得同版本 `/d/snowkeep/` LPC 後，須先閉合 include、inherit、clone、exit，再做 targeted compile 與入口 Runtime。

## Class Implementation Packages

| Class | Confirmed | Missing exact Source | Conflict / compatibility | Runtime handoff |
|---|---|---|---|---|
| Taoist | Target 歷史文件確認職業規劃；目前只有 rank compatibility | Target entry Room/NPC、recruit trigger、player `set_class("taoist")`、class daemon、`initialize`／`advance_level` | mudchina／MudRen family 的 master、API 與地圖結構不同，不能直接移植 | Entry→recruit→class→rank→save→relogin |
| Bonze | Legacy 文件確認職業／山煙寺設計 | Target entry、master/NPC、recruit、player `set_class("bonze")`、class daemon、rank/progression | 外部 family 出家鏈僅能 corroborate | Entry→recruit→class→rank→save→relogin |
| Soldier | Target NPC 與 `feature/npc/soldier.c` 確認 NPC soldier 行為 | Player entry/NPC、合法 player `set_class("soldier")`、player class daemon、rank/progression | NPC soldier 不等於玩家職業 daemon | Entry→trigger→class→rank→save→relogin |

三項目前均為 **SOURCE_REQUIRED**；缺少任何一段時不得建立玩家職業 Runtime。

## Quest Implementation Package

- **Track A — Random Task**：外部 ES2 family 已有 `QUEST_D → qlist → assignment NPC → combat completion → reward → quest clear` 候選鏈。
- **Target missing**：目標版本 quest daemon、assignment NPC、欄位 schema、completion/reward 呼叫端與 save/persistence 邊界。
- **Track B — Story / Area**：保留既有 Snow thief、貨棧工錢、Scholar entry Runtime 證據；不得與 Random Task 混為同一系統。
- **Implementation gate**：只有取得 Target-compatible daemon＋assignment＋target＋completion＋reward＋persistence 直接 LPC，才可標記 `IMPLEMENTATION READY`。
- **Runtime handoff**：隔離角色完成 assignment→progress→completion→reward→save→relogin；每段需明確 marker。

**Status：PARTIAL / SOURCE_REQUIRED。** 攻略或 `doc/wiz/quest` 不足以補造數值。
