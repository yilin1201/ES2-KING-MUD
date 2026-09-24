#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/es2-king}/mudlib"

# Quest Evidence Gate／任務證據閘門。
# 不發明 Original 任務內容；只驗證 upstream 實際存在的任務框架與可追溯入口。
for f in \
  cmds/usr/quest.c \
  feature/quest.c \
  adm/daemons/questd.c
do
  test -f "$ROOT/$f" || { echo "QUEST EVIDENCE BLOCKED：Original 缺少 $f"; exit 2; }
done

# 只接受程式中可查證的 quest interface；任務劇情/獎勵若無 Evidence 仍維持 UNKNOWN。
grep -Eqi "quest" "$ROOT/cmds/usr/quest.c"
grep -Eqi "quest" "$ROOT/feature/quest.c"
grep -Eqi "quest" "$ROOT/adm/daemons/questd.c"

echo "QUEST FRAMEWORK LOCAL PASS：Original quest command/feature/daemon Evidence 存在；未證實的歷史任務內容仍為 UNKNOWN。"
