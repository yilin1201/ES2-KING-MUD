# Class / School Evidence-to-Runtime Map（職業／門派證據映射）

> 第五階段 5O。用於 M11/M14/M15；只決定「什麼可以進 Runtime」，不把外部版本內容自動升級成目標 Original Canon。

| Layer | Evidence | Status | Runtime rule |
|---|---|---|---|
| 七職業集合 | Google Sites／歷史截圖 | ARCHIVED_SOURCE | 可保存職業集合與 ID |
| Fighter 基礎 Class daemon | taedlar official v1.4 | CONFIRMED_SOURCE | 可作 Original Class Engine 基線 |
| Apprentice command | official Original source | CONFIRMED_RUNTIME | 可保留 apprentice 流程 |
| master/apprentice relation | official relation.c | CONFIRMED_RUNTIME | 可保留雙向關係介面 |
| NPC accept/init hooks | official source/docs | CONFIRMED_RUNTIME | 可作 School NPC 介面 |
| 外部 Scholar/Taoist/Bonze/Fighter/Swordsman masters | ES2 family repositories | CORROBORATED_RUNTIME_CANDIDATE | 只作結構／事件鏈參考 |
| 冷梅莊 `fighter.lunmay` | Archived Source + Player Record | CORROBORATED_TEXT | 名稱/識別可保存，Runtime path 不猜 |
| 梅影風身分／裝備 | Archived Source + Player Record | CORROBORATED_TEXT | 只用已支持欄位 |
| 梅影風 LPC path/HP/skill levels | 未回收 | SOURCE_REQUIRED | 禁止補造 |
| School-specific recruit conditions | 版本內容未鎖 | VERSION_SOURCE_PENDING | 不直接套用外部門派條件 |

## Gate

M15 冷梅莊只有在「School identity → master NPC Source → recruit condition → relation hook → skill/enable mapping」逐段有可用 Evidence 時，才可宣告完整 Runtime Recovery。通用 Apprentice Engine 的 PASS 不等於冷梅莊 PASS。
