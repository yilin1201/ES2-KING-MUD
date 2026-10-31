#!/usr/bin/env bash
set -euo pipefail

# Runtime Gate／實機證據閘門：只讀乾淨 Original ES2 上游，不修改保存原始碼。
ROOT="${1:-.runtime/original-es2}"
CHAR="$ROOT/mudlib/std/char.c"
TEMPLE="$ROOT/mudlib/std/room/temple.c"
USER="$ROOT/mudlib/obj/user.c"

for file in "$CHAR" "$TEMPLE" "$USER"; do
  [[ -f "$file" ]] || { echo "M19 FAIL：缺少 Original Runtime 檔案：$file"; exit 1; }
done

# Unconscious and revive／昏迷與甦醒：鎖定停用玩家與 60 秒後恢復的 Original 流程。
grep -Fq 'unconcious (string reason)' "$CHAR"
grep -Fq 'disable_player(stringp(reason) ? reason : " <昏迷不醒>")' "$CHAR"
grep -Fq 'call_out("revive", 60)' "$CHAR"
grep -Fq 'revive (int quiet)' "$CHAR"
grep -Fq 'enable_player()' "$CHAR"

# Death／死亡：鎖定戰鬥清理、屍體建立與鬼魂再次死亡分支。
grep -Fq 'remove_all_killer()' "$CHAR"
grep -Fq 'clear_condition()' "$CHAR"
grep -Fq 'COMBAT_D->announce(this_object(), "dead")' "$CHAR"
grep -Fq 'query("life_form") == "ghost"' "$CHAR"
grep -Fq 'CHAR_D->make_corpse(this_object())' "$CHAR"

# Temple resurrection／寺廟復活：只有鬼魂可以由紅色漩渦呼叫 make_living。
grep -Fq 'query("life_form") != "ghost"' "$TEMPLE"
grep -Fq 'CHAR_D->make_living (this_player())' "$TEMPLE"

# Age and login death check／年齡與登入死亡補查：鎖定在線日齡及四項狀態檢查。
grep -Fq 'query("time_aged") >= 86400' "$USER"
grep -Fq 'add("age", 1)' "$USER"
for stat in gin kee sen HP; do
  grep -Fq "damage_stat(\"$stat\", 0)" "$USER"
done

echo 'M19 LIFECYCLE RUNTIME GATE PASS／角色生命週期實機證據閘門通過。'
