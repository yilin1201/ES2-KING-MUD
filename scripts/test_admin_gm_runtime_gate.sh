#!/usr/bin/env bash
set -euo pipefail

# ADMIN GM Runtime Gate／生成 Runtime 閘門：確認 Expansion 已複製到 Neolith 實際 mudlib。
ROOT="${1:-.runtime/es2-king}/mudlib"
COMMAND="$ROOT/cmds/adm/admin.c"
COMMAND_D="$ROOT/adm/daemons/cmd_d.lpc"
PRELOAD="$ROOT/adm/etc/preload"

for file in "$COMMAND" "$COMMAND_D" "$PRELOAD"; do
  test -f "$file" || { echo "ADMIN GM RUNTIME FAIL：缺少 $file" >&2; exit 1; }
done

grep -Fq 'ES2-KING Expansion／管理員 GM 指令整合層' "$COMMAND"
grep -Fq 'wiz_level(me) < wiz_level("(admin)")' "$COMMAND"
grep -Fq 'ES2-KING OWNER COMMAND REHASH' "$COMMAND_D"
grep -Fq '"admin", "kingcreate"' "$COMMAND_D"
grep -Fqx '/cmds/adm/admin' "$PRELOAD"

# 檢查權限不足時明確回覆，避免管理員指令無聲失敗。
grep -Fq 'ADMIN: 你沒有管理員權限。' "$COMMAND"

echo 'ADMIN GM RUNTIME GATE PASS／生成 Runtime 已包含 admin.c、命令索引與預載項目。'
