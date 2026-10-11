#!/usr/bin/env bash
set -euo pipefail

# Oracle backup smoke test／Oracle 備份冒煙測試：只使用臨時資料，不碰真實玩家資料。
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEMP_ROOT"' EXIT
DATA_DIR="$TEMP_ROOT/player-data"
BACKUP_DIR="$TEMP_ROOT/external-backup"
mkdir -p "$DATA_DIR/user/7" "$DATA_DIR/login/7"
printf '%s\n' 'synthetic numeric-account fixture' > "$DATA_DIR/user/7/7probe.o"
printf '%s\n' 'synthetic login fixture' > "$DATA_DIR/login/7/7probe.o"

# 測試環境刻意使用同一個暫存檔案系統，因此只在此測試中明確允許同裝置。
BACKUP_DIR="$BACKUP_DIR" DATA_DIR="$DATA_DIR" ALLOW_SAME_DEVICE_BACKUP=1 \
  bash "$ROOT/deploy/oracle/backup.sh" > "$TEMP_ROOT/backup.log"
ARCHIVE="$(find "$BACKUP_DIR" -maxdepth 1 -type f -name 'es2-king-data-*.tar.gz' -print -quit)"
test -n "$ARCHIVE"
test -f "$ARCHIVE.sha256"
(cd "$BACKUP_DIR" && sha256sum -c "$(basename "$ARCHIVE").sha256")
tar -tzf "$ARCHIVE" | grep -Fq 'user/7/7probe.o'
tar -tzf "$ARCHIVE" | grep -Fq 'login/7/7probe.o'

# 預設策略必須拒絕同一檔案系統，避免誤把同磁碟資料當成異地備份。
if BACKUP_DIR="$TEMP_ROOT/same-device-backup" DATA_DIR="$DATA_DIR" \
  bash "$ROOT/deploy/oracle/backup.sh" >"$TEMP_ROOT/refusal.log" 2>&1; then
  echo 'ORACLE BACKUP TEST FAIL：同檔案系統備份未被預設拒絕。' >&2
  exit 1
fi
grep -Fq '同一檔案系統' "$TEMP_ROOT/refusal.log"
echo 'ORACLE_BACKUP_SMOKE_PASS：封存、校驗碼、數字帳號檔案與同磁碟保護均通過。'
