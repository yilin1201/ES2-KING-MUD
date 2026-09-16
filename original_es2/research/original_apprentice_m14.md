# M14 Original ES2 師徒／拜師系統考證基線

> 階段：M14。原則：先保存與確認 Original ES2 證據，再做 Runtime 重建；不得以 ES2-KING 擴充設定冒充 Original。

## 已確認證據

### 1. Original 文件明確存在 apprentice 功能

`docs/legacy/mudlib/feature/apprentice` 明確記錄：

- `create_family(string family_name, int generation, string title)`：建立門派資料 mapping，並把指定物件設定為掌門人。
- `recruit_apprentice(object ob)`：把傳入物件設定為指定物件的弟子，並建立相關資料。

因此「門派／師徒」不是 ES2-KING 新創機制，而是 Original ES2 Mudlib 已有的正式功能概念。

### 2. Original 巫師文件確認玩家流程包含拜師與學武功

`docs/legacy/wiz/quest` 以玩家遊戲流程舉例，直接提到新玩家會詢問「怎樣升級、拜師、學武功」。這可作為歷史玩法存在性的第二層證據，但不等同於完整拜師條件或指令實作。

## 尚未確認

目前 upstream `taedlar/es2_mudlib` 保存版本中，尚未由本階段找到對應的 `mudlib/feature/apprentice.c` 實作檔；因此下列內容不得自行補造：

- 玩家實際拜師指令名稱與語法。
- 師父 NPC 接受／拒絕拜師的完整條件。
- generation（門派代數）、title（稱號）在玩家資料中的精確保存欄位。
- 七大職業各門派的師父 NPC 對應與入門條件。
- 離師、叛師、改投其他門派等規則。

## M14 重建策略

1. 先以 Original 文件鎖定 `create_family()` 與 `recruit_apprentice()` 的語意契約。
2. 搜尋現存 NPC、歷史來源與玩家紀錄，尋找 family／generation／title／apprentice 等實際使用證據。
3. 對已確認的七大職業與門派 ID 建立「職業 → 門派 → 師父 NPC → 拜師條件」證據表。
4. 若 Original 實作缺失，Runtime 重建只能建立相容層，並標記 `[ES2-KING Reconstruction]`，不得修改保存用途的 Original 原始碼。
5. Runtime 測試目標：真實玩家 → 師父 NPC → 拜師 → family 資料建立 → quit → relogin → 門派／師徒資料保存。

## 與 M15 冷梅莊的銜接

M11 已確認 `fighter.lunmay` 對應冷梅莊；既有 Original 證據亦已鎖定梅影風／劉乙忘玄。M14 的通用師徒資料結構完成後，M15 優先以冷梅莊作為第一個完整「門派 → 師父 → 玩家拜師 → 武學」串接案例。
