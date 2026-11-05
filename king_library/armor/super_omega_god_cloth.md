# 超級Ω神聖衣（Super Omega God Cloth）

> [ES2-KING Expansion] 專案擁有者指定的新創神裝，不屬於 Original ES2。

- 載體：神之戒（God ring）
- 正式解封指令：`release omega`
- 快捷指令：`kring`
- 封印指令：`seal omega`（七件卸下後全部回歸神之戒，不留在 Inventory）
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


## 顯示與封印規格

- 七件名稱共同前綴「超級Ω神聖衣。」使用白色顯示；部件名使用黃色顯示。
- `seal omega` 必須先透過 Original ES2 `unequip()` 解除七件裝備與其 `apply_armor`，再將七件實體收回神之戒。
- 封印成功後，神之庇護、絕對霸體、光速境界三個 apply 狀態均須歸零；再次 `release omega` 時重新由對應部件恢復。
- 目前三個狀態只定義為裝備綁定的 Expansion apply 標記；在沒有新的專案 Canon／Runtime 證據前，不自行補造額外免傷、霸體或移速倍率。
