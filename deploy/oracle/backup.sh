#!/usr/bin/env bash
set -euo pipefail

# ES2-KING Oracle 備份：只封存玩家持久化檔案，不輸出密碼、環境變數或資料庫連線字串。
APP_DIR="${APP_DIR:-$HOME/ES2-KING-MUD}"
DATA_DIR="${DATA_DIR:-$HOME/es2-king-data}"
BACKUP_DIR="${BACKUP_DIR:-}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
ALLOW_SAME_DEVICE_BACKUP="${ALLOW_SAME_DEVICE_BACKUP:-0}"

if [[ -z "$BACKUP_DIR" ]]; then
  echo "BACKUP FAIL：請設定 BACKUP_DIR 為另一台主機或獨立掛載的備份目錄。" >&2
  exit 2
fi
[[ -d "$DATA_DIR" ]] || { echo "BACKUP FAIL：找不到玩家資料目錄：$DATA_DIR" >&2; exit 1; }
[[ "$RETENTION_DAYS" =~ ^[0-9]+$ ]] || { echo "BACKUP FAIL：RETENTION_DAYS 必須是整數。" >&2; exit 2; }

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"
DATA_REAL="$(realpath "$DATA_DIR")"
BACKUP_REAL="$(realpath "$BACKUP_DIR")"

# 防止把備份寫回資料目錄本身或其子目錄，避免形成遞迴封存。
case "$BACKUP_REAL/" in
  "$DATA_REAL/"*) echo "BACKUP FAIL：備份目錄不可位於玩家資料目錄內。" >&2; exit 2 ;;
esac

# 預設要求備份目錄位於不同檔案系統，避免主機磁碟故障時原始資料與備份一起遺失。
# 若管理者已確認外部儲存的掛載方式特殊，可明確設定 ALLOW_SAME_DEVICE_BACKUP=1。
if [[ "$(stat -c %d "$DATA_REAL")" == "$(stat -c %d "$BACKUP_REAL")" && "$ALLOW_SAME_DEVICE_BACKUP" != "1" ]]; then
  echo "BACKUP FAIL：備份目錄與玩家資料位於同一檔案系統；請掛載異地／外部備份儲存，或明確設定 ALLOW_SAME_DEVICE_BACKUP=1。" >&2
  exit 2
fi

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
NAME="es2-king-data-$STAMP.tar.gz"
TMP="$(mktemp "$BACKUP_REAL/.es2-king-backup.XXXXXX")"
trap 'rm -f "$TMP" "$TMP.sha256"' EXIT

# 封存前不讀取或輸出玩家檔案內容；封存完成後檢查壓縮檔與 SHA-256 校驗碼。
tar -czf "$TMP" -C "$DATA_REAL" .
tar -tzf "$TMP" >/dev/null
mv "$TMP" "$BACKUP_REAL/$NAME"
(
  cd "$BACKUP_REAL"
  sha256sum "$NAME" > "$NAME.sha256"
)
chmod 600 "$BACKUP_REAL/$NAME" "$BACKUP_REAL/$NAME.sha256"

# 僅清理超過保留期限的同類備份；不碰玩家資料目錄。
find "$BACKUP_REAL" -maxdepth 1 -type f -name 'es2-king-data-*.tar.gz' -mtime +"$RETENTION_DAYS" -delete
find "$BACKUP_REAL" -maxdepth 1 -type f -name 'es2-king-data-*.tar.gz.sha256' -mtime +"$RETENTION_DAYS" -delete

echo "ES2-KING BACKUP PASS：$BACKUP_REAL/$NAME"
echo "SHA256：$BACKUP_REAL/$NAME.sha256"
echo "範圍：$DATA_REAL（玩家持久化檔案）；此檔案備份不取代 Neon/Postgres 供應商端的資料庫備份。"
