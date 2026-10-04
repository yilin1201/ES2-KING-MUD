# ES2-KING-MUD 資料來源庫

本文件記錄 ES2-KING-MUD 專案研究《東方故事2：天朝帝國》
（Eastern Stories 2 / ES2）時使用的資料來源。

## 建立目的

1. 保存 Original ES2 的歷史資料與原始設定。
2. 維持 Annihilator 原始 ES2 的世界觀與系統架構。
3. 區分原作、歷史資料、衍生版本、玩家記憶與 ES2-KING 新創內容。
4. 所有重要設定盡可能保留可追溯來源。
5. 避免 AI 將推測或後期衍生內容誤認為 Original ES2。
6. Original ES2 重建完成後，再逐步加入 ES2-KING Expansion。

---

# 1. Annihilator / Original ES2 Mudlib

來源類型：

[Confirmed]

重要性：

最高優先等級 Original ES2 資料來源。

主要用途：

- ES2 Mudlib 原始架構
- Race 種族
- Attribute 天生屬性
- Health 精、氣、神等生命數值
- Skill 技能
- Martial Arts 武學
- Combat 戰鬥
- Class 職業
- Guild / Clan 門派
- Weapon 武器
- Armor 防具
- NPC
- World / Map 世界與地圖
- Quest 任務
- Lifecycle 角色生命週期
- Commands 指令
- 遊戲系統公式
- 原始程式邏輯

研究原則：

凡可由 Annihilator 原始 Mudlib、原始程式碼或原始文件
直接確認的內容，優先視為 Original ES2 的最高等級證據。

如果其他資料與 Original ES2 Mudlib 發生衝突，
原始碼與原始文件優先。

---

# 2. ES2 Mudlib GitHub 原始碼

已知重要來源：

taedlar / es2_mudlib

來源類型：

[Confirmed]

已知資訊：

- ES2 為 Annihilator 等人建立的 LPMud。
- 早期 ES2 Mudlib 曾公開發布。
- 可追溯 ES2 Mudlib v1.3b 等歷史版本。
- 後續另有 UTF-8 與較新維護版本。
- 不同年代版本可能存在程式與內容差異。

使用原則：

研究 Original ES2 時，
應記錄所使用的 Mudlib 版本。

不得因新版程式存在某項設定，
就直接假定所有歷史 ES2 版本皆具有相同內容。

---

# 3. ES2 Mudlib 原始文件瀏覽站

來源：

es2.xor.tw

來源類型：

[Confirmed / Archived]

用途：

查詢 Original ES2 Mudlib 文件、
系統分類、技能背景與歷史程式資料。

目前已發現的文件分類包含：

- health
- skill
- race
- rank
- guild
- class
- damage
- combat
- weapon
- armor
- martial
- magic
- lifecycle
- taoist
- alchemist
- stats
- attribute
- soldier
- thief
- scholar
- clan
- story
- world
- sheol
- theme
- history
- myth

目前文件中已確認的 Race ID 至少包含：

- human
- woochan
- jiaojao
- yenhold
- rainnar
- ashura
- headless
- yaksa
- blackteeth

已發現的技能或系統相關名稱包含：

- alchemy
- celestial
- chaos-steps
- chivi
- essencemagic
- fonxansword
- iceforce
- lotusforce
- necromancy
- perception
- six-chaos-sword
- tiger_force
- taoism-fire
- taoism-freeze
- taoism-storm

以上名稱後續仍需逐項追查實際程式、
中文名稱、使用條件與所屬版本。

---

# 4. ES2 歷史資料站

來源：

Google Sites - es2mud

網站：

https://sites.google.com/site/es2mud

來源類型：

[Archived]

主要用途：

- Original ES2 世界觀
- 創世神話
- 故事背景
- 主線任務
- 職業
- 門派
- 門派分支
- 武學
- 技能
- NPC
- 任務
- 遊戲公式
- 玩家保存資料
- 歷史攻略

此網站為 ES2 歷史資料的重要保存來源。

但是：

如果內容與 Annihilator Original ES2 Mudlib
或原始文件衝突，

以 Original Source Code / Documentation 為優先。

---

# 5. 東方故事2 天朝帝國 Wikipedia

來源：

中文 Wikipedia
《東方故事2 天朝帝國》

來源類型：

[Archived / Reference]

主要用途：

- ES2 歷史
- 開發背景
- Annihilator
- Mudlib 發展歷史
- ES2 公開原始碼歷史
- 版本資訊
- 相關人物與技術背景

Wikipedia 適合作為歷史索引與線索來源。

但是：

Wikipedia 不作為遊戲公式、
技能數值或種族能力的最高證據來源。

