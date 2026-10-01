# 超級Ω神聖衣（Super Omega God Cloth）

> [ES2-KING Expansion] 專案擁有者指定的新創神裝，不屬於 Original ES2。

- 載體：神之戒（God ring）
- 正式解封指令：`release omega`
- 快捷指令：`kring`
- 授權：僅唯一 Owner 帳號 `king` 且具 Original admin 權限
- 全套防禦：七件合計 `armor +300`；神戒若另外穿戴，再增加 `armor +5`

| 裝備 | Original ES2 槽位 | armor | 狀態 |
|---|---|---:|---|
| 超級Ω神聖衣。頭盔 | `head_eq` | 35 | 群星護佑 |
| 超級Ω神聖衣。盔甲 | `armor` | 100 | 神之庇護 |
| 超級Ω神聖衣。披風光翼 | `neck_eq` | 40 | 光速境界 |
| 超級Ω神聖衣。腰帶 | `waist_eq` | 30 | 絕對霸體 |
| 超級Ω神聖衣。手套 | `hand_eq` | 30 | 神拳防護 |
| 超級Ω神聖衣。腳套 | `leg_eq` | 35 | 下盤防護 |
| 超級Ω神聖衣。鞋子 | `feet_eq` | 30 | 踏星防護 |

披風光翼採 `neck_eq`，因 Original ES2 人形種族沒有獨立背部／護肩槽；這是最接近 mantle／披風、且不與身體盔甲衝突的合法位置。

解封時會重用物品欄中的既有聖衣，只建立缺少的部件；七件均透過 Original `wear()` API 穿戴。三個狀態寫入裝備的 `apply_armor`，卸下對應部件時會跟著解除，不留下永久暫存加成。
