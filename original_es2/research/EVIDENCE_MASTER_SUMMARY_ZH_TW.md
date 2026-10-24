# ES2-KING Evidence Master Summary（最新中文證據總整理）

> 更新日期：2026-09-25  
> 範圍：Original ES2 / Historical Evidence / Actual Gameplay / Reconstruction / Expansion  
> 原則：**Original Source > Archived Source > Archived Gameplay Record > Player Record > Reconstruction / Expansion**  
> 本文件是證據主索引摘要，不等同 Runtime PASS；UNKNOWN 不補造。

## 1. 已掌握的核心資料來源

| 資料群 | 已掌握內容 | 證據定位 |
|---|---|---|
| 使用者提供的實際 ES2 遊戲影片 | Login／角色流程／進入世界／房間文字／方向移動／Score／指令互動／世界探索 | Actual Gameplay Evidence |
| 梅影風實際 Skills／戰鬥畫面 | 武學中文名、Skill ID、畫面等級、acquire 指令 | High-value Gameplay Evidence |
| PIXNET clert2201 | 冷梅、封山、任務、武學、裝備、Rank、NPC、歷史 Gameplay | Historical Player / Archived Gameplay Evidence |
| Vovo2000 topic 29232 | NPC、門派、家族、裝備、種族、世界史、陰間／輪迴；可達 ES2 graph 已 DEPTH EXHAUSTED | Archived Historical Source |
| 舊 ES2-KING MOD／聊天文字 | 自行設計 NPC、HP、路徑、招式、數值 | Reconstruction / Expansion；不得倒灌 Original |

## 2. 實際 ES2 遊戲影片

目前影片已確認的操作骨架：

`Client startup → Login／Character flow → Enter World → Room text → Exits → Direction movement → Score／Character info → Command interaction → World exploration`

用途：
- 校正 Original ES2 UI、Prompt、Command、Output。
- 校正房間／出口／移動顯示方式。
- 作為 WebTelnet／Full Driver expected behavior 的歷史實機依據。

邊界：
- Historical Gameplay Evidence ≠ 目前 ES2-KING Runtime PASS。
- 尚不能以影片概括宣告 NPC、Items、Combat、Skills、School/Apprentice、Save/Quit/Relogin 全部通過。
- 精確 Login／Create Character Prompt/Output 仍需逐格補完。

## 3. 梅影風核心實機 Skills

| 中文名稱 | Original Skill ID | 實機畫面等級 |
|---|---|---:|
| 寒梅心法 | `hainmay force` | 200 |
| 傲梅暗劍訣 | `advance_lunmay` | 200 |
| 冷梅劍法 | `lunmay` | 195 |
| 梅影身法 | `mayin` | 195 |
| 七巧如意手 | `seven` | 186 |

已確認實機指令：
- `acquire seven from may`

安全結論：
- `seven` = 七巧如意手。
- `hainmay force` = 寒梅心法。
- `may` 為該 acquire 記錄中的梅影風教學／取得對象。
- 畫面等級只保存為該次 Gameplay Evidence，不推導 NPC 固定 Runtime 配置。

## 4. 寒梅心法名稱校正

早期 ES2-KING 曾使用「冷梅心法」；後續 Actual Gameplay + PIXNET 均支持：

**寒梅心法（hainmay force）**

正式分層：
- Original / Historical：**寒梅心法**
- ES2-KING 舊「冷梅心法」：只保留 compatibility alias。
- Expansion `lengmei_d.c` 已正名；尚需 Neolith Runtime 最小驗證後才可關閉 naming conflict。

## 5. 冷梅莊人物關係

### 梅影風
- 冷梅莊莊主／門派掌門／武者師父。
- 歷史裝備名稱：銀霜鎧、奔雲靴、梅花白襖、流雲清玉帶、白玉戒指、寒霜劍、冰雪匕。
- 只確認名稱／關係；裝備 stats、Object Path、掉落率仍未知。

### 梅嵐武
- 梅影風長子。
- 冷梅莊接班人。
- Archived Source 明示冷梅劍法承自其父。

### 楊子陵
- 冷梅派第一代弟子排行第四。
- 歷史人物背景：由梅影風收養。
- 歷史文字出現「真冷梅劍法」。

