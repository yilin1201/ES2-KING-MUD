# ADMIN／GM 指令原版限制與來源紀錄

## 分類

- 本指令程式：**[ES2-KING Expansion]**，以 ES2-KDS 的 `cmds/adm/admin.c` 為參考改編。
- 下列數值範圍：**[Confirmed — Original ES2 source]**，直接核對 Annihilator 的 `taedlar/es2_mudlib` 原始碼。
- 不將 ES2-KDS 的 GM 指令本身描述為 Original ES2 原生指令。

## 已核對限制

| 項目 | 原版範圍 | 原始碼證據 |
|---|---:|---|
| 八大屬性 | 1～50 | [`include/attribute.h`](https://github.com/taedlar/es2_mudlib/blob/main/mudlib/include/attribute.h) 定義 `ATTRVAL_MIN=1`、`ATTRVAL_MAX=50`；[`feature/attribute.c`](https://github.com/taedlar/es2_mudlib/blob/main/mudlib/feature/attribute.c) 對玩家物件拒絕超界數值。 |
| 技能等級 | 0～200 | [`feature/char/skill.c`](https://github.com/taedlar/es2_mudlib/blob/main/mudlib/feature/char/skill.c) 的 `set_skill()`、`query_skill()`、`advance_skill()` 均以 200 為上限。 |
| 角色等級 | 1～999 | [`feature/char/score.c`](https://github.com/taedlar/es2_mudlib/blob/main/mudlib/feature/char/score.c) 的 `set_level()` 拒絕小於 1 或大於 999 的數值。 |

## 八大屬性中文名稱

依 Original ES2 的 [`cmds/std/identify.c`](https://github.com/taedlar/es2_mudlib/blob/main/mudlib/cmds/std/identify.c)：

- `str`：膂力
- `cor`：膽識
- `cps`：定力
- `int`：悟性
- `wis`：慧根
- `spi`：靈性
- `con`：根骨
- `dex`：機敏

## 驗證界線

本文件只記錄可由原始碼直接確認的數值規則與名稱。HP、精／氣／神最大值仍須依實際 stat API 和 Runtime 行為另行驗證；不因範例數字而宣稱其為原版上限。LPC 編譯與遊戲內實測結果另記，不由靜態檢查代替。
