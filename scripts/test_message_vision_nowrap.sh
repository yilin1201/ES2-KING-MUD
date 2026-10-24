#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/es2-king}"
FILE="$ROOT/mudlib/adm/simul_efun/message.c"
test -f "$FILE"
grep -Fq 'ES2-KING MESSAGE VISION NO HARD WRAP' "$FILE"
grep -Fq 'message("vision", str2, you)' "$FILE"
grep -Fq 'message ("vision", str1, me)' "$FILE"
grep -Fq 'message ("vision", str3, environment(me)' "$FILE"
! grep -Fq 'cjk_wrap (str1, 70, -1)' "$FILE"
! grep -Fq 'cjk_wrap (str2, 70, -1)' "$FILE"
! grep -Fq 'cjk_wrap (str3, 70, -1)' "$FILE"
echo "MESSAGE_VISION_NOWRAP_PASS"
