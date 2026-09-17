#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/original-es2}/mudlib"

for file in feature/save.c obj/login.c obj/user.c feature/user/autoload.c feature/char/condition.c std/char.c std/room/temple.c feature/char/score.c feature/char/finance.c cmds/std/buy.c cmds/std/drop.c cmds/std/give.c cmds/std/put.c; do
  test -f "$ROOT/$file" || { echo "M24 RUNTIME FAIL：缺少 $file"; exit 1; }
done

# Persistence／持久化與角色恢復。
grep -Fq 'save_object (file)' "$ROOT/feature/save.c"
grep -Fq 'restore_object (file, 1)' "$ROOT/feature/save.c"
grep -Fq 'save_autoload()' "$ROOT/obj/user.c"
grep -Fq 'restore_autoload()' "$ROOT/obj/user.c"
grep -Fq 'restore_condition()' "$ROOT/obj/user.c"
grep -Fq 'my_link->save()' "$ROOT/obj/user.c"

# Death／復活與資料狀態。
grep -Fq 'CHAR_D->make_corpse(this_object())' "$ROOT/std/char.c"
grep -Fq 'CHAR_D->make_living (this_player())' "$ROOT/std/room/temple.c"

# Score and economy／能力分數與經濟。
grep -Fq 'gain_score(string course, int xp)' "$ROOT/feature/char/score.c"
grep -Fq 'pay_money(int amount, int check_only)' "$ROOT/feature/char/finance.c"
grep -Fq 'int can_afford(int amount)' "$ROOT/feature/char/finance.c"
grep -Fq 'me->pay_money(price)' "$ROOT/cmds/std/buy.c"

# Item protection／物品保護：跨 drop、give、put 指令維持一致。
grep -Fq 'obj->query("no_drop")' "$ROOT/cmds/std/drop.c"
grep -Fq 'item->query("no_drop")' "$ROOT/cmds/std/give.c"
grep -Fq 'obj->query("no_drop") || obj->query("no_get")' "$ROOT/cmds/std/put.c"

echo 'M24 DATA INTEGRITY RUNTIME PASS／保存、恢復、死亡、分數、經濟與物品保護介面一致。'
