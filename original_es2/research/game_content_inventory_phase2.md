# Original ES2 Game Content Inventory — Phase 2

> Audit baseline：`build/original-es2-races-phase2` @ `b3992eea6ba59bfee3b2728f04719afd866245a7`  
> Pinned Original Source：Annihilator/taedlar @ `cc45c06af4852380e5148dad3c9d53ff06854f2c`  
> 原則：Source Exists 不等於 Playable；Static PASS 不等於 Runtime PASS；外部 ES2 family 候選不倒灌為目標版本 Canon。

## 1. Inventory Summary

| 類別 | 數量／範圍 | 狀態 | 判定依據 |
|---|---:|---|---|
| Area / Region | 1 個保存區域：`/d/snow` | PASS | Pinned Original tree 只有 Snow area；真實 Driver 已走完整區域 |
| Room | 43 | PASS / N/A | 42 個玩家可達；`inn_staff_room` 為掌櫃排程服務房，不是玩家出口 |
| Active Room Exit | 86 個 exit／custom movement transition | PASS | 無 active destination 指向缺檔 Snow room |
| NPC Source | 23 | PARTIAL | 22 個直接或動態有引用；`child4.c` 無生成點；各 NPC 功能見下表 |
| Snow NPC Object | 29 | PARTIAL | 主要武器、裝備、任務物件與場景物件存在；兩項缺外部依賴 |
| Snow Area Object | 3 | PASS | 兩本 study book 與七彩石 overlay 基礎物件 |
| Shared Area Object | 26 | PASS / PARTIAL | 武器、服裝、容器、骰子；已使用部分可玩，完整逐件 Runtime 未驗證 |
| Shop / Vendor | 4 | PASS | 店小二、藥鋪掌櫃、鐵匠、魚天；既有 Economy Driver Journey 已通過 |
| Bank | 1 | PASS | 魚記小鋪繼承 `BANK`；既有 Economy Driver Journey 已通過 |
| Original Class Daemon | 2 | PARTIAL | `commoner.c`、`fighter.c`；Snow NPC 另可設定 scholar／thief／alchemist，但無同版本 daemon |
| Skill Daemon | 2 | PARTIAL | `sword.c`、`unarmed.c`；Snow 另保存 `dragon_force.c` |
| Story / Area Progression | 6 條可辨識鏈 | PARTIAL | 2 條 Runtime PASS、4 條 partial／broken；詳見 Quest Inventory |
| Save / Persistence | Player dbase + autoload + Neon backing | PASS | 既有跨容器證據；本輪盜賊 class／learned state 亦通過重登還原 |

可重複清冊 Gate：

```bash
node scripts/test_game_content_phase2_static.mjs <pinned-original-mudlib>
```

輸出 `GAME_CONTENT_PHASE2_STATIC_PASS` 才代表本表的數量、Snow active room reference 與已知缺檔邊界沒有漂移。

## 2. World / Map Dependency

### 2.1 玩家可達性

- 起點：`/d/snow/inn_hall`。
- 43 個 room 中 42 個可由 exit 或 `enter`／`out`／`climb` 到達。
- `inn_staff_room` 只供 `innkeeper.c` 排程移動；無玩家入口，分類 `NOT APPLICABLE`，不是 broken room。
- 隱藏／條件移動已納入：廣場榕樹、破宅樑柱、磨坊、客棧大灶、東路圍牆。
- active Snow destination 缺檔數：0。

### 2.2 保存邊界

下列 exit 在 Source 中已被註解，代表歷史世界邊界，不是 active broken exit：

| Snow 邊界 | 歷史目的地 | 狀態 |
|---|---|---|
| `river1` north | `/d/chixiao/river2` | UNREACHABLE / UNKNOWN |
| `ngate` north | `/d/goat/sroad1` | UNREACHABLE / UNKNOWN |
| `sgate` southeast | `/d/oldpine/road1` | UNREACHABLE / UNKNOWN |
| `sgate` west | `/d/newcamp/gate` | UNREACHABLE / UNKNOWN |
| `npath2` north | `/d/month/a1` | UNREACHABLE / UNKNOWN |
| `wgate` northwest | `/d/graveyard/grave1` | UNREACHABLE / UNKNOWN |
| `egate` northeast | `/d/lee/r1` | UNREACHABLE / UNKNOWN |
| `ebridge` east | `/d/snowkeep/entrance` | UNREACHABLE；另有 active NPC handoff，見 Quest Q2 |

## 3. NPC Inventory

