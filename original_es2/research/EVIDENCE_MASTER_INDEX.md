# Original ES2 Evidence Master Index（證據總索引）

> 第四階段 4A。目的：建立 Original Research Evidence 的來源分級與主題索引；**本階段不搬移、不刪除、不合併 Evidence 正文**。

## 證據狀態標準

統一狀態與舊標籤相容規則請見 `original_es2/research/EVIDENCE_STATUS_STANDARD.md`。Google Sites／截圖類資料統一屬 `ARCHIVED_SOURCE`，不得與 Original LPC `CONFIRMED_SOURCE` 混為同一層級。

## 證據優先原則

Original Source（原始程式／官方保存來源） > Archived Source（歷史網站／截圖／封存） > Archived Gameplay Record（歷史實機紀錄） > Player Record（玩家紀錄） > Reconstruction（重建推論）。來源衝突時並列保存，不自行融合。

| 檔案 | 主題 | 主要來源層級 | 角色 | 重複/交叉關係 | 動作 |
|---|---|---|---|---|---|
| `es2_google_sites_index.md` | 全站索引 | Archived / Player / Source 混合 | Master Registry | 與各 Google Sites 專項交叉 | KEEP |
| `m16_npc_item_evidence_registry.md` | NPC/物品 M16 | Text + Runtime | Registry | M22 為後續 Runtime 擴充，不取代 M16 | KEEP |
| `m17_world_evidence_registry.md` | 世界 M17 | Text + Runtime | Registry | M21 為後續 Runtime 擴充，不取代 M17 | KEEP |
| `m18_quest_evidence_registry.md` | 任務 | Text + Runtime | Registry | 與 M18 Closure 配對 | KEEP |
| `game_content_inventory_phase2.md` | Phase 2 遊戲內容清冊 | Source + Static + Runtime | Inventory / Dependency Map | 43 rooms、23 NPC、Quest／Item／Shop／Class 邊界 | KEEP |
| `original_content_deep_recovery_phase3.md` | Phase 3 Snowkeep／fon／challie Deep Recovery + Quest Runtime | Source + History + External Negative Search + Runtime | Recovery Exhaustion / Runtime Evidence | 不覆寫 Phase 2 清冊；補足缺檔證據耗盡與兩條 Quest Journey | KEEP |
| `original_content_remaining_gap_list.md` | K Admin 驗收後 Original 剩餘內容缺口 | Existing Evidence + Runtime Matrix | Remaining Gap / Next Evidence Target | 集中記錄 SOURCE_REQUIRED、BROKEN、UNKNOWN、EVIDENCE_EXHAUSTED；不創作 Runtime | KEEP |
| `original_content_implementation_packages.md` | Human／Snowkeep／Class／Quest 實作交接包 | Confirmed Target Source + Missing Dependency Boundary | Implementation Gate / Runtime Handoff | 只整理可執行依賴與缺失 LPC；不把外部 family Source 升級成 Target Canon | KEEP |
| `target_lost_source_lifecycle_recovery_2026_09_29.md` | Target 缺失 Class／Quest／Snowkeep／Race／輪迴 Source 收斂 | Target Source + Git History + Exact Public Code Search + Family Lineage Diff | Lost Source Boundary / Dependency Gate | 新確認 Historical race 行為片段與 Target reincarnation core；外部 death-world lifecycle 標記 CONFLICT | KEEP |
| `m19_lifecycle_evidence_registry.md` | 生命週期 | Original Runtime | Registry | 與 M24 資料完整性交叉 | KEEP |
| `m21_world_content_evidence_registry.md` | 世界 Runtime | Original Runtime | Registry | 補強 M17；不是重複刪除候選 | KEEP |
| `m22_npc_item_evidence_registry.md` | NPC/物品 Runtime | Original Runtime | Registry | 補強 M16；不是重複刪除候選 | KEEP |
| `original_apprentice_m14.md` | 師徒 | Original Source | Baseline | 與 M23 核心玩法交叉 | KEEP |
| `original_class_reconstruction_m11.md` | 職業 Runtime | Original Source | Baseline | 與門派截圖證據互補 | KEEP |
| `original_class_school_evidence.md` | 七職業/門派 | ARCHIVED_SOURCE | Baseline | 與 M11 Runtime 證據互補 | KEEP |
| `original_seven_class_runtime_matrix_phase3.md` | 七職業 Runtime 完整度 | Target Source + History + Archived / External Cross-check | Runtime Matrix / Exhaustion Boundary | 統整 M11、M31、Phase 3，保留外部 lineage 邊界 | KEEP |
| `targeted_class_source_recovery_rc1.md` | Fighter／Taoist 定向 Source Recovery 與 R4 Gate | Target Source + Historical ES2 Source + Runtime | Reconstruction Gate / Runtime Provenance | Fighter 已 RECONSTRUCTION_RUNTIME_PASS；Taoist 維持 SOURCE_REQUIRED | KEEP |
| `original_martial_force_m13.md` | 武學/內功 | Original Source | Baseline | 與 M23 核心玩法交叉 | KEEP |
| `original_race_google_sites_evidence.md` | 種族設定 | ARCHIVED_SOURCE | Baseline | 與 Race Reconstruction 來源不同 | KEEP |
| `original_race_reconstruction_phase2.md` | 種族重建 | Source + Archived Gameplay | Reconstruction Baseline | 保留版本/命名衝突，不與網站證據融合 | KEEP |
| `original_race_runtime_baseline_m10.tsv` | 種族 Runtime 基線 | Runtime Dataset | Machine-readable Evidence | 與 Race 文件配對 | KEEP |
| `original_skill_reconstruction_m12.md` | 技能 | Original Source + Reconstruction | Baseline | 與 Study 文件互補 | KEEP |
| `original_study_formula_m12.md` | Study 精確公式 | Original Source | Formula Evidence | 比 Learning 文件更精確的公式層 | KEEP |
| `original_study_learning_m12.md` | Study 行為 | Original Source | Behavioral Evidence | 與 Formula 互補，不合併 | KEEP |
| `original_world_map_google_sites_evidence.md` | 國家地圖 | ARCHIVED_SOURCE | Visual Evidence | 與 M17/M21 Runtime 世界證據互補 | KEEP |

