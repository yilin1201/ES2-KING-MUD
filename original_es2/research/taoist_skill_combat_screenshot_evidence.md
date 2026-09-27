# Original ES2 Taoist Skill / Combat Screenshot Evidence Registry

> 建檔日期：2026-09-27
> 主要來源：ES2 MUD Tips（es2tips.blogspot.com）歷史 help、Pot-w 公告、玩家實機/圖片文章。
> 目的：把道士職業「文字 Help 宣告」與「圖片/實機畫面真正出現」分層記錄，供 Original ES2 Recovery 使用。
> 規則：Help Exists ≠ Screenshot Confirmed ≠ Runtime PASS。圖片未逐張驗證前不得標成實機招式 CONFIRMED。

## 1. 職業樹

### 天師道士
- 朱衣派：`taoist.fire`，師父郭布。
- 玄衣派：`taoist.storm`，師父安懶道人。
- 素衣派：`taoist.freeze`，師父白齊。
- 紫衣派：`taoist.thunder`，師父華子儀。
- 歷史職業頁建議路線記錄：Fire → Storm/Freeze（任務）→ Thunder（任務）。此為玩家攻略敘述，不作 Runtime requirement Canon。

### 茅山道士
- 靈雲觀：`mao-shan.cloud`，林正陽。
- 隱風觀：`mao-shan.wind`，歐陽無極。
- 幻霧觀：`mao-shan.fog`，杜風凌。
- 進階：`taoist.adv`。
- 另有 `mao-shan.sword` 茅山劍士 help 節點。

## 2. 天師四派咒術 — Help Evidence

| 派系 | Skill | 招式 ID | 中文招式 | Help 效果摘要 | Evidence |
|---|---|---|---|---|---|
| 朱衣 | `taoism-fire` | `magic fire` | 咒火 | sen 5 / delay 1 / 傷害 50% | HELP CONFIRMED |
| 朱衣 | `taoism-fire` | `earth fire` | 地火 | sen 20 / delay 1 / 傷害 33%，恢復氣，無視抗性 | HELP CONFIRMED |
| 朱衣 | `taoism-fire` | `inferno fire` | 大業火 | sen 45 / delay 2 / 50% + 當前氣 25% 傷害 | HELP CONFIRMED |
| 朱衣 | `taoism-fire` | `pure fire` | 三昧真火 | sen 75 / delay 3 / 總傷害 300% | HELP CONFIRMED |
| 玄衣 | `taoism-storm` | `quick storm` | 疾風 | sen 10 / delay 1 / 傷害 25%；條件滿足後影響下次風符催咒 | HELP CONFIRMED |
| 玄衣 | `taoism-storm` | `crazy storm` | 暴風 | sen 30 / delay 1 / 傷害 33%，命中忽視風抗 | HELP CONFIRMED |
| 玄衣 | `taoism-storm` | `killer storm` | 飛戮風 | sen 50 / delay 1 / 傷害 75% | HELP CONFIRMED |
| 玄衣 | `taoism-storm` | `whirl storm` | 轉輪大風 | sen 75 / delay 3 / 傷害 125% | HELP CONFIRMED |
| 素衣 | `taoism-freeze` | `chill freeze` | 寒冰 | sen 5 / delay 1 / 傷害 50% | HELP CONFIRMED |
| 素衣 | `taoism-freeze` | `ominous freeze` | 兆冰 | sen 20 / delay 2 / 精 100%、神 33% 傷害；回復精神；無視抗性 | HELP CONFIRMED |
| 素衣 | `taoism-freeze` | `shadow freeze` | 無相冰 | sen 30；命中使目標 delay 3，自身無 delay；失敗自身 delay 1 | HELP CONFIRMED |
| 素衣 | `taoism-freeze` | `polar freeze` | 七重玄冰 | sen 50 / delay 2 / 傷害 150% | HELP CONFIRMED |
| 紫衣 | `taoism-thunder` | `swamp thunder` | 澤雷 | sen 5 / delay 1 / 傷害 50% | HELP CONFIRMED |
| 紫衣 | `taoism-thunder` | `blaster thunder` | 爆雷 | sen 50 / delay 1 / 25% + 當前神 1/8 | HELP CONFIRMED |
| 紫衣 | `taoism-thunder` | `divine thunder` | 神光雷 | sen 75 / delay 2 / 對神造成 33%，無視抗性 | HELP CONFIRMED |
| 紫衣 | `taoism-thunder` | `hexagram thunder` | 六卦熒雷 | sen 90 / delay 2 / 傷害 175%，觸發但不消耗 overload | HELP CONFIRMED |

### Pot-w 時間線佐證
2013-05-22 官方公告保存：「天師四派咒法更新，見 help taoist.fire, storm, freeze, thunder」。因此四派技能 Help 至少在該公告時間點屬正式更新對象。

