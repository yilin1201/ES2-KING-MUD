# Original ES2 Gameplay Gap Analysis

> Baseline：Internal Skill 前 HEAD `9f27811ac74e4b727acfcc5b9bd4ae565b6eb8b4`  
> Evidence precedence：Original Source → Original 文件 → 歷史保存資料 → 玩家記錄。  
> 本表只描述已保存 Original Runtime 的覆蓋程度；ES2-KING Expansion 不倒灌為 Original Canon。

## 功能差距矩陣

| 領域 | 狀態 | Evidence／Runtime 邊界 |
|---|---|---|
| Race | IMPLEMENTED | 既有 11 種族 compatibility 與公開選角已通過；遺失 initializer、人類族 Original ID 與衝突業力值仍不補造。 |
| Class | PARTIAL | Original `CLASS_D`、commoner／fighter 與 apprentice 轉職鏈存在；未保存的職業 Daemon／公式仍未知。 |
| School | IMPLEMENTED | Snow 私塾與龍圖丹派入門已在真實 Driver Journey 通過。 |
| NPC | IMPLEMENTED | Snow 保存區 NPC、vendor 與互動可執行；未保存歷史 NPC 屬性／掉落仍不補造。 |
| Map | PARTIAL | Snow 房間與 exits 可玩；歷史世界的完整 Room Tree、path、spawn 尚無足夠來源。 |
| Movement | IMPLEMENTED | 房間出口與方向移動已由真實 Driver 驗證。 |
| Items | IMPLEMENTED | 保存物件可取得、攜帶與交付；未知歷史掉落表維持 UNKNOWN。 |
| Equipment | IMPLEMENTED | Original 木劍取得、wield 與 inventory 已在 Journey 通過。 |
| Combat | IMPLEMENTED | Original kill／攻防回合已在真實 Driver 通過。 |
| Skills | IMPLEMENTED | skill storage、study、enable／map 與既有 Journey 指令鏈可用；未保存門派技能全集不補造。 |
| Internal Skill | IMPLEMENTED | Original `force → dragon force` 的 enable／map、exert、精氣神消耗、戰鬥修正與 save／quit／relogin／restore 已由隔離真實 Driver 通過；未保存的其他內功內容維持 UNKNOWN。 |
| Special Combat State | EVIDENCE FOUND / NOT IMPLEMENTED | 明鏡止水有歷史玩法與招式池證據；成本、回合、權重與 Original LPC 不足，禁止以 Expansion 推測補成 Original。 |
| Apprentice | IMPLEMENTED | apprentice command、非同步收徒 flag、relation 保存與轉職已實機通過。 |
| Quest | UNKNOWN | 候選版本與歷史文字存在，但目標 Original daemon、flags、獎勵與完整鏈未鎖定。 |
| Economy | IMPLEMENTED | `finance.c`、`buy.c` 為 Original Source；本輪新增真實 Driver 貨幣扣款驗證。 |
| Shop | IMPLEMENTED | waiter `F_VENDOR`、list、buy、交貨與 inventory 結果由同一 Session 驗證。 |
| Inventory | PARTIAL | inventory、合併物品與 autoload Source 可用；本輪已驗證 37 文合併物品跨 save／quit／relogin 精確還原。非 autoload 任意裝備的保存仍無完整證據。 |
| Death / Recovery | PARTIAL | 昏迷、corpse、ghost 與寺廟 make_living Source 已確認；城隍 register／輪迴與懲罰仍缺 LPC。 |
| Save / Restore | IMPLEMENTED | Original save_object／restore_object、relogin 與 Neon 跨容器 restore 已通過。 |
| Player progression | PARTIAL | level、score、skill、class／apprentice 保存鏈存在；完整長期成長與未保存職業公式尚未閉合。 |
| Commands | IMPLEMENTED | look、score、inventory、movement、combat、skills、apprentice、save、quit 與管理指令已執行。 |
| Social / communication | PARTIAL | say／tell 等 Original command Source 存在，但尚未納入雙玩家 Runtime Journey。 |
| Admin / KING | IMPLEMENTED | KING password／character restore、admin state 與 Owner authorization 已通過；明確屬 ES2-KING 管理層。 |

## 下一個 Evidence-backed 功能

Internal Skill 升級為 IMPLEMENTED 後，選擇 **Original Inventory（物品保存）**：

1. Evidence 完整度最高：`feature/user/autoload.c` 明確定義保存與還原合約，`std/money.c` 明確保存合併數量。
2. Runtime 相依性已具備：Original save／quit／relogin 與 Neon backing store 均已通過。
3. Gameplay 價值直接：玩家攜帶狀態若無法精確還原，長期角色流程不成立。
4. 不需要猜測 Quest、掉落表或任何遺失 Canon。

本輪實際進度：隔離 KING fixture 建立 37 文 → 記錄 `query_amount()` → save → quit → 新 WebSocket relogin → 驗證仍為 37。由於任意非 autoload 裝備沒有完整保存證據，Inventory 暫維持 PARTIAL。
