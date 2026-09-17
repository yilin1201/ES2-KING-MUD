#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.runtime/es2-king}/mudlib"
KINGD="$ROOT/adm/daemons/kingd.c"
COMMAND="$ROOT/cmds/adm/kingcreate.c"
MARK="$ROOT/obj/king/creation_mark.c"

for file in "$KINGD" "$COMMAND" "$MARK"; do
  test -f "$file" || { echo "M26 RUNTIME FAIL：缺少 $file"; exit 1; }
done

# Security Regression／安全回歸：必須雙重檢查最高管理權限並拒絕任意路徑。
grep -Fq 'SECURED_ADMIN_COMMAND' "$COMMAND"
grep -Fq 'interactive(actor)' "$KINGD"
grep -Fq 'wiz_level(actor) >= wiz_level("(admin)")' "$KINGD"
grep -Fq 'file = creation_registry[id]' "$KINGD"
if grep -Eq 'new\((arg|id)\)' "$COMMAND" "$KINGD"; then
  echo 'M26 RUNTIME FAIL：玩家輸入可直接建立任意物件。' >&2
  exit 1
fi

grep -Fq '"creation_mark" : "/obj/king/creation_mark"' "$KINGD"
grep -Fq 'set("es2_king_expansion", 1)' "$MARK"

echo 'M26 KING ADMIN RUNTIME PASS／受控創造服務與安全邊界可載入獨立 Runtime。'
