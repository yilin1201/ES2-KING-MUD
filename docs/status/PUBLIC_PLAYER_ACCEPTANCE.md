# Public Player Acceptance

P6 的 `PUBLIC_PLAYER_SMOKE_PASS` 只能由外部 HTTPS/WSS 執行取得，localhost 或容器內部 smoke 不得升級。

執行：

```bash
node scripts/test_public_player_acceptance.mjs https://es2-king-mud.onrender.com/ <40-char deployed commit>
```

Acceptance 必須同時驗證：
1. HTTPS health 與 WebTelnet browser modules。
2. health 回報的 `build_commit` 等於指定 deployed commit。
3. 外部 WSS `/mud` 收到 Original ES2 login prompt。
4. 普通玩家未使用 ID 進入新人物建立確認，且不具 owner/admin/wizard 權限。
5. 回答 N，不建立帳號、不設定密碼、不污染 Neon。

只有以上全部 PASS 才輸出 `PUBLIC_PLAYER_SMOKE_PASS`。

Physical iPhone Safari 仍是獨立 acceptance evidence；Public smoke 不得冒充實體 iPhone 驗證。
