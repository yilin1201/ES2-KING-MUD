# ES2M 技能、防具與雪亭出口安全批次（2026-10-03）

## 證據與導入結果

- ES2M 來源固定為 `wolfer168/es2-webmud@e93dad172cb1472dae3eba0a2d1978c12b678985`。
- 原樣保存 `daemon/skill/beast.c` 與 `obj/example/skill/fonxansword.c`；前者註冊 `beast` 徒手技能並把動作委派給種族 daemon，後者是原始技能範例，未改寫其中 `damae` 拼字。野獸種族端是否已映射此技能仍須 Runtime 證據，因此只列部分導入。
- 91 件先前缺少的防具全部完成逐檔 SHA 比對後導入：hand 17、head 28、leg 9、neck 15、waist 22。加入原有 13 件後，五個部位共 104 件。
- 91 件新增防具沒有內容 SHA 重複。共同依賴是既有 `ansi.h`、`armor.h` 與五種裝備 feature；三件另用既有 `F_UNIQUE`，`corrosive_hands.c` 唯一額外物件依賴 `/obj/money/silver`，該檔已存在。
- `d/snow/sgate.c` 的 SHA 差異只有來源新增的 `southeast -> /d/oldpine/entrance`；來源同時保留 KING 已有的 `west -> /custom/zhenwu/room/gate`，因此不會覆蓋振武接線。本批採用來源檔，雪亭南門兩條已考證出口同時保存。

## 維持 UNKNOWN 的差異

`daemon/skill/taoism-spells.c` 不覆蓋，維持 UNKNOWN。逐段比對顯示差異不是格式變動：

- KING 快照把裝備元素加成限制在 `-90..200`，並以百分比乘算 `power * (100 + bonus)`。
- ES2M 來源取消上下限，改成先加算 `(power + elemental_bonus)` 再套抗性。
- 兩者會改變實際咒術傷害；目前沒有足夠歷史證據可判定哪一版應覆蓋既有 Runtime，相容性也未經普通玩家 Gameplay 驗證。

## Runtime 與驗證邊界

- 既有 Runtime overlay 會整區套用 `custom/`，因此 91 件防具會進入產生的 Runtime；但商店、掉落、任務與普通玩家取得途徑仍是 UNKNOWN。
- `beast.c` 依既有規則只在 Runtime 缺檔時補入；`fonxansword.c` 僅保存為原始範例，不宣稱已接入玩法。
- Static 測試驗證來源 SHA、去重、引用、老松林／武當地圖與 NPC 拓樸；沒有執行手機實機、Driver Runtime 或普通玩家 Gameplay，因此不得回報那些層級為 PASS。
