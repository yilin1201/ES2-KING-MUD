# ES2M 五堂鎮（武當區域）完整導入（2026-10-03）

## 證據與範圍

- ES2M 來源：`wolfer168/es2-webmud`；固定 HEAD `e93dad172cb1472dae3eba0a2d1978c12b678985`。
- 來源路徑：`source/upstream/mudlib/d/wutang/`。
- 本批保存並導入 56 個房間、31 個 NPC、2 個區域物件。
- 另補 4 個現有 KING snapshot 尚未保存、但 NPC 直接引用的武器／防具相依檔。

## Runtime 接線與保護

- Pinned Original Runtime 沒有 `/d/wutang`；若日後存在同名區域，導入腳本停止且不覆蓋。
- ES2M `entrance.c` 的 north 指向振武軍營大門；同一固定來源的 `custom/zhenwu/room/gate.c` 新版已有 south 指回 `/d/wutang/entrance`。
- 振武軍營既有 east／west 出口與徵兵功能均保留，只新增來源已證實的 south 出口。

## 驗證邊界

- 拓樸閘門驗證房間／NPC／物件數量、五堂鎮區域標記、一般雙向出口、NPC 與 literal dependency（直接字串相依）閉合。
- 已完成 Static 與隔離 Runtime overlay 驗證；尚未宣稱 Driver Compile 或普通玩家 Gameplay PASS。