關係：
```text
冷梅莊
└─ 梅影風
   ├─ 長子／接班人：梅嵐武
   └─ 收養／第一代弟子：楊子陵
```

## 6. 明鏡止水正式定位

**明鏡止水不是直接攻擊招式。**

ES2-KING 正式定位：
- 特殊戰鬥狀態／Form／State Enhancement。
- 玩家啟動一次後進入 ON 狀態。
- Combat Engine 每回合從已確認招式池自動選招。
- 同一招可重複。
- 狀態結束後回到一般冷梅劍法戰鬥。

流程：
`寒梅心法 + 冷梅劍法 → Combat → 明鏡止水 ON → 自動選招 → 狀態結束 → 一般冷梅劍法`

正式六招：
1. 梅二方劍
2. 梅四方劍
3. 梅八方劍
4. 愛霜恨雪
5. 寒霜三千里
6. 傲梅暗劍訣

仍 UNKNOWN：傷害倍率、命中／爆擊、持續時間、內力成本、權重、啟動機率等數值。

## 7. PIXNET 冷梅歷史任務／進階鏈

目前回收到的歷史鏈：

`古大叔 → 楊子陵 → 雪山神秘洞穴 → 千年白蟒 → 蛇膽 → 榮府歐陽鐘 → 九轉冰心丹 → 梅夫人 → 寒梅玉珮 → 梅影風 → 冷梅劍法真諦 → 膽識 +2`

進階冷梅劍士相關五項武功：
- 冷梅劍法
- 傲梅暗劍訣
- 梅影身法
- 七巧如意手
- 寒梅心法

這五項與實際 Skills Evidence 高度交叉吻合。

### 寒梅玉珮
Historical Gameplay Evidence：
- 冷梅劍法 +10
- 傷害力 +5
- 傲梅暗劍訣 +10

Object LPC 未回收前，不升級成 CONFIRMED_RUNTIME。

## 8. 封山派

人物鏈：
```text
柳東蘆
├─ 柳淳風
├─ 柳新雨
└─ 柳繪心
```

已掌握：
- 柳東蘆：封山劍派掌門、前武林盟主。
- 柳淳風／柳新雨：風雨雙劍／風雨雙俠歷史關係。
- PIXNET 保存封山進階條件、劍氣／劍芒／劍心／劍神、劍宗／氣宗、棄劍石、水雲劍法等歷史線索。
- 不與冷梅莊武學混用。

## 9. Vovo2000 世界觀補完

已確認 Archived Historical Content：
- 故事起點：雪亭鎮。
- 主線涉及：嵐城、旋芒寶劍、穿靈寶劍、寒於寶衣、侮天鬼、杞庸／金色烏鴉。
- 十三精靈：金烏、銀蟾、大鵬、天龍、澤獸、鳳凰、赤魈、青蛛、濁魚、旱魃、穹氤、域摩、區冥。
- 分類：六神、四鬼、三靈。
- 區冥轉世與其百名子女／世界種族祖先的歷史敘述亦有保存。

因此「雪亭鎮」已由模擬名稱提升為 **CONFIRMED_TEXT 的歷史故事起點**。

仍 UNKNOWN：
- 真實 Room Path。
- 完整 Room Tree。
- exits。
- NPC spawn／clone。
- 出生點。

## 10. Lifecycle：死亡／陰間／輪迴

現有 Runtime 已確認：
- 昏迷／revive。
- die／corpse。
- ghost 再死亡。
- Temple `enter` → make_living。
- 在線年齡。
- 登入死亡補查。

Vovo2000 新增 Historical Evidence：

```text
死亡
↓
鬼魂
↓
陰間
↓
城隍爺
↓
register
↓
往生／輪迴
```

並保存：
- 不完成程序可能成為孤魂野鬼的歷史描述。
- 地府鬼卒。
- 左國益／鬼城地氣塔塔頂守衛主將。

因此此流程「概念」已提升為 CONFIRMED_TEXT；但城隍爺 LPC、`register` command LPC、Room Path、Flags、費用、輪迴公式、能力重置仍 SOURCE_REQUIRED。

## 11. 種族交叉證據

