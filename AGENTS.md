# ES2-KING-MUD — AGENTS.md

## 1. 專案核心目標

本專案名稱為 ES2-KING-MUD。

專案第一目標是保存、研究、整理並盡可能重建
《東方故事2：天朝帝國》（Eastern Stories 2 / ES2）
原始遊戲的世界觀、系統與遊戲內容。

原始 ES2 內容與 ES2-KING 新創內容必須嚴格區分。

不得為了補齊資料而自行改寫、推測或創造原始 ES2 設定。


## 2. Original ES2 原作優先原則

Original ES2 包含但不限於：

- 世界觀與神話
- Race 種族
- Attribute 天生屬性
- Health 精、氣、神、內力
- Class 職業
- Clan / Guild 門派
- Skill 技能
- Martial Arts 武學
- Enable / Map 技能激發
- Combat 戰鬥
- Weapon 武器
- Armor 防具
- NPC
- Map / World 地圖與世界
- Quest 任務
- Lifecycle 角色生命週期
- Story 劇情
- Original Commands 原始指令

處理上述內容時，應優先查證原始資料，不得自行補完。


## 3. 原作證據優先順序

資料可信度依下列順序判斷：

1. Annihilator / ES2 原始 Mudlib Source Code
2. ES2 原始官方文件與程式內文件
3. ES2 歷史資料站與存檔
4. 可靠的舊玩家資料與攻略
5. 專案擁有者的原版 ES2 遊玩記憶
6. 尚未確認的網路資料

若不同來源互相衝突，以較高等級證據為優先。


## 4. 資料標記制度

所有考證資料應盡可能標示來源：

[Confirmed]
原始碼、Annihilator 文件或可靠官方資料確認。

[Archived]
ES2 歷史資料站、保存資料或可靠舊資料確認。

[Variant-US]
東方故事2北美版本資料。
僅供比較與參考，不直接視為 Annihilator Original ES2。

[Player Memory]
專案擁有者實際遊玩原版 ES2 的記憶。

[Unverified]
已有線索，但尚未取得足夠證據。

[ES2-KING Expansion]
本專案後續新增的原創內容。


## 5. 禁止 AI 擅自補完 Original ES2

如果 Original ES2 資料不足：

不得因為設定「看起來合理」就自行創造答案。

正確處理方式：

1. 保留原始資料。
2. 標記 Unverified。
3. 記錄目前找到的證據。
4. 等待後續原始碼或歷史資料驗證。

如果提出推測，必須明確標示為推測。


## 6. ES2-KING Expansion

ES2-KING 可以新增：

- 新武學
- 新神兵
- 新 NPC
- 新 Boss
- 新任務
- 新地圖
- 新門派
- 新種族
- 新境界
- 新系統

但是所有新增內容必須標記：

[ES2-KING Expansion]

不得將新創內容描述成 Original ES2。


## 7. Variant 版本

北美版或其他衍生 ES2 版本：

保存在 variants/ 之下。

若其中內容值得 ES2-KING 採用，
必須先標示其原始來源，再決定是否轉化為：

[ES2-KING Expansion]

不得直接覆蓋 Original ES2。


## 8. 修改原則

修改既有專案前：

1. 先閱讀相關程式碼與文件。
2. 優先沿用 Original ES2 架構。
3. 採取最小必要修改。
4. 不進行與任務無關的重構。
5. 不任意刪除 Original ES2 內容。
6. 不任意更換核心架構。


## 9. 安全原則

未經專案擁有者明確授權，不得：

- 大量刪除資料
- 覆蓋 Original ES2 資料
- Push
- Merge
- 正式部署
- 執行破壞性操作

不得將密碼、API Key、Token 或私人資料寫入 Repository。


## 10. 工作語言

與專案擁有者溝通時使用繁體中文與台灣常用詞彙。

專案擁有者為程式開發新手。

重要技術概念：

先使用白話中文解釋，
再補充必要的英文或專業術語。

需要專案擁有者手動操作時，
應說明：

在哪裡操作
→ 按哪裡
→ 輸入什麼
→ 正常應看到什麼。


## 11. 完成工作後回報

每次完成開發工作後，簡短回報：

1. 本次完成什麼
2. 修改哪些檔案
3. 執行哪些測試
4. 實際測試結果
5. 尚未驗證或存在的風險
6. 下一個最小合理步驟


## 12. 最高原則

Original ES2 是本專案的根。

先保存原作，
再理解原作，
再重建原作，
最後才在原作之上創造 ES2-KING。

任何新創內容不得污染 Original ES2 的歷史紀錄。
