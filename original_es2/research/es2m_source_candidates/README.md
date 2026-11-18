# ES2M 雪亭鎮原始碼隔離區

此處存放從 `taedlar/es2_mudlib` 固定 commit `cc45c06af4852380e5148dad3c9d53ff06854f2c` 直接讀取的原始 LPC；不屬於遊戲 Runtime 載入路徑。

| 檔案 | GitHub 上游 Blob SHA | 已確認直接關聯 |
|---|---|---|
| d/snow/bazar.c | 5624adfa28d38df6cc4cfa5a9ab73e462edb380a | BANK、sstreet1、npc/yu |
| d/snow/sstreet1.c | 18e2ac81e1c7aea8207bee2af515cf2d4a1a4e19 | ROOM、sgate、square_s、store、bazar |
| d/snow/npc/yu.c | 3fed86f81a693a517579b30ddf17eb56c75da428 | F_VILLAGER、F_VENDOR、blue_jacket、fur_hat、bottle |

**狀態：STAGED / SOURCE VERIFIED / TARGET COMPATIBILITY UNKNOWN / RUNTIME NOT TESTED。**

後續順序：
1. 比對目標版本中同路徑原始碼，已存在且不同時不得直接覆蓋。
2. 查核所有 inherit/include、出口、商店物件與其依賴，補齊原始證據。
3. 依照目標 Driver API 評估相容性，僅對通過的檔案提出最小導入。
4. 使用一般玩家測試 east/west、look、list、buy、銀行操作，並完成 save→quit→relogin 回歸。

請勿將本資料夾加入 Runtime 的 room/object 搜尋路徑。
