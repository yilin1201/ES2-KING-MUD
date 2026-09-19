# Original ES2 External Recovery Register（外部來源補完登錄）

> 第五階段 5B。2026-09-19 開始檢查 Repository 外部的 ES2 Source／Archive。外部 fork/衍生庫若無法證明與目標 Original 版本一致，只能作 `CORROBORATED_CANDIDATE`（交叉佐證候選），不得直接升級為 Original Runtime 真值。

## X-001 taedlar/es2_mudlib

- 身分：Annihilator 公開 ES2 Mudlib 現行來源；README 說明 GitHub 初始版本以 ES2 Mudlib v1.3b 為基礎。
- 用途：最高優先 Original Source cross-check（原始來源交叉核對）。
- 既有限制：現行保存內容不等於歷史正式站所有遊戲內容都完整保存。

## X-002 mudchina/es2

- 身分：公開標示「東方故事II（ES2）GBK 中文版」的歷史/衍生保存庫。
- 新發現：Repository 含 `quest/` 目錄，至少有 `qlist1000.c`、`qlist1500.c`、`qlist2000.c`、`qlist3000.c`、`qlist5000.c`、`qlist8000.c`、`qlist10000.c`、`qlist13000.c`、`qlist17000.c`、`qlist22000.c`、`qlist40000.c`、`qlist50000.c`、`qlist60000.c`、`qlist80000.c`、`qlist100000.c` 等。
- 抽查內容：quest entry 明確包含 `quest`、`quest_type`、`time`、`exp_bonus`、`pot_bonus`、`score` 欄位；多數 `quest_type` 為「殺」。
- 判定：`CORROBORATED_CANDIDATE`。這證明存在可追的 ES2 quest-list 類 Source，但**尚不能證明這些數值就是目標 Original 天朝帝國正式站同版本**。
- 影響：M18 從「完全沒有外部程式候選」提升為「有外部 Quest Source Candidate」，但完整 trigger→progress→save→completion→reward 鏈仍未確認，M18 仍維持 `PARTIAL / SOURCE_REQUIRED`。

## X-003 MudRen/ES2-big5 與 ES2-utf8

- 身分：ES2 v1.3b／後續編碼與 Driver 相容版本保存。
- `ES2-utf8` 同樣可見多份 `quest/qlist*.c`；可作 X-002 的獨立 repository cross-check，但兩庫可能具有共同祖先，不能把「兩個 repo 都有」誤當成兩份獨立歷史證據。
- Race Source 目前仍以 human/beast/monster 等保存框架為主，未因此找到 headless/yaksa 等遺失歷史 initializer。

## X-004 2014 ES2 Tips — Class/Master 路線

- 歷史玩家資料明確列出武者門派與師父：冷梅莊 `fighter.lunmay` → 梅影風（May yin fong），位置描述為水嵐武陵客棧北方。
- 判定：`PLAYER_RECORD / CORROBORATED`；可交叉支持既有梅影風人物檔的身分與大方向位置，但不能單獨生成 NPC LPC path、HP、skill level。

## X-005 歷史人物設定頁 — 梅影風

- 公開歷史頁保存梅影風為冷梅莊莊主、門派掌門，並列出銀霜鎧、奔雲靴、梅花白襖、流雲清玉帶、白玉戒指、寒霜劍、冰雪匕等裝備。
- 判定：`ARCHIVED_SOURCE / CORROBORATED`；與目前 `original_es2/characters/mei_yingfeng.md` 的人物與裝備敘述一致。
- 仍不能升級：NPC path、HP、完整 set_skill/map_skill。

## 5B 結論

1. **Quest 有重大新線索**：找到多個外部 ES2 保存庫中的實際 `quest/qlist*.c`，但先標記 Candidate，不直接搬進 Original Runtime。
2. **Race initializer 尚未突破**：外部保存庫仍未找到 headless/yaksa 等歷史 daemon。
3. **冷梅莊證據加強**：梅影風的 `fighter.lunmay`、人物身分、位置方向與裝備獲得外部交叉支持；Runtime path/數值仍未知。
4. 下一階段 5C 應先追 Quest qlist 的**呼叫端與保存端**：誰載入 qlist、如何派任務、如何完成、如何發放 exp/pot/score；只有鏈條閉合後才考慮升級為可重建 Runtime。
