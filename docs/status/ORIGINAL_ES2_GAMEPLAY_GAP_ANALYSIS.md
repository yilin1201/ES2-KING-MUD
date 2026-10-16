# Original ES2 Gameplay Gap Analysis

> Baseline：Internal Skill 前 HEAD `9f27811ac74e4b727acfcc5b9bd4ae565b6eb8b4`  
> Evidence precedence：Original Source → Original 文件 → 歷史保存資料 → 玩家記錄。  
> 本表只描述已保存 Original Runtime 的覆蓋程度；ES2-KING Expansion 不倒灌為 Original Canon。

## 功能差距矩陣

| 領域 | 狀態 | Evidence／Runtime 邊界 |
|---|---|---|
| Race | IMPLEMENTED | 既有 11 種族 compatibility 與公開選角已通過；遺失 initializer、人類族 Original ID 與衝突業力值仍不補造。 |
| Class | PARTIAL / BOUNDED RUNTIME PASS | Original `CLASS_D`、commoner／fighter Source 與 alchemist／scholar／thief Target transition 已由真 Driver通過；Fighter Historical Reconstruction 另完成 join／武者 rank／save／relogin。Taoist／Bonze／Soldier 尚缺安全 Target-compatible 玩家鏈。 |
| School | IMPLEMENTED | Snow 私塾與龍圖丹派入門已在真實 Driver Journey 通過。 |
| NPC | IMPLEMENTED | Snow 保存區 NPC、vendor、互動、死亡、corpse 與 room reset 重生均由真 Driver 通過；未保存歷史 NPC 屬性／掉落仍不補造。 |
| Map | PARTIAL / BOUNDED RUNTIME PASS | Snow 保存區一般出口與 custom action 已由真 Driver 逐段走通；歷史世界完整 Room Tree、path、spawn 尚無足夠來源。 |
| Movement | IMPLEMENTED | 房間出口與方向移動已由真實 Driver 驗證。 |
| Items | IMPLEMENTED | 保存物件可取得、攜帶與交付；未知歷史掉落表維持 UNKNOWN。 |
| Equipment | IMPLEMENTED | Original 木劍 wield／unwield 與藍布長衫 wear／remove 已在 Journey 通過。 |
| Combat | IMPLEMENTED | Original NPC defeat 與普通玩家 defeat／ghost／寺廟 recovery 已在真實 Driver 通過。 |
| Skills | IMPLEMENTED | skill storage、study、enable／map 與既有 Journey 指令鏈可用；未保存門派技能全集不補造。 |
| Internal Skill | IMPLEMENTED | Original `force → dragon force` 的 enable／map、exert、精氣神消耗、戰鬥修正與 save／quit／relogin／restore 已由隔離真實 Driver 通過；未保存的其他內功內容維持 UNKNOWN。 |
| Special Combat State | EVIDENCE FOUND / NOT IMPLEMENTED | 明鏡止水有歷史玩法與招式池證據；成本、回合、權重與 Original LPC 不足，禁止以 Expansion 推測補成 Original。 |
| Apprentice | IMPLEMENTED | apprentice command、非同步收徒 flag、relation 保存與轉職已實機通過。 |
| Quest | PARTIAL | 目標 Snow thief、貨棧工錢與私塾 Scholar entry 已真實 Driver 閉合並跨重登；`try/fon` 與英雄帖→Snowkeep 已完成 Deep Recovery 但仍為 Evidence Exhausted 的斷鏈／缺檔，外部候選不倒灌。 |
| Economy | IMPLEMENTED | `finance.c`、`buy.c` 為 Original Source；本輪新增真實 Driver 貨幣扣款驗證。 |
| Shop | IMPLEMENTED | waiter `F_VENDOR`、list、buy、交貨與 inventory 結果由同一 Session 驗證。 |
| Inventory | PARTIAL | inventory、合併物品與 autoload Source 可用；本輪已驗證 37 文合併物品跨 save／quit／relogin 精確還原。非 autoload 任意裝備的保存仍無完整證據。 |
| Death / Recovery | IMPLEMENTED / BOUNDED | NPC corpse、玩家 defeat→ghost→土地公廟 swirl→make_living 已由真 Driver 通過；未保存的城隍 register／輪迴與懲罰仍 UNKNOWN。 |
| Save / Restore | IMPLEMENTED | Original save_object／restore_object、relogin 與 Neon 跨容器 restore 已通過。 |
| Player progression | PARTIAL / BOUNDED RUNTIME PASS | Explore→NPC→工作 reward→money save 與 school→learning→class→save 均新增真 Driver 證據；完整長期成長、Snowkeep story 與未保存職業公式尚未閉合。 |
| Commands | IMPLEMENTED | look、score、inventory、movement、combat、skills、apprentice、save、quit 與管理指令已執行。 |
| Social / communication | IMPLEMENTED / BOUNDED | 隔離雙玩家真 Driver 已通過 say／tell／reply、UTF-8、缺席玩家錯誤與 disconnect/relogin；遺失跨 MUD DNS／GTELL 維持 UNKNOWN。 |
| Admin / KING | IMPLEMENTED | KING password／character restore、admin state 與 Owner authorization已通過；K Admin 真 Driver 另完成 Owner→Wizard→Arch→remove、權限過濾 Help、Player denial、Original `k=kill` 與 save／relogin。明確屬 ES2-KING 管理層，不倒灌為 Original Canon。 |

## Social / Communication Runtime Completion

Original Source 已直接確認：
- `mudlib/cmds/std/say.c`：同房訊息廣播與 `relay_say`。
- `mudlib/cmds/std/tell.c`：線上玩家 lookup、私訊、ignore、節流與 reply target。
- `mudlib/cmds/std/reply.c`：依暫存 reply target 回覆，包含離線／ignore／netdead 邊界。

新增隔離雙玩家 Runtime Gate：
`scripts/test_original_social_communication_runtime_e2e.sh`
→ `scripts/test_original_social_communication_runtime_e2e.mjs`

驗證範圍：say 同房 UTF-8、tell 私訊 routing、reply routing、不存在玩家 Original error、disconnect／relogin 後 tell。

2026-09-27 已以保存的真正 Neolith binary 與隔離 save_object fixture 執行完成，成功標記包含 `ORIGINAL_SOCIAL_COMMUNICATION_RUNTIME_PASS`。本地玩家核心通訊因此升級為 IMPLEMENTED；跨 MUD DNS／GTELL Source 未保存，維持 UNKNOWN。
