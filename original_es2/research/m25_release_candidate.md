# M25 Original ES2 Release Candidate

## Scope／範圍

M25 將已完成的 M21～M24 組成 Original ES2 Release Candidate（候選完整版本：進入封版前的整體可玩驗收版本）。本里程碑只驗證保存來源與既有 Runtime（執行環境），不把 ES2-KING Expansion（擴充內容）寫回 Original。

## Runtime Gate／執行閘門

- Driver Build（驅動器建置）：Neolith 必須能由乾淨來源完成設定與編譯。
- Driver Boot（驅動器啟動）：必須載入 Original ES2 mudlib（遊戲程式庫）並出現登入提示。
- Player Journey（玩家旅程）：真實建立帳號與角色，執行 `look`、`score`、`inventory`、`help`，完成房間往返、`save`、`quit` 與重新進入。
- Persistence（持久化）：重新進入後角色名稱、職業、種族及位置必須可恢復。
- M21～M24 的世界、NPC／物品、核心玩法及資料完整性 Gate 必須保持通過。

## Regression Test／回歸測試

靜態測試鎖定 Roadmap（路線圖）邊界、M21～M24 結果與 Original／Expansion 分離；Runtime 測試重跑 M21～M24 已確認的來源介面，避免候選版本整合時倒退。

## UNKNOWN（未知）

- 未取得可靠歷史證據的區域、任務完整鏈、NPC 掉落率、歷史數值與內容仍為 `UNKNOWN`。
- M25 通過代表目前可考證內容形成可建置、可登入、可移動、可存讀的候選基準，不代表遺失的歷史內容已被補齊。
- GitHub Actions（GitHub 自動化測試）若因免費額度／US$0 spending budget（支出預算）無法啟動 Runner（測試執行器），狀態只能標示 `ACTIONS-INFRA-BLOCKED`，不得宣稱 Actions PASS。

## Release Boundary／候選版邊界

Original ES2 保存原始碼不為增加註解而修改。M26 才能開始 ES2-KING Expansion，且 Expansion Canon（擴充正史設定）不得反寫成 Original 歷史證據。
