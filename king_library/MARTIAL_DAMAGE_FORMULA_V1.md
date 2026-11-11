# ES2-KING｜武學傷害參數與計算公式 V1

## 1. 本版決策

- **保留既有武學定義**：不得改動已建立武學的名稱、招式順序、招式敘述、顏色、招式輪替、原有特效、技能 ID、啟用／映射關係。
- 本文件是既有戰鬥引擎的公式與參數規格補全，不是重新平衡武學，也不代表所有武學已套用新係數。
- ES2M 上游公式作為本次參考來源；KING 自創武學係數仍標記為 **ES2-KING Expansion**，不得回標成 Original ES2。
- 本輪為生成 Runtime 加入可選 `damage_pct`／`no_armor` 參數處理；不修改任何既有武學定義、係數或招式資料。所有補丁只作用於生成 Runtime，Repository 內 Original ES2 來源保持不變。

## 2. 參數定義

| 參數 | 引擎欄位 | 真正用途 | 是否直接等於傷害 |
|---|---|---|---|
| 攻擊技巧加成 | `action["attack"]` | 加到攻擊技巧值，影響命中／防禦判定 | 否 |
| 內功招式係數 | `action["force"]` | 加到內功功力百分比，參與內力力道加成 | 否 |
| 防禦效果 | `action["defense"]` | 隨招式保存於 `last_action`，供對手下一次攻擊判定扣除 | 否 |
| 傷害倍率百分比 | `action["damage_pct"]` | 直接調整換算後的基礎傷害；缺省或非正值時按 100% 處理 | **是，傷害倍率** |
| 不扣防具 | `action["no_armor"]` | 命中時跳過一般護甲減傷 | 不增加基礎傷害，只取消此減傷步驟 |
| 元素類型 | `action["element"]` | ES2M 封存版本有元素追加傷害；本輪 KING Runtime 尚未啟用此參數 | **參考資料，尚未啟用** |

**重要：** attack、force、defense 不是三個可以直接相加的傷害數值。傷害倍率請使用獨立的 `damage_pct`；既有招式沒有該欄位時，維持原本 100% 行為。

## 3. 計算流程（依 ES2M 已封存戰鬥程式）

### A. 基礎攻擊力道

`base_strength = attacker.query_strength("attack")`

ES2M 角色戰鬥基礎力道（克）由屬性與當前氣值計算：

`attack_strength = str × cor × 150 + kee × 30`

這是 ES2M `feature/char/combat.c` 的來源公式；不同 Runtime 分支仍須以實際載入檔案為準。

### B. 內功加成

預設 `force_ratio = 75`（角色未設定或設定為 0 時）。當角色啟用內功時：

`force_bonus = force_skill × current_kee × (force_ratio + action_force) / 25`

- `force_skill`：啟用內功技能等級。
- `current_kee`：當前氣值（不是最大氣值）。
- `action_force`：招式的 `force` 係數。
- 玩家氣值不足時，來源引擎會按可用氣值比例縮減加成。
- 有足夠精力時，力道加成加入攻擊力道；精力不足時，引擎會消耗精力並降低攻擊技巧與力道。
- NPC／非玩家角色的精力分支依來源程式處理。

### C. 命中技巧

`attack_ability = query_ability("attack") + query_skill(attack_skill) + action_attack`

再扣除目標對相同攻擊技能的隨機熟練度影響，以及目標上一招的 `defense` 係數。最後由目標的 `defend()` 判斷閃躲／防禦；若招式明確指定 `must_hit`，則依引擎分支跳過一般閃躲與格擋判定。

### D. 格擋／吸收

未被閃躲時，先沿用目前 KING Runtime 的 Original `absorb()` 流程處理被吸收的力道。封存 ES2M 變體另有 `parry_result`／`parry_reduce` 整合，但本輪不移植該自訂招架系統，以免改變既有戰鬥行為。

### E. 力道換算為基礎傷害

ES2M 預設徒手換算式：

`raw_damage = 1 + floor(remaining_strength / 10000) + random(floor(remaining_strength / 10000))`

其中 `random(n)` 的結果是 0 至 n-1；力道不足以形成隨機區間時，該項為 0。再加上角色的 `apply/damage`。

**注意：** 若啟用的內功技能本身實作 `inflict_damage()`，原引擎可能改走內功自訂換算；若沒有該函式，ES2M 更新版已保存回退至通用徒手公式的修正。武器攻擊則由武器物件自己的 `inflict_damage()` 處理，不可假設所有武器與徒手都使用同一換算式。

### F. 傷害倍率與護甲

`scaled_damage = floor(raw_damage × damage_pct / 100)`

- `damage_pct` 缺省／非正值：使用 100%。
- 除非 `no_armor` 為真，否則再扣除目標 `resist_damage()` 所回傳的護甲減傷。
- 最終傷害小於 1 時，實際扣血為 0。
- 封存 ES2M 變體的元素追加傷害依 `damage_vs_element` 與 `armor_vs_element` 計算；此功能目前仍屬參考，不可將 `element` 寫入 KING 招式並期待它已生效。

## 4. 目前 KING 既有係數的處理方式

- 現有武學的 `attack`、`force`、`defense` 數值原樣保留。
- 如來神掌目前為既有 V1 自訂配置；冷梅劍法、傲梅暗劍訣、傲劍訣維持各自已記錄的版本與數值。不得為了讓公式看起來一致而批次改值。
- 生成 Runtime 現在支援可選的 `damage_pct` 與 `no_armor`，但本輪不對任何既有招式加入這些欄位；缺省倍率維持 100%，一般護甲照常計算。
- 後續如需新增傷害倍率，必須逐招指定、記錄原值／新值與測試結果；不得把文字敘事當成必中、破防或必殺效果。

## 5. 來源與可信度

1. **ES2M-derived WebMUD custom variant（本次公式參考）**：封存來源 HEAD `0948a4cb77fb5fe982d7fe09681791255db18253`。
   - [combatd.c](../source/es2m_updates/20261009_latest/source/upstream/mudlib/adm/daemons/combatd.c) — 攻擊技巧、內功加成、格擋、倍率與元素傷害流程。
   - [feature/char/combat.c](../source/es2m_updates/20261009_latest/source/upstream/mudlib/feature/char/combat.c) — 基礎力道、徒手傷害換算、護甲與實際扣血。
2. **KING 現有武學參數版本**：[`MARTIAL_DAMAGE_V0.md`](MARTIAL_DAMAGE_V0.md)、[`MARTIAL_DAMAGE_V1.md`](MARTIAL_DAMAGE_V1.md)。
3. KING Runtime adapter 只補上 `damage_pct`／`no_armor`，並保留 Original 的基礎攻擊、武器傷害骰、內功映射與吸收邏輯；元素追加傷害及封存變體的 `parry_reduce` 尚未移植。

## 6. 驗收邊界

- 靜態驗收可確認來源公式存在、參數語義有明確定義、已凍結武學招式資料未被本次修改。
- 靜態驗收**不能**取代 Neolith Driver／普通玩家隔離實戰測試。
- Runtime source gate 會確認生成 Runtime 的參數處理位置；這仍是靜態檢查，不宣告實戰傷害 E2E PASS。
