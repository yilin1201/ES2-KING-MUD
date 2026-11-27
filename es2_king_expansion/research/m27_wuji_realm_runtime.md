# M27 天神殿・無極之境 Runtime

> `[ES2-KING Expansion]` `[Project Canon]` `[Admin Room]`

## Canon 實作

- `wuji_realm.c` 逐段程式化既定 `admin_rooms/wuji_realm.md` 正式場景描述，不增加未授權世界觀。
- 唯一出口 `down` 連接 Original ES2 已確認的 `/d/snow/square`／雪亭鎮廣場中央。
- `kinghome`（創世神域入口指令）使用 `SECURED_ADMIN_COMMAND`，只有最高 `(admin)` 可進入。
- 房間 `init()`（進入初始化）再次檢查權限；非最高管理員會被送回雪亭鎮，形成雙層安全邊界。
- `no_fight`（禁止戰鬥）與 `no_clean_up`（避免房間被自動清除）只處理管理空間運作，不推定額外 Canon 功能。

## Runtime Gate／執行閘門

最高管理員必須能由凡間執行 `kinghome` 進入、看見完整描述，再以 `down` 回到「廣場中央」。一般玩家入口與繞過入口的直接進入皆須遭拒。

## Regression Test／回歸測試

M26 `kingcreate` 白名單不得被房間功能放寬；Original `/d/snow/square.c` 不修改；Expansion 房間與指令只存在獨立覆蓋層。

## UNKNOWN（未知）

Canon 文件明定另行設計的召喚、神兵、武學授予與世界觀察功能保持 `UNKNOWN`，M27 不自行推定。

## 2026-11-09 Khome／梅寒霜連線修復

- `khome` 現在進入 Owner 私人家園 `/custom/home/room/home_hall`；`kinghome` 仍只進入本文件所述無極之境。
- 本次 M27 Runtime Gate 同時核對生成後 Runtime 的 Khome command、home hall、無極之境、演武界、梅寒霜 NPC、`setup()` 及雙向出口。
- M30 真 Neolith LPC Load Gate 已載入 `/custom/home/room/home_hall`、`/d/king/wuji_realm`、`/d/arena/yanwujie` 與 `/d/arena/npc/mei_hanshuang`，載入結果 PASS。
- 上述為真 Driver LPC preload／房間 setup 載入證據；Owner 實際輸入 khome 的互動 E2E 與梅寒霜完整戰鬥 E2E 尚待獨立驗收，不以 preload 結果冒充。