若 Wikipedia 與 Original Source Code 發生衝突，
以 Original Source Code 為準。

---

# 6. 其他 ES2 原始碼保存計畫

已知可能來源包含：

- MudRen ES2-big5（已核對歷史版本；使用清單： [MudRen 安全補充與差異考證](evidence/supplemental/mudren_es2_big5_reuse.md)）
- MudChina ES2
- ES2 UTF-8
- FluffOS / MudOS 相容版本
- 其他歷史 ES2 Mudlib Mirror

來源類型：

[Confirmed / Archived / Variant]

研究時必須確認：

1. 原始碼來源。
2. Mudlib 版本。
3. 是否由 Annihilator 原始版本直接演進。
4. 是否存在後續維護者修改。
5. 是否加入非 Original ES2 的內容。

不同 Repository 不得在未比對前直接視為完全相同版本。

---

# 7. ES2 北美版本

名稱：

東方故事II（北美版）
天朝遊俠傳

已知舊資料站：

kango.fortunecity.ws

來源類型：

[Variant-US]

目前已知資料類型包含：

- 基礎地理地圖
- 故事由來
- 門派
- 功夫
- Quests 任務
- 師父技能檔案
- 武功招式名稱
- 遊戲連接相關資訊

重要規則：

北美版本可能已經修改、
擴充或重新設計部分 Original ES2 內容。

因此：

北美版本資料不得直接標示為：

[Confirmed]

若北美版本存在 Original ES2
目前尚未找到的內容，

首先標記：

[Variant-US]

然後再與以下來源交叉驗證：

- Annihilator Mudlib
- Original ES2 Documentation
- es2.xor.tw
- ES2 歷史資料站
- 其他 Original ES2 原始碼

如果最後證實原版確實存在，
才可以提升為：

[Confirmed]

如果確認只有北美版存在，
則永久保留：

[Variant-US]

---

# 8. 專案擁有者 Original ES2 遊玩記憶

來源類型：

[Player Memory]

專案擁有者曾實際遊玩 Original ES2。

玩家記憶可以作為：

- 尋找原始碼的線索
- 找尋技能名稱
- 找尋種族能力
- 找尋任務
- 找尋 NPC
- 找尋歷史遊戲機制

但是在找到原始資料驗證之前，
不得自動升級為 [Confirmed]。

---

# 9. 目前 Original ES2 種族記憶

目前已知對應：

human = 人類

headless = 刑天

rainnar = 雨師妾

blackteeth = 黑齒

woochan = 無腸

jiaojao = 焦僥

yenhold = 厭火

ashura = 修羅

yaksa = 夜叉

其中 Race ID 的存在可由 Original ES2 文件進一步驗證。

中文名稱與詳細能力仍應逐項建立證據。

---

# 10. 焦僥玩家記憶

Race ID：

jiaojao

中文名稱：

焦僥

目前記憶：

焦僥適合發展盜賊／小偷相關職業。

目前證據：

[Player Memory]

另外歷史 ES2 資料中存在
盜賊相關種族適性線索。

後續需要確認：

- 天生屬性
- 身法
- 定力
- 警覺
- Backstab
- Thief Class
- 是否存在種族加成

在找到原始程式公式之前，
不得自行建立數值。

---

# 11. 厭火玩家記憶

Race ID：

yenhold

中文名稱：

厭火

目前記憶：

厭火具有消耗精力進行噴火的種族能力。

目前證據：

[Player Memory]

後續需要確認：

- 原始能力名稱
- 使用指令
- 消耗 Gin / Kee / Sen / Force 中何種數值
- 傷害公式
- 冷卻或限制
- 等級需求
- 是否受到天生屬性影響

以上內容在原始碼確認之前，
不得自行建立公式。

---

# 12. 雨師妾玩家記憶

Race ID：

rainnar

中文名稱：

雨師妾

目前記憶：

雨師妾隨身具有養蛇相關能力。

玩家記憶中：

可以使用自己的血進行養蛇／煉蛇。

目前證據：

[Player Memory]

後續需要確認：

- Snake 是否為 Race Object
- 是否存在專屬 NPC / Pet
- 養蛇指令
- 煉蛇機制
- 是否消耗 Kee
- 蛇的成長機制
- 戰鬥能力
- 死亡處理
- 是否可召回
- 是否存在蛇的不同階段

在取得 Original ES2 程式證據前，
保持 [Player Memory]。

---

# 13. Original ES2 角色基礎架構

目前研究方向：