| NPC Source | 名稱 | 生成位置／方式 | 內容依賴 | 狀態 |
|---|---|---|---|---|
| `waiter.c` | 店小二 | `inn_hall` | 四種食物 vendor、阿寶鏈入口物品 | PASS |
| `innkeeper.c` | 掌櫃 | `inn_hall` | 客棧排程；受襲時生成 patrol | PASS |
| `gammer.c` | 瞎眼老太婆 | `square` | 梳子→盜賊；`try/fon` 殘鏈 | PASS / PARTIAL |
| `junkman.c` | 拾荒老頭 | `square` | 接受物品 | PARTIAL（互動存在，完整用途無證據） |
| `herbalist.c` | 藥鋪掌櫃 | `herb_shop` | 四種藥品 vendor | PASS |
| `child.c` | 阿寶 | `tree` | 食物→梳子；`try/fon` 殘鏈 | PASS / PARTIAL |
| `child1.c` | 小孩 | `square_n` | 場景 NPC | PASS |
| `child2.c` | 小孩 | `square_n` | 木劍裝備 | PASS |
| `child3.c` | 小孩 | `school` ×2 | 私塾場景 | PASS |
| `child4.c` | 小孩 | 無 spawn reference | 未發現依賴 | UNREACHABLE |
| `teacher.c` | 王懷芝 | `school` | literacy、scholar 轉職 | PARTIAL |
| `alchemist.c` | 陳維俠 | `school` | apprentice→alchemist | PASS（既有 M31 Runtime） |
| `oldman.c` | 黑衣老人 | `court` | 裝備／戰鬥 | PASS |
| `girl.c` | 白衣女子 | `ruin2` | 髮簪→英雄帖 | PARTIAL |
| `woman.c` | 少婦 | `npath2` | 場景 NPC | PASS |
| `miller.c` | 楊大嬸 | `mill` | 場景 NPC | PASS |
| `smith.c` | 鐵匠 | `smithy` | vendor；洛鐵→箭 | PASS / PARTIAL |
| `foreman.c` | 工頭 | `store` | 木箱→驢車→工錢 | PARTIAL |
| `yu.c` | 魚天 | `bazar` | vendor／bank；金錢→雪亭小鎮見聞 | PASS / PARTIAL |
| `lieutenant.c` | 武官 | `ngate` | 守門 NPC／裝備 | PASS |
| `garrison.c` | 官兵 | `ngate` ×4 | 守門 NPC／裝備 | PASS |
| `guard.c` | 青衣漢子 | `ebridge` ×2 | 英雄帖→Snowkeep | BROKEN / UNREACHABLE |
| `patrol.c` | 巡邏官兵 | `innkeeper.c` 動態生成 | 客棧治安／戰鬥 | PASS |

## 4. Quest / Progression Dependency Graph

### Q1 — 阿寶梳子／盜賊入門

`waiter vendor → food → child(阿寶) accept_object → annatto comb → gammer accept_object → thief_qualified → say 祖奶奶 → class=thief → sneak/stealing learning progress 20 → save/restore`

- 狀態：**COMPLETE / Runtime PASS**。
- 真實 Driver：隔離 `thiefprobe` 全程由玩家指令通過；沒有使用 KING 或正式 Neon 資料。
- Original 行為邊界：`improve_skill(..., 20)` 寫入 learning progress，初始 raw skill level 仍為 0；本輪照原作驗收，未把 20 改造成技能等級。

### Q2 — 古銅髮簪／英雄帖／封山入口

`ruin1 在 10–13 時 search 雜草 → hairpin → girl accept → say 英雄帖 → invitation → ebridge guard accept → move /d/snowkeep/entrance`

- 狀態：**BROKEN / UNREACHABLE**。
- 斷點：目標 pinned Source 沒有 `/d/snowkeep/entrance`；guard 的交付後 move 是 active call。
- 處理：不從未鎖定版本的外部 ES2 family repository 搬入 Snowkeep。

### Q3 — 阿寶／瞎眼老太婆 `try/fon`

- 可見狀態：`0/1→3→5`、`8→10`、`10→13→15`、`16→18`、`40→43→45→48→50`。
- 狀態：**PARTIAL / UNKNOWN completion**。
- 缺口：`5→8`、`15→16`、`18→40` 呼叫端與 `__ID_CHALLIE__` 物件來源均不在目標 Source；也沒有 completion／reward 閉環。
- 保存：使用 `query_temp/set_temp("try/fon")`，不得宣稱可跨登入保存。

### Q4 — 私塾識字／書生

`sit → teacher heartbeat 教三字經 → literate progress → 條件式 pick_student → 玩家答覆 → class=scholar`

- 狀態：**RUNTIME PASS / BOUNDED（Phase 3）**。
- 隔離 fixture 只預置 Source 明列的 `literate=5` 前置；`sit`、learning progress、offer、玩家回答、`class=scholar` 與 save／relogin 均由真 Driver 通過。測試只以管理診斷排除 random scheduling，不修改正式機率；外部桃林與遺失 Scholar daemon 內容仍 UNKNOWN。

### Q5 — 陳維俠拜師／方士

`apprentice chen → pending/alchemist → apprentice chen → set_class(alchemist) + title`

- 狀態：**COMPLETE / Runtime PASS**。
- 證據：既有 `M31_CLASS_RUNTIME_PASS`，含 save／quit／relogin／restore。

### Q6 — 貨棧搬運工錢

`crate(wage=25) → load into wagon → wage_deserved += wage → 向工頭說工錢 → coin`

