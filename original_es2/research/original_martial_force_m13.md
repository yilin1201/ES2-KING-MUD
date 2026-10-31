# M13 Original ES2 武學／內功重建證據基線

> 狀態：`[Confirmed Source]`。本文件只整理已在 Original ES2 原始碼／歷史文件確認的行為，不把 ES2-KING 擴充武學倒灌成 Original。

## 1. Skill Daemon／技能守護程式

目前 Original `mudlib/daemon/skill` 可直接確認基礎 `unarmed` 與 `sword`；歷史區域技能則可由各區域 `skill` 目錄提供專用 Skill Daemon。

`Skill Daemon`：技能規則物件。它不是玩家的技能數值本身，而是負責定義某個技能可如何被使用、進階或觸發特殊功能。

## 2. force／內功的基礎與映射

Original 的內功架構使用基礎技能 `force`，再以 `map_skill("force", "<專用內功>")` 把實際使用中的內功映射到專用 Skill Daemon。

Original `exert` 指令會先讀取 `skill_mapped("force")`：

- 沒有映射內功：提示目前沒有使用任何內功。
- 仍只映射到基礎 `force`：要求先 `enable` 一種內功。
- 已映射專用內功：交由該 Skill Daemon 的 `exert_function()` 處理。

因此 ES2-KING 重建時必須保留「基礎 force → 專用內功 → exert 功能」三層關係，不能把內功只做成一個單獨數值。

## 3. 已確認 Original 範例：dragon force／龍圖心經

Original `mudlib/d/snow/skill/dragon_force.c` 是可執行的歷史內功範例：

- 註冊技能名稱 `dragon force`。
- `valid_enable("force")` 為真，證明它可作為 `force` 的專用映射。
- 未正式練成前，累積學習進度達 1500 後可進階至 40 級，並增加 `martial art` 評價。
- 40 級後到 120 級以前，依 Original 公式由學習進度觸發逐級成長。
- 技能進階時可能提高 `gin`、`kee`、`sen` 上限。
- `exert dragon force` 會開始實際練功狀態。
- 每輪練功需要精、氣、神各至少 10，並各消耗 10。
- 練功成功判定會使用 `cps`（膽識）、`con`（根骨）與基礎 `force`。
- 成功後會增加 `dragon force` 與基礎 `force` 的學習進度。

以上公式保持 Original 原文邏輯，不在此階段重新平衡。

## 4. 戰鬥數值關係

Original `estimate` 可確認：當 `force` 已映射為專用內功時，攻擊強度會加入與 `force` 技能及目前 `kee`（氣）相關的修正。因此「氣」與內功不是同一個欄位：`kee` 是角色狀態資源，`force` 是技能系統的一部分。

## 5. 歷史技能名錄

Original wizard 歷史文件仍保留多個技能背景名稱，例如 `hainmay_force`、`iceforce`、`longyeforce`、`lotusforce`、`tiger_force` 等。這些名稱可作為後續考證索引，但在找到對應完整原始碼／可靠歷史證據前，不推定公式、門派、招式或強度。

## 6. M13 Runtime 驗證目標

下一步建立 Runtime-only 驗證，使用 Original 已存在的 `dragon force` 作為證據樣本：

1. 建立真實玩家。
2. 準備必要技能與資源，但不改寫 Original 內功程式。
3. 驗證 `map_skill("force", "dragon force")`。
4. 玩家真正執行 `exert dragon force`。
5. 驗證精／氣／神實際消耗。
6. 驗證內功／force 學習進度能依 Original 路徑成長。
7. `quit` → 重新登入後驗證技能與映射／學習資料的保存邊界。

## 7. ES2-KING 擴充隔離

易筋經、霸天煉體訣、渾天寶鑑、如來神掌等已定稿 ES2-KING 武學屬於 Expansion／重建擴充層。M13 先把 Original 內功引擎證明可運作，再讓擴充武學接上同一套可信的底層架構。
