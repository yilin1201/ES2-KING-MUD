# M22 Original ES2 角色／NPC／裝備／物品證據登錄表

## 證據範圍

- Primary upstream（主要上游）：`taedlar/es2_mudlib`。
- 本階段只登錄乾淨 Original Runtime tree（執行程式樹）實際存在的 `mudlib/d/snow/` 內容。
- NPC（Non-Player Character，非玩家角色）的 HP、技能、掉落率、商品與任務關係，只有原始碼直接支持時才可標為 `CONFIRMED_RUNTIME`。
- 未保存的歷史人物、師父、怪物、裝備與物品維持 `UNKNOWN`（未知）。

## 機器可重現基線

| 類型 | 狀態 | 數量／證據 |
|---|---|---|
| Snow NPC 程式 | `CONFIRMED_RUNTIME` | `mudlib/d/snow/npc/` 根目錄共 23 個 `.c`。 |
| Snow NPC 專屬物品 | `CONFIRMED_RUNTIME` | `mudlib/d/snow/npc/obj/` 共 29 個 `.c`。 |
| Snow 區域一般物品 | `CONFIRMED_RUNTIME` | `mudlib/d/snow/obj/` 共 3 個 `.c`。 |
| 村民類 | `CONFIRMED_RUNTIME` | `F_VILLAGER`，包含店主、孩童、工頭等既有程式。 |
| 士兵類 | `CONFIRMED_RUNTIME` | `F_SOLDIER`，包含 `garrison.c` 與 `lieutenant.c`。 |
| 商人能力 | `CONFIRMED_RUNTIME` | `F_VENDOR`，目前由 `yu.c`、`waiter.c`、`herbalist.c`、`smith.c` 繼承。 |
| 戰士／強盜類 | `CONFIRMED_RUNTIME` | `girl.c` 繼承 `F_FIGHTER`；`oldman.c` 繼承 `F_BANDIT`。 |

## 已確認載入關係範例

- 市集 `bazar.c` 載入 `npc/yu`。
- 藥鋪 `herb_shop.c` 載入 `npc/herbalist`。
- 鐵匠鋪 `smithy.c` 載入 `npc/smith`。
- 北門 `ngate.c` 載入 4 名 `npc/garrison` 與 1 名 `npc/lieutenant`。
- 學堂 `school.c` 載入 `npc/teacher`、`npc/alchemist` 與 `npc/child3.c`。
- 貨棧 `store.c` 載入 `npc/foreman`、`npc/obj/wagon` 與 `npc/obj/crate`。
- 壁爐房 `fireplace.c` 載入木劍與木刀，證明房間可直接載入物品而非 NPC。

## UNKNOWN 邊界

- 上述程式名稱不自動代表完整歷史身分、門派或任務職責。
- 沒有逐檔證據時，不補造 HP、技能等級、掉落率、商品價格或特殊能力。
- M15 冷梅莊／梅影風文字證據不得因 Snow 區域盤點而被誤寫成已存在的 Runtime path。
- ES2-KING Expansion（擴充內容）人物與物品不得寫入本登錄表冒充 Original。
