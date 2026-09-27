#!/usr/bin/env bash
set -euo pipefail

# Fighter Reconstruction Static Gate／武者歷史重建靜態閘門：
# 只允許已通過 R4 Gate 的 join→fighter 適配，不准混入未知職業內容。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
ENTRY="$REPO_ROOT/es2_king_expansion/runtime/mudlib/d/reconstruction/fighter_guildhall.c"
ORIGINAL_FIGHTER="$RUNTIME/mudlib/daemon/class/fighter.c"
EVIDENCE="$REPO_ROOT/original_es2/research/targeted_class_source_recovery_rc1.md"

fail() { echo "FIGHTER RECONSTRUCTION STATIC FAIL：$*" >&2; exit 1; }

test -f "$ENTRY" || fail "缺少 Fighter Reconstruction Entry"
test -f "$ORIGINAL_FIGHTER" || fail "缺少 Target Original fighter.c"
test -f "$EVIDENCE" || fail "缺少 R4 Target Gate Evidence"

grep -Fq '[ES2-KING Reconstruction]' "$ENTRY" || fail "入口未標示 Reconstruction"
grep -Fq 'mudchina/es2 `std/room/class_guild.c`' "$ENTRY" || fail "入口缺少 Historical provenance"
grep -Fq 'add_action("do_join", "join")' "$ENTRY" || fail "缺少 Historical join command"
grep -Fq 'query_class() != "commoner"' "$ENTRY" || fail "未限制 Target commoner eligibility"
grep -Fq 'set_class("fighter")' "$ENTRY" || fail "未使用 Target-safe set_class()"
grep -Fq 'return "武者"' "$ORIGINAL_FIGHTER" || fail "Target Original fighter rank 不符"
grep -Fq 'Fighter Gate: `RECONSTRUCTION_READY`' "$EVIDENCE" || fail "R4 Gate 尚未允許 Fighter Reconstruction"
grep -Fq 'Taoist Gate: `SOURCE_REQUIRED`' "$EVIDENCE" || fail "Taoist 關閉邊界遺失"

# Unknown Guard／未知內容保護：入口不得偷偷加入成長、技能、裝備、戰鬥、師父或地圖物件。
for forbidden in \
  'initialize(' 'advance_level(' 'set_attr(' 'set_skill(' 'map_skill(' 'gain_score(' \
  'set_level(' 'valid_wield(' 'valid_wear(' 'kill_check(' 'apprentice' 'set("objects"' \
  'set("exits"' 'startroom' '/obj/board/'
do
  if grep -Fq "$forbidden" "$ENTRY"; then
    fail "入口含未經 Evidence 支持的內容：$forbidden"
  fi
done

echo 'ORIGINAL_FIGHTER_RECONSTRUCTION_STATIC_PASS'
