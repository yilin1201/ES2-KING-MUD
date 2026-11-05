#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/es2-king}/mudlib"

# Quest Evidence Gate／任務證據閘門。
# 全域 Quest 仍非 COMPLETE；但 pinned Snow 已有一條經 Runtime 閉合的 Story／Area progression。
# 此 Gate 只確認 Source dependency，不用 Static 取代 scripts/test_original_thief_progression_runtime_e2e.sh。
CHILD="$ROOT/d/snow/npc/child.c"
GAMMER="$ROOT/d/snow/npc/gammer.c"
WAITER="$ROOT/d/snow/npc/waiter.c"
GUARD="$ROOT/d/snow/npc/guard.c"

for file in "$CHILD" "$GAMMER" "$WAITER" "$GUARD"; do
  test -f "$file" || { echo "QUEST EVIDENCE BROKEN：缺少 $file" >&2; exit 1; }
done

grep -Fq 'obj/comb' "$CHILD"
grep -Fq 'set_class("thief")' "$GAMMER"
grep -Fq 'improve_skill("sneak", 20)' "$GAMMER"
grep -Fq 'improve_skill("stealing", 20)' "$GAMMER"
grep -Fq '/d/snowkeep/entrance' "$GUARD"

echo "QUEST EVIDENCE PARTIAL：Snow 盜賊入門鏈已閉合；try/fon 與 Snowkeep 缺檔仍維持 PARTIAL／BROKEN／UNKNOWN。"