## 3. 天師派內功 / 身法

### 朱衣
- `sun force` 丹陽神功：remedy、recover、sun fire。
- `eight_steps` 火雲奇門步法：縱躍閃躲。

### 玄衣
- `dao force` 明道心法：recover、remedy、windarmor。

### 紫衣
- `nine-dragon force` 九龍神功：heal、regenerate、overload。
- `reflecting star sword` 清河映星劍。
- `magic steps` 陰陽奇門步。

### 素衣
- Blog Help 節錄確認另有縱躍閃躲技能、上清道長學習節點；目前搜尋結果未完整顯示技能名稱，標 `PARTIAL / NAME PENDING`，不可自行補名。

## 4. 道士共享技能

### 太乙劍法 `taiyie`
- 劍術 + parry。
- Help：內功 30 可學；內功 90 + 幻劍術 90 後，招架攻擊時可自動施展幻劍術。

### 幻劍術 `virtual sword`
| ID | 中文招式 | Help 傷害描述 |
|---|---|---|
| `ten` | 十面埋伏 | 附加傷害 +10 |
| `thirty-six` | 六陰六陽劍 | +36 |
| `forty-nine` | 四九歸元 | +49 |
| `sixty-four` | 六十四爻誅殺訣 | +64 |
| `eighty-one` | 九九陽極幻劍 | +81 |
| `ninety-nine` | 無極幻影 | +99 |
Help 記錄：消耗神為總傷害一半，自身 delay 1。

### 紫薇心經 `chivi sutra`
- `fire defence` 禦火術。
- `storm defence` 禦風術。
- `freeze defence` 禦冰術。
- `thunder defence` 禦雷術。
- `dispel` 解除效果。

### 桃山密籙 `taoism of conviction`
- `thunder-conviction` 狂雷咒：降雷防。
- `freeze-conviction` 寒冰咒：降冰防。
- `fire-conviction` 炎殺咒：降火防。
- `storm-conviction` 亂風咒：降風防。
- `dispel` 解除桃山效果。

### 素雲書 `taoism-cloud`
`taiyi` 太乙為前置；傳送節點依 Help：snow(15)、month(30)、sptown(45)、fontown(60)、swaylan(75)、yaoy(90)、skysnow(105)、flower(120)、fei(135)、tomb(150)、capital(165)、dragon(180)。Help 記錄每次消耗 50 神。

## 5. 茅山系 — Help Evidence

### 靈雲觀 `mao-shan.cloud`
幽冥三箭 `taoism of purify`：
- `netherbolt` 青冥之箭：可恢復神。
- `drainerbolt` 紫幽之箭：可恢復精。
- `feeblebolt` 蒼靈之箭：可恢復氣。
- Help 記錄三箭對殭屍、鬼魂、動物有較高傷害，需正陽符。

茅山〖五雷術〗 `mao-shan lightning`：已確認 Help 節點與 `cleanse` 等能力存在；完整能力表待逐頁補齊，標 `PARTIAL`。

### 茅山共通 `mao-shan magic`
- `blank`：符紙變普通。
- `yin`：普通符 → 少陰符。
- `yang`：普通符 → 正陽符。
- `nature`：普通符 → 先天符。
- `remedy`：消耗先天符恢復體力。

### 茅山奇門術 `mao-shan mysticism`（目前 Help 節錄）
- `recall` 翔空之術。
- `collect` 集靈之術。
- `slave` 通靈之術。
- `devour` 噬魂之術。
- 另有 memory/記憶相關能力，但本輪節錄不完整，保留 `PARTIAL`。

### 隱風 / 幻霧
網站確認 `mao-shan.wind`、`mao-shan.fog` 與師父/地點；其完整招式表需從圖片與各自 Help 頁繼續逐項 recovery。本檔不使用先前聊天推測補齊。

## 6. Screenshot / Actual Gameplay Evidence Layer

### 分級
- `HELP CONFIRMED`：Blog 保存遊戲 help 文字。
- `BOARD CONFIRMED`：Pot-w 官方公告保存。
- `SCREENSHOT CONFIRMED`：必須能在網站圖片/戰鬥截字看到實際招式名稱或施法訊息。
- `GAMEPLAY TEXT CONFIRMED`：文章保存 terminal 實機輸出。
- `PENDING IMAGE REVIEW`：文章有圖，但尚未逐張辨識。

### 目前狀態
本輪已建立完整 Help 骨架，但尚未把網站所有道士圖片逐張完成視覺辨識。因此上述招式目前主要是 `HELP CONFIRMED`，不可批次升級為 `SCREENSHOT CONFIRMED`。
2014/11 實機文字保存隱風觀趙曉九的 NPC 行為：召喚火球失敗、呼喚金烏神使、以書換神符等；屬 `GAMEPLAY TEXT CONFIRMED`，但不等同玩家可學技能。

