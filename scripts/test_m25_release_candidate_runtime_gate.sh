#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.runtime/original-es2}/mudlib"

# Runtime Gate／執行閘門：鎖定候選版實機旅程所需的最小完整介面。
for file in obj/login.c obj/user.c adm/daemons/logind.c cmds/std/look.c cmds/usr/score.c cmds/usr/inventory.c cmds/usr/help.c cmds/usr/save.c cmds/usr/quit.c d/snow/inn_hall.c d/snow/inn_kitchen.c feature/save.c; do
  test -f "$ROOT/$file" || { echo "M25 RUNTIME FAIL：缺少 $file"; exit 1; }
done

# Login and persistence／登入與持久化。
grep -Fq 'USER_OB' "$ROOT/adm/daemons/logind.c"
grep -Fq 'void logon (object ob)' "$ROOT/adm/daemons/logind.c"
grep -Fq 'save_object (file)' "$ROOT/feature/save.c"
grep -Fq 'restore_object (file, 1)' "$ROOT/feature/save.c"
grep -Fq 'my_link->save()' "$ROOT/obj/user.c"

# Player commands／玩家旅程使用的真實 Original 指令。
for command in "$ROOT/cmds/std/look.c" "$ROOT/cmds/usr/score.c" "$ROOT/cmds/usr/inventory.c" "$ROOT/cmds/usr/help.c" "$ROOT/cmds/usr/save.c" "$ROOT/cmds/usr/quit.c"; do
  grep -Eq 'int main ?\(object me, string arg\)' "$command"
done

# World traversal／世界移動：客棧與廚房必須形成 west／east 雙向連線。
grep -Fq '"west" : __DIR__"inn_kitchen"' "$ROOT/d/snow/inn_hall.c"
grep -Fq '"east" : __DIR__"inn_hall"' "$ROOT/d/snow/inn_kitchen.c"

echo 'M25 RELEASE CANDIDATE RUNTIME PASS／登入、指令、移動、保存與重新載入介面完整。'
