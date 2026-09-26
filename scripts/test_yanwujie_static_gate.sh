#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/es2-king}"
ROOM="$ROOT/mudlib/d/arena/yanwujie.c"
REALM="$ROOT/mudlib/d/king/wuji_realm.c"

test -f "$ROOM"
test -f "$REALM"
grep -Fq '"enter" : "/d/arena/yanwujie"' "$REALM"
grep -Fq '"up" : "/d/king/wuji_realm"' "$ROOM"
grep -Fq 'set("arena_zone", 1)' "$ROOM"
grep -Fq 'set("es2_king_expansion", 1)' "$ROOM"

# Safety Boundary／安全邊界：Original die() 已確認沒有 room alternative_die/no_die hook。
# 未完成 Runtime Death integration 前，禁止重新加入會造成假安全感的無效欄位或錯誤 HP API。
! grep -Fq 'alternative_die' "$ROOM"
! grep -Fq 'set("no_die"' "$ROOM"
! grep -Fq 'set("no_flee"' "$ROOM"
! grep -Eq 'max_kee|max_gin|max_sen|eff_kee|max_force|who->set\(' "$ROOM"

echo "YANWUJIE STATIC GATE PASS：天神殿雙向連結與 ES2 Statistic 安全邊界正確；死亡保護仍待 Runtime call-chain integration。"
