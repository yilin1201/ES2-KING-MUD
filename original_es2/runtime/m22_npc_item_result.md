# M22 角色／NPC／裝備／物品驗證結果

## 結論

`WORK-LOCAL PASS`（Work 雲端環境本機驗證通過）。

```text
$ bash scripts/test_m22_npc_item_static.sh
M22 NPC ITEM STATIC PASS／NPC、物品與證據邊界正常。

$ bash scripts/test_m22_npc_item_runtime_gate.sh ../upstream
M22 NPC ITEM RUNTIME PASS／NPC=23，NPC物品=29，區域物品=3。
```

驗證上游 Commit：`cc45c06af4852380e5148dad3c9d53ff06854f2c`。

GitHub Actions：`ACTIONS-INFRA-BLOCKED`。專案維持 US$0 額外付費，Runner 因免費額度無法啟動；不視為程式 FAIL、不重複 rerun，待免費額度恢復後補驗證。

所有未取得可靠 Original 證據的角色屬性、技能、掉落與歷史人物仍為 `UNKNOWN`，沒有以 Expansion 補造。