Character
│
├── Race 種族
├── Attribute 天生屬性
├── Health 精氣神等數值
├── Class 職業
├── Guild / Clan 門派
├── Branch 門派分支
├── Basic Skills 基礎技能
├── Special Skills 特殊技能
├── Martial Arts 武學
├── Enable / Map 技能激發
├── Combat 戰鬥
└── Lifecycle 角色生命週期

此架構後續應以 Original ES2 Mudlib
逐項驗證與修正。

---

# 14. 已知核心天生屬性

目前角色畫面與歷史資料顯示：

- Str：力量
- Con：體魄
- Dex：身法
- Int：悟性
- Wis：慧根
- Cor：定力

後續需要從 Original ES2 Source Code 確認：

- 初始產生公式
- 種族修正
- 職業影響
- 成長方式
- 上下限
- 與精氣神的計算關係

---

# 15. 已知角色生命／能量數值

目前角色資料顯示：

- Kee：氣血
- Gin：精力
- Sen：神識
- Force：內力

後續需確認：

- 最大值公式
- 恢復公式
- Attribute 關係
- Class 成長公式
- Race 修正
- Skill 影響

---

# 16. 已知基礎技能系統

目前已知基礎技能包含：

- force
- sword
- blade
- unarmed
- parry
- dodge

Original ES2 使用：

Basic Skill
→ Enable / Map
→ Special Skill

例如：

sword
→ 特殊劍法

blade
→ 特殊刀法

dodge
→ 特殊身法

force
→ 特殊內功

後續應從 Original Source Code
確認完整 Skill Mapping 機制。

---

# 17. Original ES2 與 ES2-KING 的分界

本專案最重要的規則：

Original ES2
與
ES2-KING Expansion

必須永久保持可追溯的分界。

Original ES2：

只保存、研究、重建與修復。

ES2-KING：

在 Original ES2 基礎之上新增內容。

不得將 ES2-KING 新創內容
反向寫成 Original ES2 歷史設定。

---

# 18. ES2-KING Expansion

來源類型：

[ES2-KING Expansion]

此分類專門保存本專案後續新增內容。

可能包含：

- 新武學
- 新神兵
- 新門派
- 新 NPC
- 新 Boss
- 新種族
- 新任務
- 新地圖
- 新境界
- 新系統
- Original ES2 延伸劇情

所有新創內容必須標記：

[ES2-KING Expansion]

---

# 19. Variant 內容轉入 ES2-KING 的規則

如果北美版或其他 ES2 衍生版本
存在優秀設定，

可以考慮加入 ES2-KING。

但是必須保留來源，例如：

Original Source：

[Variant-US]

ES2-KING Status：

[ES2-KING Expansion]

這代表：

該內容受到北美版本啟發，
但現在正式成為 ES2-KING 的延伸內容。

不得改寫為 Original ES2。

---

# 20. 證據標記制度

## [Confirmed]

Annihilator 原始碼、
Original ES2 Mudlib、
原始官方文件或直接程式證據確認。

---

## [Archived]

ES2 歷史資料站、
保存網站、
歷史攻略或可靠舊資料。

---

## [Variant-US]

ES2 北美版本或其衍生內容。

---

## [Player Memory]

專案擁有者實際遊玩 Original ES2 的記憶。

---

## [Unverified]

已有線索，
但尚未取得足夠證據。

---

## [ES2-KING Expansion]

ES2-KING 專案新增的原創內容。

---

# 21. 資料衝突處理順序

當不同來源發生衝突時：

Original Source Code

>

Original Documentation

>

Archived Original ES2 Data

>

Variant Versions

>

Player Memory

>

Unverified Information

不得為填補資料空缺
而自行創造 Original ES2 設定。

---

# 22. AI / Codex 研究規則

AI 或 Codex 處理 Original ES2 時：

1. 不得自行補完未知設定。
2. 不得把推測寫成事實。
3. 不得將 ES2-KING 新創內容混入 Original ES2。
4. 找不到證據時標記 [Unverified]。
5. 玩家記憶標記 [Player Memory]。
6. 北美版本標記 [Variant-US]。
7. 找到原始碼後才升級為 [Confirmed]。
8. 修改 Original ES2 前應先理解原始程式架構。
9. 優先保存原始行為，再考慮現代化修改。
10. 所有重大考證應盡可能記錄來源。

---

# 23. 專案最高原則

Original ES2 是 ES2-KING 的根。

本專案的順序是：

保存 Original ES2

↓

研究 Original ES2

↓

理解 Annihilator 架構

↓

重建 Original ES2

↓

驗證角色、技能、戰鬥與世界系統

↓

最後才加入 ES2-KING Expansion

ES2-KING 的目的不是取代 Original ES2，

而是在尊重 Original ES2 的基礎上，

讓這個世界繼續發展。
