# ES2-KING Minimum Playable Milestone

## 定義

只有以下流程全部實際通過，才可以稱為「第一版可玩 MUD」。目前狀態：**尚未通過**。

## M0 — Source bootstrap

- [x] 鎖定 Original ES2 primary upstream
- [x] 驗證 Character setup
- [x] 驗證 Score / Level
- [x] 驗證 Human initialization
- [ ] 建立可編譯的最小 Mudlib tree
- [ ] Driver 成功啟動

## M1 — Connect / Login

- [ ] Client 能連線到測試 Server
- [ ] 顯示 ES2-KING welcome
- [ ] 建立／登入測試帳號
- [ ] 建立角色

## M2 — Character

第一個驗證角色先用 Original `human + commoner + level 1`，避免 Expansion 干擾 Original 核心測試。

- [ ] 八 Attribute 存在
- [ ] Gin / Kee / Sen 存在
- [ ] HP 與 Kee 分離
- [ ] Fatigue 存在
- [ ] Race = human
- [ ] Class = commoner
- [ ] Level = 1

## M3 — World

- [ ] 角色進入第一個測試房間
- [ ] `look` 可顯示房間
- [ ] 至少一個方向可移動
- [ ] 移動後可返回

## M4 — Basic commands

- [ ] `look`
- [ ] `score`
- [ ] `skills`
- [ ] `inventory`
- [ ] 基本移動方向

## M5 — ES2-KING first expansion test

Original M1–M4 穩定後才進入：

- [ ] 建立 ES2-KING 刑天測試角色
- [ ] Original / Expansion Race Object 分離
- [ ] `score` 顯示刑天資料
- [ ] 進入 ES2-KING 出生／測試房間

## 驗收原則

文件存在 ≠ 程式可執行。

程式可編譯 ≠ MUD 可登入。

Server 啟動 ≠ 可玩。

只有真實 Client 完成「連線 → 登入／創角 → 進房 → look → score → 移動」後，M1–M4 才能標記完成。
