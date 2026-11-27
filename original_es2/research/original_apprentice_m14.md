# M14 Original ES2 師徒／拜師系統考證基線

> 階段：M14。原則：先保存與確認 Original ES2 證據，再做 Runtime 重建；不得以 ES2-KING 擴充設定冒充 Original。

## 已確認證據

### 1. Original 文件明確存在 apprentice 功能

`docs/legacy/mudlib/feature/apprentice` 明確記錄：

- `is_apprentice_of(object ob)`：判定指定物件是否為傳入物件的弟子。
- `assign_apprentice(string title, int privs)`：設定門派地位與抬頭；文件記錄 `-1` 為掌門人、`0` 為弟子。
- `create_family(string family_name, int generation, string title)`：建立門派資料 mapping，並把指定物件設定為掌門人。
- `recruit_apprentice(object ob)`：把傳入物件設定為指定物件的弟子並建立相關資料。

因此「門派／師徒」不是 ES2-KING 新創機制，而是 Original ES2 Mudlib 已有的正式功能概念。

### 2. Original 玩家拜師指令已確認

`mudlib/cmds/std/apprentice.c` 保存了真實玩家指令：

- 語法：`apprentice <某人>`。
- 只能拜同一房間中存在、且屬於 character 的目標。
- 不能拜自己為師。
- 已經是對方弟子時會拒絕重複拜師。
- 目標必須是 living 狀態。
- 師父 NPC 透過 `accept_apprentice(me)` 決定是否接受玩家。
- 接受後會顯示玩家跪下磕四個響頭、叫「師父」的 Original 訊息。
- 最後由 NPC 執行 `init_apprentice(me)` 建立師徒關係。

### 3. Original 師徒關係資料結構已確認

`mudlib/feature/char/relation.c` 保存了師徒關係實作：

- `masters` mapping 保存師父。
- `apprentices` mapping 保存弟子。
- 關係識別鍵為 `id + "#" + birthday`，因此同名／角色身分仍以生日欄位共同識別。
- `is_master_of()` / `is_apprentice_of()` 判定雙方關係。
- `add_master()` / `add_apprentice()` 會同步建立雙向關係。
- `delete_master()` / `delete_apprentice()` 會同步解除雙向關係。
- 預設 `init_apprentice(object ob)` 直接呼叫 `add_apprentice(ob)`；NPC 可以 override／覆寫此函式加入額外初始化。
- `accept_apprentice(object ob)` 是拜師確認介面，由可收徒 NPC 自行定義是否接受。

### 4. 師徒關係會影響 Original 遊戲功能

現存 Original 程式另有交叉證據：

- `acquire.c` 在玩家向師父求傳技能時，會使用 `is_apprentice_of()` 判斷師徒關係並顯示師徒專用訊息。
- `skills.c` 允許師徒雙方查看彼此技能。
- `fight.c` 會阻止玩家直接向自己的師父挑戰。
- `d/snow/npc/alchemist.c` 的技能教學會檢查玩家是否為該 NPC 弟子。

這表示師徒 mapping 並非孤立資料，而是 Original 戰鬥、技能學習與資訊權限的一部分。

### 5. Original 巫師文件確認玩家流程包含拜師與學武功

`docs/legacy/wiz/quest` 以玩家遊戲流程舉例，直接提到新玩家會詢問「怎樣升級、拜師、學武功」。這可作為歷史玩法存在性的第二層證據。

## 尚未確認

目前仍不得自行補造：

- 七大職業各門派所有師父 NPC 的完整名單與精確拜師條件。
- `family_name`、`generation`、`title` 與現存 `relation.c` 雙向師徒 mapping 在不同 Original 版本間的完整演變關係。
- 離師、叛師、改投其他門派的完整規則。
- 各門派拜師後自動授予的技能、稱號、屬性或裝備。

## M14 Runtime 重建策略

1. 保存 Original `apprentice` 玩家指令，不修改證據層原始碼。
2. Runtime-only 建立一名最小測試師父 NPC，僅實作 `accept_apprentice()`，讓真正的 Original `apprentice.c` 與 `relation.c` 負責建立關係。
3. 真實玩家執行 `apprentice <師父>`，確認 `is_apprentice_of()` 與師父端 `is_master_of()` 同時成立。
4. 玩家 `quit → relogin` 後重新驗證師父關係保存；若 NPC 端關係不屬永久保存資料，不把 NPC 重啟後狀態誤判為玩家存檔失敗。
5. 再以 `acquire`／技能學習或師徒技能查看權限做第二層交叉驗證。
6. 通用 Runtime 閉環 PASS 後，再進 M15 冷梅莊實際師父與武學串接。

## 與 M15 冷梅莊的銜接

M11 已確認 `fighter.lunmay` 對應冷梅莊；既有 Original 證據亦已鎖定梅影風／劉乙忘玄。M14 的通用師徒資料結構完成後，M15 優先以冷梅莊作為第一個完整「門派 → 師父 → 玩家拜師 → 武學」串接案例。
