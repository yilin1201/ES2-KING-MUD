# M2 — Original ES2 人物基礎系統與八大屬性實機驗證

狀態：PASS

## 原則

M2 以 Original ES2 人物模型為基礎進行實機重建與驗證；ES2-KING 專案決策另行標示，不回寫或偽裝成 Original 歷史規則。

## 已由 Original ES2 Source 確認

### 人類初始八大屬性

`mudlib/daemon/race/human.c` 在 Human 初始化時建立八個 attribute：

- `str` — 專案正式玩家標示：臂力；目前 upstream `score.c` 顯示「膂力」
- `cor` — 膽識
- `int` — 悟性
- `spi` — 靈性
- `cps` — 定力
- `dex` — 機敏
- `con` — 根骨
- `wis` — 慧根

Human 每項初始 raw value = `13 + random(6)`，因此正常範圍為 13–18。

### ES2-KING 專案決策：取消防洗角色屬性扣減

Original ES2 的 `ENABLE_ANTISPAM` 登入防洗機制可能在重複創角時對八大屬性之一扣 1。依專案決策，ES2-KING 執行環境停用這項角色屬性扣減，因此新建 Human 的八大 raw attributes 維持 `human.c` 原始初始化範圍 13–18。

Original ES2 原始程式仍作為歷史與研究基準保留；此項屬於 ES2-KING runtime configuration，不宣稱為 Original 規則。

### 初始 Statistic

Human 初始化：

- `gin` = 30
- `kee` = 30
- `sen` = 30

HP 與 Kee 為不同資料，不得合併。

### Attribute base / effective

`query_attr(name, 1)` 讀取 raw/base value；`query_attr(name)` 會加上暫時性的 `apply/<name>` 修正值。因此 M2 分辨「基礎值」與「有效值」。

### score 顯示條件

目前 upstream `mudlib/cmds/usr/score.c` 只有在：

- 查看者為 wizard；或
- 玩家 level > 1

時才顯示八大屬性。

因此 Lv.1 玩家 `score` 沒有八大屬性是 Original ES2 現行程式的預期行為，不代表資料未初始化。

## M2 Live Runtime Evidence

GitHub Actions Run #41：`34996423172`

實際流程：Original ES2 Boot → Telnet Login → 建立 Human / Commoner / Lv.1 → 客棧大堂 → `look` → `score` → `west` 到廚房 → runtime-only `m2probe`。

實機角色：測試玩家 `(Mone)`，男性人類，平民，Level 1。

本次八大屬性實測：

- str = 17 / 17
- cor = 14 / 14
- int = 14 / 14
- spi = 17 / 17
- cps = 17 / 17
- dex = 13 / 13
- con = 16 / 16
- wis = 15 / 15

八項 raw/base 均在 13–18，且無防洗角色屬性扣減。

Base / Effective 實測：str raw/base = 17、effective = 17；runtime probe 暫時套用 `apply/str +2` 後 effective = 19，而 raw/base 維持 17，隨後立即還原。

Statistic 實測：

- HP = 80 / 80
- con = 16，因此 HP maximum = con × 5 = 80
- Gin = 30 / 30
- Kee = 30 / 30
- Sen = 30 / 30

因此 HP 與 Kee 已由 live runtime 證明為不同資料。

Lv.1 `score` 實際顯示形體、精、氣、神、食物、飲水、疲勞，但未顯示八大屬性，與 `score.c` 的 Level > 1 / wizard 顯示條件一致。

## M2 PASS 判定

- PASS — Human / Commoner / Lv.1 真實建立。
- PASS — 八大屬性全部取得 live runtime evidence。
- PASS — 八大 Human raw/base attributes 全部介於 13–18。
- PASS — ES2-KING 已取消防洗角色造成的屬性扣減。
- PASS — Base / Effective 差異機制已實機驗證。
- PASS — HP 與 Kee 分離；HP/con 關係已實機驗證。
- PASS — Gin / Kee / Sen 初始 30/30 已實機驗證。
- PASS — Lv.1 `score` 屬性顯示條件與 Original Source 一致。
- PASS — M1 的登入、創角、出生房、look、score、移動流程仍正常。

結論：**M2 PASS**。
