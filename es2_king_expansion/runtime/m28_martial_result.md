# M28 易筋經＋霸天煉體訣驗證結果

`WORK-LOCAL PASS`（Work 本機驗證）。

```text
M28 MARTIAL STATIC PASS／七境、兆／極與 Original 邊界正常。
M28 MARTIAL RUNTIME PASS／Expansion 狀態層可載入，Original 200 級上限仍保留。
Driver Boot：PASS。
`kingmartial yijinjing 300`：PASS，顯示黑級無極境。
`kingmartial batian ji`：PASS，顯示 Expansion Canon 階段。
`kingmartial yijinjing 301`：PASS（正確拒絕超界）。
`kingmartial batian foo`：PASS（正確拒絕未知階段）。
```

Expansion 狀態寫入 `es2_king/` 命名空間；未修改 Original 技能保存格式。GitHub Actions：`ACTIONS-INFRA-BLOCKED`，不 rerun、不宣稱 Actions PASS。未定義戰鬥公式、回血比例與固定殺招維持 `UNKNOWN`。