## 7. Source / Runtime Cross-check

本輪對 ES2-KING branch 做路徑/檔名搜尋，未從 tree path 找到明確 `taoism-fire/storm/freeze/thunder`、`mao-shan.*` 對應檔名。這只代表路徑名稱搜尋沒有命中，不足以宣告 Source Missing；後續需做內容搜尋與 historical upstream 比對。

## 8. Pending Screenshot Recovery Queue
1. 逐篇搜尋 taoist.fire/storm/freeze/thunder 圖片文章。
2. 逐張辨識咒火/地火/大業火/三昧真火的戰鬥訊息。
3. 逐張辨識疾風/暴風/飛戮風/轉輪大風及多重催咒。
4. 逐張辨識寒冰/兆冰/無相冰/七重玄冰。
5. 逐張辨識澤雷/爆雷/神光雷/六卦熒雷與 overload。
6. 追靈雲/隱風/幻霧圖片，完成茅山三觀招式表。
7. 追幻劍術六式實機畫面。
8. 每張圖片保存：文章 URL、日期、角色/目標、技能/招式、畫面原文、Evidence 等級。

狀態：`IN PROGRESS — HELP REGISTRY BUILT / SCREENSHOT REVIEW PENDING`。
## 9. Round 2 — Gameplay Combat Text / 茅山完整 Help 補強

### 9.1 轉輪大風 — Actual Gameplay Text CONFIRMED
2014/10 月 archive 保存紫衣派道士「雷道(Gfmul)」實戰文字。角色施展「轉輪大風」後，畫面連續顯示第一重、第二重、第三重轉輪大風，並記錄風刃命中駱易。
因此 `whirl storm / 轉輪大風` 可由單純 `HELP CONFIRMED` 升級為 `GAMEPLAY TEXT CONFIRMED`；同時證明風符多重催咒在歷史實機輸出中確實出現。
注意：角色標題為紫衣派，但可施展風系招式，與 `taoist.adv` 所記天師四系雙修機制方向相容；不可僅憑此紀錄推導完整學習條件。

### 9.2 靈雲觀完整 Help 補強
`mao-shan.cloud`：
- 幽冥三箭 `taoism of purify`：netherbolt 青冥之箭、drainerbolt 紫幽之箭、feeblebolt 蒼靈之箭。
- 五雷術 `mao-shan lightning`：`cleanse` 凝聚靈力；`bless` 消耗神/靈力/先天符，全面提升目標屬性、元素傷害與元素抗性；`consume` 消耗神/靈力/先天符恢復目標精神。
- Help 最後更新：2014/05/01。

### 9.3 隱風觀完整 Help 補強
`mao-shan.wind` / 茅山幻術 `taoism of nature`：
- `dog` 喚犬之術：目標 delay 2。
- `monkey` 喚猿之術：隨機偷取目標一件物品。
- `hydra` 喚蟒之術：吞掉非玩家目標。
- `rain` 喚雨之術：恢復施法者周圍玩家精氣神。
以上為 `HELP CONFIRMED`；尚未逐張取得實機圖片證明。

### 9.4 幻霧觀完整 Help 補強
`mao-shan.fog` / 茅山奇術 `taoism of darkness`：
- `hell` 入陰之術：前往地獄。
- `ghost_fire` 鬼火術：法術傷害。
- `smoke` 鬼煙術：脫離戰鬥並隱藏。
- `hell_fire` 幽冥之火：一次大量法術傷害。
- 上述施法需少陰符。

`mao-shan mysticism` 奇門術：
- `memory` 記憶之術。
- `recall` 翔空之術。
- `collect` 集靈之術。
- `slave` 通靈之術。
- `devour` 噬魂之術。

### 9.5 NPC Gameplay Text — 趙曉九
2014/11 實機文字：隱風觀道士趙曉九會因咒語錯誤被自己招出的火球炸倒，並嘗試呼喚「金烏神使」但失敗；也會以書籍交換神符。分類：`NPC GAMEPLAY TEXT CONFIRMED`，不視為玩家可學 skill。

### 9.6 Screenshot 狀態
目前搜尋介面能回收文章正文與歷史實機文字，但尚未可靠取得網站內所有原始 Blogger 圖片本體。因此本輪新增的是 `GAMEPLAY TEXT CONFIRMED`，不是 `SCREENSHOT CONFIRMED`。後續仍需針對文章原圖逐張 recovery。

Round 2 狀態：`IN PROGRESS — HELP EXPANDED / WHIRL STORM GAMEPLAY TEXT CONFIRMED / IMAGE REVIEW STILL PENDING`。