## 4A 結論

目前沒有任何一組 Evidence 適合直接去重刪除。M16→M22、M17→M21 是不同里程碑／不同證據成熟度；Study Formula／Learning 是公式與行為兩層；Race Google Sites／Reconstruction 是不同來源層。`score_interface_spec.md` 已於 4A 確認為 ES2-KING PROJECT-CANON 並移出 Original Evidence。第四階段 4B 已建立 `EVIDENCE_CONFLICT_REGISTER.md`，集中保存來源衝突，不覆寫任何 Evidence 正文。

## 4B 衝突摘要

目前已登錄：刑天/形天命名、黑齒業力 3/5、夜叉業力 35/30，以及人類族 Original ID 待考證。`cor=膽識`、`cps=定力` 已於 4C 由 Owner 確認並完成資料校正，不再列為未解衝突。詳見 `original_es2/research/EVIDENCE_CONFLICT_REGISTER.md`。

## 4C 欄位一致性基線

八屬性代碼固定為：`str=臂力`、`cor=膽識`、`int=悟性`、`spi=靈性`、`cps=定力`、`dex=機敏`、`con=根骨`、`wis=慧根`。後續 Evidence/Canon/Runtime 新增或修改資料均不得再使用舊的 cor/cps 反向映射。

## 4D 狀態標籤治理

已建立 `EVIDENCE_STATUS_STANDARD.md`。本輪優先修正三份最容易把「截圖已確認」誤讀為「Original Source Code 已確認」的文件；其餘 Evidence 保留正文與歷史標籤，透過相容規則統一解讀，避免為改標籤而大量改寫歷史證據。

## 4E Runtime 可用性

已建立 `EVIDENCE_RUNTIME_USABILITY_MATRIX.md`，把 Evidence 分成 `IMPLEMENTABLE`、`PARTIAL_IMPLEMENTABLE`、`REFERENCE_ONLY`、`SOURCE_REQUIRED`、`CONFLICT_BLOCKED`。此分類只代表證據是否足以支持安全重建，不等同 Runtime/Public PASS。


