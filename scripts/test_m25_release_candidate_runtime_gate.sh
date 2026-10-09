#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.runtime/original-es2}/mudlib"

# Runtime Gate／依照上游實際檔名（.c／.lpc）檢查候選版必要介面。
# 此 PASS 只代表 RC interface readiness，不等於 Public Device E2E 驗收。
for file in obj/login.c obj/user.c adm/daemons/logind.c cmds/std/look.lpc cmds/usr/score.lpc cmds/usr/inventory.lpc cmds/usr/help.lpc cmds/usr/save.c cmds/usr/quit.lpc d/snow/inn_hall.c d/snow/inn_kitchen.c feature/save.c; do
  test -f "$ROOT/$file" || { echo "M25 RUNTIME FAIL：缺少 $file"; exit 1; }
done

# Login and persistence／登入與持久化。
grep -Fq 'USER_OB' "$ROOT/adm/daemons/logind.c"
grep -Fq 'void logon (object ob)' "$ROOT/adm/daemons/logind.c"
grep -Fq 'save_object (file)' "$ROOT/feature/save.c"
grep -Fq 'restore_object (file, 1)' "$ROOT/feature/save.c"
grep -Fq 'my_link->save()' "$ROOT/obj/user.c"

# Player commands／玩家旅程使用上游實際指令檔。
for command in "$ROOT/cmds/std/look.lpc" "$ROOT/cmds/usr/score.lpc" "$ROOT/cmds/usr/inventory.lpc" "$ROOT/cmds/usr/help.lpc" "$ROOT/cmds/usr/save.c" "$ROOT/cmds/usr/quit.lpc"; do
  grep -Eq 'int main ?\(object me, string arg\)' "$command"
done

# World traversal／客棧與廚房必須形成 west／east 雙向連線。
grep -Fq '"west" : __DIR__"inn_kitchen"' "$ROOT/d/snow/inn_hall.c"
grep -Fq '"east" : __DIR__"inn_hall"' "$ROOT/d/snow/inn_kitchen.c"

echo 'M25 RELEASE CANDIDATE INTERFACE PASS／登入、指令、移動、保存與重新載入的 RC 必要介面完整；不代表 Public Device E2E PASS。'
