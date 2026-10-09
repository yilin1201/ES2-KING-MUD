# 刑天 / Headless — Original ES2 考證檔

> Original ID：`headless`
>
> 本檔案只保存 Original ES2 的可追溯資料、歷史資料與待驗證項目。
> ES2-KING 新創設定請見 `es2_king_expansion/races/headless.md`。

---

## 1. 基本資料

| 項目 | 內容 | 狀態 |
|---|---|---|
| Original ID | `headless` | [Confirmed] |
| Original ES2 Race | 存在 | [Confirmed] |
| 專案統一中文名稱 | 刑天 | [ES2-KING Naming] |
| 歷史資料常見異名 | 形天 | [Archived] |

`headless` 的存在已由 Original ES2 文件索引確認。

ES2-KING 專案中文名稱統一使用「刑天」。歷史資料若出現「形天」，保留原文作為異名與搜尋關鍵字，不取代專案主名稱。

---

## 2. 歷史資料線索

[Archived]

目前保存的 ES2 歷史資料曾以「形天 / headless」記錄此種族，並存在與形天相關的裝備、武器詞綴與 NPC 種族線索。

這些資料只能證明歷史版本中存在相關內容；在取得對應 Original Source Code 前，不直接推導成種族屬性或能力公式。

---

## 3. 神話原型

[Mythology Reference]

《山海經・海外西經》存在刑天／形天相關神話：失首後仍以乳為目、臍為口，持干戚而舞。

神話資料只作為名稱與文化原型參考，不等同於 Original ES2 的遊戲機制。

---

## 4. 天生屬性

[Unverified]

待確認 Original ES2 中 `headless` 的：

- str 臂力
- cor 膽識
- int 悟性
- spi 靈性
- cps 定力
- dex 機敏
- con 根骨
- wis 慧根
- 屬性生成公式
- 種族 Bonus / Penalty

不得使用 ES2-KING 的設計值反推 Original ES2。

---

### 第三方重建資料 [Archived／第三方重建]

來源：wolfer168/es2-webmud `source/upstream/mudlib/daemon/race/headless.c`
（檔頭註明 CUSTOM A-H RACE，依使用者提供之 2006-09-15 原始種族資料；尚未對照 Original 原始碼）

| 屬性 | 初始值 |
|---|---|
| str 臂力 | 25 + random(6) |
| cor 膽識 | 15 + random(6) |
| int 悟性 | 8 + random(6) |
| spi 靈性 | 5 + random(6) |
| cps 定力 | 11 + random(6) |
| dex 機敏 | 19 + random(6) |
| con 根骨 | 23 + random(6) |
| wis 慧根 | 13 + random(6) |

- 精／氣／神初始值：80 / 100 / 30
- karma 25；commoner_score_base 160
- 職業等級上限：commoner 1、fighter 65、taoist 40、alchemist 40、soldier 60、scholar 50、thief 50、monk -1（意義待確認）
- 無頭無頸：不可穿 armor、cloth、head_eq、neck_eq 類護具

## 5. Health / Resource

[Unverified]

待確認：

- Kee 氣血
- Gin 精力
- Sen 神識
- Force 內力
- 是否存在種族修正
- 是否存在特殊恢復機制

---

## 6. 特殊能力與指令

[Unverified]

目前尚未取得足夠 Original Source Code 證據確認刑天是否具有專屬主動能力、被動能力或特殊 Command。

---

## 7. 職業、武器與門派限制

[Unverified]

待確認：

- Class 職業限制
- Guild / Clan 門派限制
- Weapon 武器限制
- Skill Bonus
- Combat Bonus

---

## 8. 業力與創角條件

[Archived]

後期歷史玩家資料曾記錄 `headless`／形天的轉生業力需求為 25。

此資料屬歷史版本記錄，不直接視為所有 Original ES2 版本的固定值；仍需版本與原始碼交叉驗證。

---

## 9. 待考證清單

- Original Race daemon / source file
- 中文名稱在原始遊戲中的正式顯示
- 八大 Attribute 公式
- Kee / Gin / Sen / Force 公式
- 特殊能力與 Command
- 武器、職業、門派限制
- 學習速度是否有種族修正
- 業力與創角條件的版本差異
- Lifecycle / Death 特殊機制

---

## 10. Preservation Rule

本檔案只負責 Original ES2：

**保存 → 考證 → 重建 → 驗證**

以下內容不得寫回本檔案作為 Original ES2 事實：

- ES2-KING 的高力量／高體魄／高定力設計
- ES2-KING 的低悟性設計
- ES2-KING 的 60% 學習速度
- ES2-KING 的直接選角規則
- ES2-KING 的武器／職業開放規則

上述設計統一保存於：

`es2_king_expansion/races/headless.md`