## PIXNET Historical Gameplay Evidence

- `pixnet_clert2201_historical_gameplay_evidence.md` — 「紅塵偶遇／緒方殘炎」東方故事2歷史實機、攻略、武學、NPC、任務、物品、地圖、Rank、Books、天賦與 Board 更新證據。2026-09-29 已逐頁讀取主索引 4 頁、39 篇文章，文章內站內 post link 無新增節點；狀態：**DEPTH EXHAUSTED（Pending = 0）**。

- `mei_yingfeng_skills_runtime_evidence.md` — 梅影風實際 Skills 畫面：寒梅心法、傲梅暗劍訣、冷梅劍法、梅影身法、七巧如意手五項 Runtime CONFIRMED。


## 新增 Historical Gameplay Evidence 索引

| 檔案 | 主題 | 主要來源層級 | 狀態 |
|---|---|---|---|
| `pixnet_clert2201_historical_gameplay_evidence.md` | PIXNET 東方故事2攻略／實機／Board | Archived Gameplay / Historical | IN PROGRESS |
| `mei_yingfeng_skills_runtime_evidence.md` | 梅影風五項 Skills + acquire | Actual Gameplay Record | CONFIRMED |
| `es2_actual_login_character_runtime_evidence_part1.md` | Login／創角／初期操作錄影 | Actual Gameplay Video | PARTIAL CONFIRMED / 持續逐格 |

以上屬 Historical Gameplay Evidence，不與 Original LPC Source 混級；但可用於校正 Reconstruction 與 Full Driver expected behavior。

- `vovo2000_es2_character_historical_evidence.md` — Vovo2000 VOA ACT #7 ES2 人物資料鏡像與投稿連結圖；三頁主串及可達 ES2 子頁已逐層確認。包含 NPC/職業/門派/裝備、冷梅莊、封山派、陰間 Lifecycle、種族顯示、主線/歷史/神話。狀態：**DEPTH EXHAUSTED（以 topic 29232 可達 ES2 graph 為邊界）**。

- `EVIDENCE_MASTER_SUMMARY_ZH_TW.md` — **最新中文 Evidence Master Summary**：統整實際遊戲影片、梅影風實機 Skills、PIXNET、Vovo2000、冷梅／封山、World Lore、Lifecycle、Race，以及 Reconstruction/Expansion 隔離與目前真正缺口。後續新增 Evidence 優先由此總覽進入 Gap Comparison。


## KING Weapon Combat Mapping Recovery — 2026-09-28

### SOURCE CONFIRMED
- Original ES2 `data/chinese.o`：`advance_lunmay` = 傲梅暗劍訣；`chin_staff` = 青邪杖法；`secondhand sword` = 左手劍術；`twohanded staff` = 雙握杖法。
- Original ES2 `feature/weapon/sword.c` 明確提供 `secondhand sword` damage channel；`feature/weapon/staff.c` 明確提供 `twohanded staff` damage channel。
- Original ES2 legacy equip 文件確認 `wield_as` 可讓同一武器以 `sword`／`secondhand sword` 等武器技能裝備。

### UNKNOWN / EVIDENCE BOUNDARY
- 目前公開 Original ES2 Source Recovery 尚未找到 `map_skill("secondhand sword", "advance_lunmay")` 或等價直接 mapping 證據。
- 目前公開 Original ES2 Source Recovery 尚未找到 `map_skill("twohanded staff", "chin_staff")` 或等價直接 mapping 證據。
- 因此不得僅依中文名稱或武器類型推導「傲梅暗劍訣 = secondhand sword」或「青邪杖法 = twohanded staff」正式 Combat Mapping；兩項維持 UNKNOWN，等待 Historical Evidence 或更完整 Original Source。

## Original Inventory Persistence Boundary — 2026-09-28

