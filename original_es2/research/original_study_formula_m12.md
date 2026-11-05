# M12 Original `study`／`improve_skill` 精確公式

> 證據標籤：`[Confirmed Source]`
> Original 基準：`taedlar/es2_mudlib` commit `cc45c06af4852380e5148dad3c9d53ff06854f2c`

## 1. 研讀成本

Original `feature/study.c`：

```text
cost = 1 + (9 - wis / 3)
最低 cost = 1
```

若研讀內容要求 `archaic attainment`（古文造詣），則研讀成本再乘 2。

研讀每次執行都需要：

- `sen`（神）至少等於 cost。
- `gin`（精）至少等於 cost。
- `fatigue`（疲勞）尚未達最大值。

通過後會先消耗相同 cost 的精與神。

## 2. 理解能力與學習點

一般研讀：

```text
skill = literate
point = int / content_count
```

其中 `literate` 是讀寫能力，`int` 是悟性，`content_count` 是書中技能項目數量。

若要求古文造詣：

```text
skill = literate / 10 + archaic attainment
```

每個技能項目的書本上限 `max` 若高於理解能力 skill，實際判定 max 會先降到 skill。

## 3. 成功判定

只有角色目前 raw skill（原始技能等級）低於該書 `content[t]` 上限時才有學習機會。

Original 成功條件：

```text
random(point + skill) >= max / 2
```

成功後：

```text
improve_skill(target_skill, 1 + random(point))
```

因此 Runtime 測試不可硬寫「study 一次必定增加固定 X 點」。測試必須處理 Original 隨機機制。

## 4. 成功研讀後的附加成長

只要本輪至少一個內容技能成功：

- `literate` 也會 `improve_skill(1 + random(int))`。
- 若要求古文造詣，`archaic attainment` 同樣會增加學習進度。
- 疲勞增加成功技能項目數 `gain`。
- 神另外受到 `gain` 點 damage。

## 5. `improve_skill()` 真正行為

Original `feature/char/skill.c` 證明 `improve_skill()` 增加的是 `learned[skill]` 學習進度，不是直接把技能等級加一。

基礎 amount 若為 0 會改成 1，之後加入角色等級隨機加成：

```text
amount += amount * random(level / 8)
```

然後：

- 累加 `learned[skill]`。
- 累加本輪 `skill_gain[skill]`。
- 若技能尚不存在，先建立技能等級 0。
- 呼叫 `SKILL_D(skill)->skill_improved(...)` 讓該 Skill Daemon（技能守護程式）處理後續升級規則。

## 6. M12 Runtime 測試策略

為避免把隨機結果誤判為 FAIL，Runtime-only（僅執行期）研讀夾具應：

1. 使用單一 `content` 技能，避免 `int / content_count` 被多項內容分散。
2. 準備足夠的 `literate`、精、神與疲勞空間。
3. 記錄 study 前的 raw skill 與 `query_learn()`。
4. 玩家真正執行 `study <物品>`，而不是直接呼叫 `set_skill()`。
5. 允許重複研讀至 `query_learn()` 明確增加，並設定有限次數避免無限迴圈。
6. quit → relogin 後再次讀取 raw skill 與 `query_learn()`。
7. 重新登入後資料必須與離線前一致，才算 Persistence（持久化）PASS。

## 7. 證據邊界

本文件只鎖定 Original 原始碼可直接證明的公式。特定武學需要多少 learned 才升級，仍由各自 `SKILL_D(skill)->skill_improved()` 決定；沒有讀到對應 Skill Daemon 前，不建立通用升級門檻。
