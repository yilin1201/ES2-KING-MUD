# M25 Original ES2 Release Candidate 驗證結果

`WORK-LOCAL PASS`（Work 雲端環境本機完整驗證通過）。

## Build／建置

```text
上游 Original ES2：taedlar/es2_mudlib@cc45c06af4852380e5148dad3c9d53ff06854f2c
Neolith Driver：CMake configure PASS
Neolith Driver：cmake --build --preset dev-linux PASS
Driver Boot：neolith -f neolith.conf -c PASS
登入畫面：東方故事Ⅱ／天朝帝國／Celestial Empire 顯示正常
```

## Player Journey／玩家旅程

```text
帳號：mlocal（本機暫存測試帳號，未提交角色資料）
角色：候選驗收／男性／human（人類）／commoner（平民）
look：PASS，客棧大堂與 west 出口正常
score：PASS，顯示候選驗收 (Mlocal)、等級 1 平民、人類
inventory：PASS，正常回覆目前沒有物品
help：PASS，顯示 ES2 mudlib v1.5 說明文件
west：PASS，由客棧大堂進入廚房
east：PASS，由廚房返回客棧大堂
save：PASS，回覆下次由此開始、檔案儲存完畢
quit → mlocal 重新進入：PASS
重新進入後 score：PASS，角色名稱、平民、人類、等級與狀態保留
```

## Aggregate Gates／彙總閘門

```text
M21 WORLD STATIC PASS
M21 WORLD RUNTIME PASS
M22 NPC ITEM STATIC PASS
M22 NPC ITEM RUNTIME PASS
M23 CORE GAMEPLAY STATIC PASS
M23 CORE GAMEPLAY RUNTIME PASS
M24 DATA INTEGRITY STATIC PASS
M24 DATA INTEGRITY RUNTIME PASS
M25 RELEASE CANDIDATE STATIC PASS
M25 RELEASE CANDIDATE RUNTIME PASS
```

GitHub Actions：`ACTIONS-INFRA-BLOCKED`。帳號免費 Actions 使用額度／US$0 spending budget 導致 0-Step Runner failure（測試執行器未進入任何步驟），不是程式失敗；依零付費模式不 rerun（重新執行）。待免費額度恢復後補正式 Actions 驗證，本文不宣稱 Actions PASS。

未有可靠歷史證據的區域、完整任務鏈、掉落率及歷史數值保持 `UNKNOWN`。Original ES2 與 ES2-KING Expansion 保持分離。
