#!/usr/bin/env bash
set -euo pipefail
ROOT="es2_king_expansion/runtime/mudlib"
KINGD="$ROOT/adm/daemons/kingd.c"
grep -Fq '#define KING_OWNER_ID "king"' "$KINGD"
grep -Fq 'actor->query("id") == KING_OWNER_ID' "$KINGD"
grep -Fq 'interactive(actor)' "$KINGD"
grep -Fq 'wiz_level(actor) >= wiz_level("(admin)")' "$KINGD"
for command in kingcreate kingrealm kingmartial kingcanon; do
  grep -Fq 'KING_D->authorized(me)' "$ROOT/cmds/adm/$command.c"
done
for daemon in kingmartiald kingcanon_d; do
  grep -Fq 'KING_D->authorized(actor)' "$ROOT/adm/daemons/$daemon.c"
done
grep -Fq "grep -Fqx 'king (admin)'" scripts/apply_es2_king_expansion.sh
grep -Fq 'ES2-KING PUBLIC OWNER ID RESERVATION' scripts/apply_es2_king_expansion.sh
grep -Fq 'if (arg == "king")' scripts/apply_es2_king_expansion.sh
grep -Fq '已拒絕公開註冊' scripts/apply_es2_king_expansion.sh
grep -Fq 'ob->delete("id")' scripts/apply_es2_king_expansion.sh
grep -Fq 'logon(ob)' scripts/apply_es2_king_expansion.sh
if sed -n "/if (arg == \"king\")/,/^[[:space:]]*}/p" scripts/apply_es2_king_expansion.sh | grep -Fq 'destruct(ob)'; then
  echo 'KING OWNER STATIC FAIL：保留分支仍銷毀登入物件，可能遺留不明確的 Telnet session。' >&2
  exit 1
fi
# 密碼不得成為 repository 設定；授權程式只能核對帳號 ID 與 Original 驗證後的權限。
if rg -n 'KING_OWNER_PASSWORD|owner_password|set_password' es2_king_expansion scripts M30_PLAYABLE_ALPHA_ENTRY.md --glob '!test_king_owner_authorization_static.sh'; then
  echo 'KING OWNER STATIC FAIL：repository 出現 Owner 密碼設定介面。' >&2; exit 1
fi
echo 'KING OWNER AUTHORIZATION STATIC PASS／帳號 ID、互動登入與 admin 三重邊界完整。'
