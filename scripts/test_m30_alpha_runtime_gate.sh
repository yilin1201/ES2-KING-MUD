#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/es2-king}/mudlib"

# Original core／Original 核心：M30 不得犧牲已完成可玩基線。
for f in adm/daemons/logind.c obj/login.c obj/user.c feature/char/skill.c feature/study.c feature/char/combat.c cmds/std/study.c cmds/usr/enable.c cmds/std/exert.c cmds/std/perform.c cmds/std/apprentice.c feature/save.c d/snow/inn_hall.c d/snow/square.c; do
  test -f "$ROOT/$f" || { echo "M30 RUNTIME FAIL：Original 核心缺少 $f"; exit 1; }
done
# KING 300 級例外不得破壞一般玩家的 Original 200 級上限。
grep -Fq 'private int es2_king_skill_cap()' "$ROOT/feature/char/skill.c"
grep -Fq 'return 200;' "$ROOT/feature/char/skill.c"
grep -Fq 'if( val > cap ) val = cap;' "$ROOT/feature/char/skill.c"
grep -Fq 'save_object (file)' "$ROOT/feature/save.c"
grep -Fq 'restore_object (file, 1)' "$ROOT/feature/save.c"
grep -Fq 'me->interrupt(me, "exhausted")' "$ROOT/d/snow/skill/dragon_force.c"
! grep -Fq 'me->interrupt_me(me, "exhausted")' "$ROOT/d/snow/skill/dragon_force.c"

# Expansion core／Expansion 核心：M26-M29 全部同一 overlay／覆蓋層。
for f in adm/daemons/kingd.c adm/daemons/kingmartiald.c adm/daemons/kingcanon_d.c cmds/adm/kingcreate.c cmds/adm/kingrealm.c cmds/adm/kingmartial.c cmds/adm/kingcanon.c d/king/wuji_realm.c obj/king/creation_mark.c; do
  test -f "$ROOT/$f" || { echo "M30 RUNTIME FAIL：Expansion 缺少 $f"; exit 1; }
done
grep -Fq 'level > 300' "$ROOT/adm/daemons/kingmartiald.c"
grep -Fq 'form < 1 || form > 11' "$ROOT/adm/daemons/kingcanon_d.c"
grep -Fq '"down" : "/d/snow/square"' "$ROOT/d/king/wuji_realm.c"
grep -Fq 'creation_registry[id]' "$ROOT/adm/daemons/kingd.c"
echo 'M30 ALPHA RUNTIME PASS／Original 核心與 M26-M29 Expansion overlay 相容。'