Vovo2000 人物資料支持：
- 劉乙忘玄 = 厭火族。
- 田由 = 形天族。
- 黃天霸 = 夜叉族。
- 韓夫人 = 夜叉族。

「田由 = 形天族」再次證明 Historical Original display 曾使用「形天」。

分層規則：
- Original Evidence：保留「形天」原文。
- ES2-KING Owner Canon：正式主名稱「刑天」。
- 不互相覆寫。

仍保留歷史衝突：
- blackteeth 業力 3 vs 5。
- yaksa 業力 35 vs 30。
- 人類族 Original ID 尚未確認；`human_clan` 只屬 Reconstruction ID。

## 12. 舊 ES2-KING MOD 資料隔離

舊聊天／文字檔曾產生非常完整但屬 Reconstruction／Expansion 的內容，例如：
- 梅影風 HP 6500。
- 自建 `/d/lengmei/npc/meiyingfeng.c`。
- 自建萬梅晴雪閣。
- 傲霜凝冰訣 Lv.280。
- 35% 極寒冰甲。
- 冷梅傲雪劍及自行設定特效。
- 冷梅劍衛 HP、King 免傷等模擬戰鬥數值。

這些資料不得因為描述完整而升級為 Original Evidence。

固定規則：
**Actual Original Source / Gameplay Evidence 優先；Reconstruction / Expansion 永遠分層。**

## 13. 目前真正 Evidence 缺口

### 高優先
1. 冷梅莊 Original Room/NPC LPC Path。
2. 梅影風 Original NPC LPC。
3. 梅影風完整 `set_skill / map_skill`。
4. 冷梅莊真實 Room Tree／exits。
5. 冷梅任務真正 Flags／NPC trigger／reward LPC。
6. 城隍爺／`register` LPC。
7. 人類族 Original Race ID。
8. 遺失 Race Initializer。
9. blackteeth 3/5、yaksa 30/35 版本來源收斂。
10. 實際影片 Login／Create Character 精確 Prompt／Output。

### 不應再用猜測補足
- NPC HP／屬性。
- 掉落率。
- Combat coefficients。
- Quest reward formula。
- Reincarnation formula。
- Historical room paths。

## 14. Evidence → Game Completion 邊界

Evidence Recovery 不再阻塞目前 Playable Core。

目前真正需要 Runtime execution proof 的 Game Completion Journey：

`Connect → Login → Character → Enter World → Look → Score → Inventory → Movement → NPC → Items/Equipment → Combat → Skills → School/Apprentice → Save → Quit → Relogin`

其中 Full Driver 五段核心：
`NPC → Items/Equipment → Combat → Skills → School/Apprentice`

Runtime Evidence Head `07b865ce4a8ac9689e64580cc605f045e5cea0aa` 已以真正 Neolith Driver 完成單一完整 Journey；NPC、Items / Equipment、Combat、Skills、School / Apprentice、Save / Quit / Relogin 全部為 RUNTIME PASS（真實執行環境通過），Full Driver Runtime Gate（完整 Driver 執行關卡）為 PLAYABLE PASS（實際可遊玩驗收通過）。

此 Runtime 結果不改寫 Evidence 層：Historical Evidence（歷史證據）與 Original Source（原始來源）仍依來源等級判定；Runtime PASS 不會把未證實的 Original 史實提升為 CONFIRMED。

Quest 若目標 Original Evidence 不足，維持 UNKNOWN，不為了提高完成度自行補造。Public Compatibility（公開環境相容性）與 Render（外部部署）本階段均為 PENDING / NOT TESTED（待驗證／未測試）。

## 15. Master 結論

目前已能穩定串聯：
- 實際遊戲影片 → UI／操作／歷史 Gameplay。
- 梅影風實機 Skills → Skill Name／ID／acquire。
- PIXNET → 冷梅武學、進階、任務、裝備、封山等 Historical Gameplay。
- Vovo2000 → NPC、人物關係、門派、裝備、種族、World Lore、Lifecycle。
- 舊文字／MOD → 嚴格隔離為 Reconstruction／Expansion。

後續每批新資料固定走：
**New Evidence → Source Classification → Existing Gap Comparison → Conflict Check → Registry Update → Runtime Usability → Minimal Runtime Gate**。

不得以 Static／Historical Evidence 冒充 Runtime PASS。