### CONFIRMED
- Target pinned Original baseline：`taedlar/es2_mudlib@cc45c06af4852380e5148dad3c9d53ff06854f2c`。
- `mudlib/obj/user.c::save()` 在玩家存檔前呼叫 `save_autoload()`；`setup()` 在玩家載入後呼叫 `restore_autoload()`。
- `mudlib/feature/user/autoload.c::save_autoload()` 掃描 Inventory，但對 `query_autoload()` 為假的物件直接 `continue`；restore 只依保存的 autoload path／parameter 重新建立物件。
- `mudlib/cmds/usr/quit.c` 亦把 `query_autoload()` 作為離線物件保留邊界。

### 結論
- Original 角色物品 persistence 是明確的 **autoload opt-in policy**，不是任意 Equipment 通用保存。
- 已通過的 autoload save／quit／relogin 行為維持有效；任意 non-autoload equipment 不應再列為待補 Runtime 功能，也不得為提高完成度新增另一套泛用保存規則。

## Target Taoist Legacy Plan Recovery — 2026-09-28

### PARTIAL CONFIRMED
- Target lineage：`taedlar/es2_mudlib@cc45c06af4852380e5148dad3c9d53ff06854f2c`。
- `docs/legacy/wiz/taoist-plan` 保存 Annihilator@Eastern.Stories 於 1995-01-18 撰寫的 Taoist 職業定位與技能規劃；Git History 顯示原檔於 initial commit `936131f5b92d0e93ee43790a8dfef3efa7a8b822` 匯入，後於 `3b5272161bc91e2010c9ebdd5520cda3547ca0eb` 移入 `docs/legacy/`。
- 文件可直接支持「道士」職業概念及太極心法、五行攝氣訣、天磯劍法、道藏等歷史規劃名稱。

### SOURCE BOUNDARY
- Target tree／target Git History 仍未保存 Taoist class daemon、entry room／NPC、recruitment command、`initialize()` 或 `advance_level()` Source。
- Historical mudchina／MudRen `taolord.c` 仍屬外部 ES2-family corroboration；不得以 legacy plan 取代缺失 LPC 或反推技能數值、起始房間及拜師條件。
- 結論：Taoist 為 `PARTIAL / SOURCE_REQUIRED`，`IMPLEMENTATION READY = NO`。

## es2.xor.tw Original Source Recovery — 2026-09-28

### Snow 英雄帖 → Snowkeep
- Original Source：`/d/snow/npc/girl.c` 以 `bronze hairpin` 觸發請求，玩家回答「英雄帖」後建立並丟出 `/d/snow/npc/obj/invitation`。
- `/d/snow/npc/guard.c` 接受 `invitation` 後銷毀英雄帖，將玩家移往 `/d/snowkeep/entrance`；`/d/snow/ebridge.c` 的 east exit 亦指向同一路徑。
- `/include/explore.h` 定義 `ID_SNOWKEEP = 10`，但 MANIFEST 未保存 `/d/snowkeep/`。
- 狀態：前置 dependency `CONFIRMED_SOURCE`；目的 Area `UNREACHABLE / SOURCE_REQUIRED`；`IMPLEMENTATION READY = NO`。

### Human Race Initializer
- `/adm/daemons/logind.c` 的 `user_race` 直接包含 `human`；`get_race()` 驗證 ID／karma，`get_gender()` 呼叫 `body->set_race(race)`，`init_new_body()` 設定 commoner／level 1 後呼叫 `CHAR_D->setup_char()`。
- `/adm/daemons/chard.c::setup_char()` 依序執行 `RACE_D(query_race())->setup()` 與 `CLASS_D(query_class())->setup()`；`/feature/char/score.c::set_race()` 會執行 race／class `initialize()`。
- `/daemon/race/human.c` 直接確認 Original ID `human`、karma 5、Human 八屬性各 `13 + random(6)`、gin／kee／sen 各 30、女性年齡 13／男性 14，以及 Human setup 行為。
- `enter_world()` 在新角色初始化後執行 `user->save()`，並以 `startroom` 或 `START_ROOM` 入場。
- 狀態：Human `CONFIRMED_SOURCE / DEPENDENCY_CLOSED`；現有 Runtime 已具同源 Source，無需重複 Restoration。`human_clan` 仍只屬 Reconstruction ID；其他 Race 不由 Human 推導。