- 狀態：**RUNTIME PASS（Phase 3）**。
- 隔離真 Driver 已沿 Original exits 完成 `get crate → load → wage_deserved=25 → say 工錢 → 25 coin → save／relogin`。同時修復工頭既有 220 文與 25 文 reward 合併、誤付 245 文的 combined money bug；不改動 Original `wage=25`。

### 其他互動

- 鐵匠：`lo iron → arrow`，但目標區域沒有 `lo iron` 來源，分類 `PARTIAL / UNREACHABLE prerequisite`。
- 魚天：依玩家等級與金錢種類交付 `note.c`，Source 可見；此支線未獨立 Runtime 驗收，分類 `PARTIAL`。
- `adm/daemons/chard.c` 會在特定 PvP 罪行分支建立 `/d/domain/npc/police(_leader)`；兩檔不存在，分類 `BROKEN / UNKNOWN historical region`，但不阻斷一般玩家主循環。

## 5. Item / Equipment

### 5.1 保存模板

- Snow NPC objects：29。
- Snow area objects：3。
- Shared `/obj/area/obj`：26。
- 合計掃描模板：58。

依 inheritance 靜態分類：29 個武器型模板、14 個裝備型模板；其餘為任務／場景／容器／書籍／特殊物件。分類只表示型別，不自動代表每一件都在玩家路線上可取得。

### 5.2 可用 Consumable

- 食物：包子、饅頭、豬肉、紅燒雞。
- 藥品：烏心丹、山豬果、野山蔘、龍涎草（實際效果以其 Source 為準）。
- 飲水：廣場水缸依 `/obj/water` 提供；不把未驗證的 `wine_pot` 算入可用酒類。

### 5.3 缺檔物件依賴

- `wine_pot.c` 建立 `/d/choyin/npc/obj/red_wine`，目標 Source 不存在該檔；且 `wine_pot` 沒有 spawn reference，分類 `UNREACHABLE / BROKEN dependency`。
- `child4.c` 與其裝備 Source 存在但沒有 spawn point；保留為歷史 Source，不刪除。

## 6. Shop / Economy

| Vendor | 商品 | 狀態 |
|---|---|---|
| 店小二 | 4 種食物 | PASS；Q1 Runtime 實際購買包子 |
| 藥鋪掌櫃 | 4 種藥品 | PASS（既有 Economy Journey） |
| 鐵匠 | 鋤頭、鐵鏟、匕首、短劍 | PASS（既有 Economy Journey） |
| 魚天 | 藍衣套、毛皮帽、瓶 | PASS（既有 Economy Journey） |
| 魚記 BANK | 開戶、存提款、換錢 | PASS（既有 Economy Journey） |
| 貨棧工錢 | 搬箱取得 25 文（Source 固定值） | PARTIAL；未新增或調整數值 |

基本循環「取得／持有貨幣→購買→使用」已通過；完整 sell/restock 平衡若 Source 未提供則維持 UNKNOWN，不自行設計。

## 7. Apprentice / Class / Progression

- `commoner`／`fighter`：有同版本 daemon。
- `alchemist`：Snow 陳維俠鏈 Runtime PASS。
- `thief`：Snow 阿寶／老太婆鏈 Runtime PASS；同版本無 thief daemon，故職業內容完整度仍 PARTIAL。
- `scholar`：王懷芝 Source chain 已於 Phase 3 由隔離真 Driver 完成 save／quit／relogin，為 BOUNDED RUNTIME PASS；同版本 scholar daemon 仍缺。
- 其他職業與師門：七職業完整交叉結果見 `original_seven_class_runtime_matrix_phase3.md`；外部 evidence 只作候選，沒有目標 Source 就保持 SOURCE_REQUIRED／UNKNOWN。

目前已成立的玩家成長鏈：

`Login → Snow exploration → waiter purchase → 阿寶 item exchange → 老太婆 class progression → learned skill state → save → quit → relogin → restore`

Quest 全域狀態因此由「完全 UNKNOWN」更新為 **PARTIAL**：至少一條目標版本區域進階鏈可完整遊玩，但 Q2／Q3 與歷史區域缺口仍未恢復。

## 8. Blocking Assessment

- P0（Driver／Login／Save）：無新增 FAIL。
- P1（Snow active navigation）：無新增 FAIL。
- P2（Quest）：Q2 在 Snowkeep 缺檔處 BROKEN；Q3 PARTIAL。兩者不阻斷核心 Snow 玩家循環，但阻斷相應歷史內容。
- P3（Item）：`wine_pot` 與 `lo iron` prerequisite 有缺口；均非核心流程 blocker。
- P4（Apprentice／Class）：alchemist、thief、scholar 的目標玩家 transition 可玩；fighter、taoist、bonze、soldier 缺完整同版本玩家鏈，維持 SOURCE_REQUIRED／EVIDENCE_EXHAUSTED。
- 武功凍結區：本輪未修改。

不得以合理推測補入 Snowkeep、`__ID_CHALLIE__`、警捕 NPC、紅酒或任何 reward／機率／數值。這些項目必須等待同版本或可證明版本關係的 Original Source。
