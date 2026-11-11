# ES2M 192e95d0 差異保存紀錄

來源：`wolfer168/es2-webmud@192e95d0fb112e5cbfbfba7313ed9923874f4fc2`
來源比較起點：`e93dad172cb1472dae3eba0a2d1978c12b678985`
KING 匯入前 HEAD：`c4ce39c33a3d1375a6c02474beadcd26c5951a96`

上游共 16 個新 Commit，31 個變更檔案，其中 11 個已由 Work 原樣保存於 `source/es2m_updates/20261004_087c1736/`。本次僅將其餘 20 個變更檔案存入 `source/es2m_updates/20261004_192e95d0/`，保留原始內容。

本批是 **source preservation only**。未修改 KING 的正式 Runtime、遊戲部署、資料庫、Neon、PR #13。

關鍵隔離：`deploy/oracle`、`deploy/local`、`server`、`web`、`adm/daemons/logind.c` 與 `cmds/usr/webhud.c` 屬其他執行環境或使用者介面，**不得直接覆蓋 KING**。先完成差異、依賴與隔離 Runtime 審查。

測試證據：保存檔案須逐一對照上游 Git blob SHA；這不代表 LPC 編譯、Runtime 或 Gameplay PASS。

保留：Hero MUD 全面凍結、Render Auto-Deploy OFF、PR #13 OPEN/NOT MERGED，`taoism-spells.c` 公式保持 UNKNOWN。
