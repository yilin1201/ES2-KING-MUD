# M19 角色生命週期 Runtime 驗證計畫

## 目標

以乾淨 Original ES2 上游程式樹核對 `unconcious → revive`（昏迷到甦醒）、`die → corpse／ghost`（死亡到屍體／鬼魂）、寺廟 `enter → make_living`（進入漩渦後恢復生命形態）與在線年齡累計。

## Runtime Gate（實機證據閘門）

1. 確認 `mudlib/std/char.c`、`mudlib/std/room/temple.c`、`mudlib/obj/user.c` 存在。
2. 鎖定上述函式及已確認的 60 秒、86400 秒常數。
3. 鎖定死亡清理、屍體建立、鬼魂分支與寺廟 `make_living()` 呼叫。
4. 不修改 Original 保存原始碼；測試僅讀取乾淨 Runtime tree（執行程式樹）。

## 完成邊界

本階段 PASS 代表生命週期核心程式證據可重現，不代表所有死亡懲罰或輪迴規則已完成。尚未找到的內容保持 `UNKNOWN`（未知）。
