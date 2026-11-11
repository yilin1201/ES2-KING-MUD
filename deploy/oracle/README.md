# ES2-KING Oracle VM deployment

KING 專用部署。參考 ES2M 已驗證的 Oracle VM + Ubuntu 24.04 + Caddy/sslip.io 架構，但不讀寫 ES2M 主機或 Repository。

- Source: yilin1201/ES2-KING-MUD
- Branch: build/original-es2-races-phase2
- Runtime: existing KING Dockerfile (single source of truth)
- Public: Caddy 443 -> localhost:8080
- Neolith TCP 4000 remains internal only
- Persistence: local volume plus existing Neon DATABASE_URL when configured
- Secrets: put DATABASE_URL and ES2_KING_CLAIM_TOKEN in ~/.config/es2-king/oracle.env; never commit them.

Oracle Security List should expose SSH 22 and HTTP/HTTPS 80/443. Do not expose 4000. 8080 is bound to 127.0.0.1 only.

First install:
  bash deploy/oracle/setup.sh
  bash deploy/oracle/https.sh

Update:
  bash deploy/oracle/update.sh

## 玩家資料備份

`DATA_DIR` 是 Docker Volume 的玩家持久化檔案目錄，預設為 `$HOME/es2-king-data`。備份必須寫到另一台主機或獨立掛載的外部儲存，不要把備份放在同一顆系統磁碟。

先掛載或準備外部備份目錄，再執行：

```bash
BACKUP_DIR=/mnt/external-backup/es2-king \
DATA_DIR="$HOME/es2-king-data" \
bash deploy/oracle/backup.sh
```

備份腳本會建立日期時間檔名、檢查 tar.gz 可讀性、產生 SHA-256 校驗碼，並依 `RETENTION_DAYS`（預設 30 天）清理舊備份。預設拒絕將備份寫在與玩家資料相同的檔案系統；若外部儲存因特殊掛載方式顯示相同裝置，必須先確認風險，再明確設定 `ALLOW_SAME_DEVICE_BACKUP=1`。

**重要限制：** 這個腳本備份的是本機玩家持久化檔案，不等於已完成 Neon/Postgres 供應商端備份，也不代表已驗證還原。若設定 `DATABASE_URL`，仍需依資料庫供應商設定資料庫備份與保留政策，並安排隔離環境還原演練。不要將玩家備份、密碼或環境變數提交到 GitHub。