### Avatar Race Initializer
- Target pinned Original `daemon/race/avatar.c` 為直接 LPC；`logind.c::user_race` 同時列出 `human` 與 `avatar`，`chard.c::hint_user_race()` 亦保存化身神說明。
- `avatar.c` 直接確認 Original ID `avatar`、karma 100、八屬性各 `16 + random(3)`、gin／kee／sen 各 30、natural armor 5、年齡 `14 + random(4)`、weight／setup 與 race daemon registration。
- `human.c::initialize()` 另保存玩家 Human 以 `random(10000) == 9999` 轉為 `avatar` 的 Original 路徑；不據此推導其他歷史種族。
- 狀態：Avatar `CONFIRMED_SOURCE / DEPENDENCY_CLOSED`；這是 Target Original Source，不是 Historical family reconstruction。

### `wine_pot` → `red_wine` 精確邊界
- Target Original `d/snow/npc/obj/wine_pot.c::create()` 直接 `new("/d/choyin/npc/obj/red_wine")`，並設 volume 150000；`reset()` 尋找 `red wine` 後補回 volume。
- Target tree／history 與 MudRen／mudchina mirrors 均未保存 `d/choyin/npc/obj/red_wine.c`；因此缺口是被直接引用的 object LPC，而不是缺少 spawn reference。
- 狀態：`wine_pot` 為 `CONFIRMED_SOURCE`，`red_wine` 為 `SOURCE_REQUIRED / BROKEN DEPENDENCY`；不得以其他酒物件替代。

### Taoist／Quest／Bonze／Soldier Boundary
- Taoist：`/doc/wiz/taoist-plan`、`taoism-spells` 與 Legacy 資料可確認職業／技能設計，但 MANIFEST 無 Target class daemon、entry、recruit LPC；維持 `PARTIAL / SOURCE_REQUIRED`。
- Quest：`/doc/wiz/quest` 確認 Original 主要模型為區域事件／故事／解謎，可導向物品、技能、門派或職業；未發現 Random Task daemon／assignment／completion／reward Source，Track A 維持 `PARTIAL / SOURCE_REQUIRED`。
- Bonze：`/doc/wiz/bonze` 與 Legacy 山煙寺／玄智和尚資料只屬設計及 Historical corroboration，未閉合 Target player-class dependency。
- Soldier：`/feature/npc/soldier.c` 是官兵 NPC 協同／拒戰行為；`/obj/npc/garrison.c` 實際 class 仍為 fighter，不能作為玩家 soldier 職業 daemon。
- 上述四項 `IMPLEMENTATION READY = NO`；未修改 Gameplay Source。

## Target Lost Source / Lifecycle Recovery — 2026-09-29

- Taoist／Bonze：MudRen／mudchina 保存的是外部 family master／skill tree，沒有 Target root class daemon、entry、player `set_class`、`initialize`／`advance_level` 閉環；維持 `PARTIAL / SOURCE_REQUIRED`。
- Soldier：公開精確搜尋的 player-class ID 只回到 Target 黑白無常 NPC；再次確認 NPC `set_class("soldier")` 不構成玩家職業入口。
- Snowkeep／`red_wine`：公開精確 Code Search 只重現 Target caller／reference，沒有取得缺失 callee LPC。
- Historical race：Target `who.c` 直接確認九個歷史 race ID；`steal.c`、`combatd.c`、`teacher.c` 與 traveller NPC 保存 jiaojao／rainnar／ashura 等局部行為，但不含 initializer 公式，狀態 `PARTIAL / SOURCE_REQUIRED`。
- Reincarnation：Target `chard.c → LOGIN_D->reincarnate()` 直接證明 body recreation／race reselection core；外部 family 則是解除 ghost＋回復 stats 的另一 lifecycle，兩者標記 `CONFLICT`，不得拼接。
- 本輪沒有新 `RECONSTRUCTION_READY`，未修改 Gameplay Source。
