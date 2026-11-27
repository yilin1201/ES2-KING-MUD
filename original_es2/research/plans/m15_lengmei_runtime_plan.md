# M15 冷梅莊／梅影風 Runtime 驗證計畫

## 目的

本階段延續 `preserve → understand → rebuild → expand`，先確認目前公開 Original ES2 Mudlib 是否真的包含可執行的冷梅莊／梅影風 NPC，再決定 Runtime 重建方式。

> **Runtime（實際執行環境）**：不是只看文件或程式文字，而是把 Driver 與 Mudlib 真正啟動後驗證行為。
>
> **Evidence gate（證據閘門）**：在建立 NPC、HP、技能等級或路徑前，先要求原始來源提供足夠證據；沒有證據就保持未知，不用猜測值補洞。

## 已鎖定 Original 證據

- 人物：梅影風（May yin fong）
- 身分：冷梅莊莊主、門派掌門、武者師父
- 歷史職業路線：`fighter.lunmay`
- 武學名稱：冷梅劍法、傲梅暗劍訣、梅影身法、七巧如意手、寒梅心法
- 裝備證據：寒霜劍、冰雪匕等
- 現階段未知：原始 NPC LPC path、HP、技能等級、完整 `set_skill`／`map_skill`

## Runtime Gate

1. Bootstrap（啟動準備）公開上游 `taedlar/es2_mudlib`。
2. 搜尋 Mudlib 是否存在 `fighter.lunmay`、`May yin fong`、`mei_yingfeng`、`lengmei`、`lunmay` 等可執行證據。
3. 若找到原始 LPC：記錄 path，下一階段才建立真實 NPC Runtime 測試。
4. 若未找到：測試必須 PASS 為「公開上游缺少可確認 NPC Runtime source」，而不是創造假 NPC 來讓測試變綠。
5. ES2-KING Expansion 設定不得進入此 Original Runtime Gate。

## PASS 定義

M15 Runtime Gate PASS 不等於「梅影風 NPC 已完整恢復」。它表示：

- Driver／Mudlib 可正常 Bootstrap；
- 自動測試能辨識目前公開上游的證據狀態；
- 缺少 NPC LPC 時不補造；
- 後續重建有清楚、可回歸的證據邊界。
