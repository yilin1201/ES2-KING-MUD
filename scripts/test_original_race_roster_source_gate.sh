#!/usr/bin/env bash
set -euo pipefail

# Original Race Roster Source Gate：本閘門只驗證 pinned Original ES2 source，
# 不可拿已被 ES2M overlay 覆蓋的 Runtime race daemon 來驗證 Original karma 值。
RUNTIME_ROOT="${1:-/opt/es2-king/runtime}"
ORIGINAL_MUDLIB="${2:-${ES2_ORIGINAL_MUDLIB:-}}"
if [[ -z "$ORIGINAL_MUDLIB" || ! -d "$ORIGINAL_MUDLIB" ]]; then
  echo "ORIGINAL_RACE_ROSTER_SOURCE_GATE_BLOCKED: provide pinned Original mudlib path as argument 2 or ES2_ORIGINAL_MUDLIB" >&2
  exit 1
fi

ORIGINAL_LOGIN="$ORIGINAL_MUDLIB/adm/daemons/logind.c"
ORIGINAL_HUMAN="$ORIGINAL_MUDLIB/daemon/race/human.c"
ORIGINAL_AVATAR="$ORIGINAL_MUDLIB/daemon/race/avatar.c"
RUNTIME_RACE_DIR="$RUNTIME_ROOT/mudlib/daemon/race"

for file in "$ORIGINAL_LOGIN" "$ORIGINAL_HUMAN" "$ORIGINAL_AVATAR"; do
  test -f "$file" || { echo "ORIGINAL_RACE_ROSTER_SOURCE_GATE_FAIL:missing:$file" >&2; exit 1; }
done
test -d "$RUNTIME_RACE_DIR" || { echo "ES2M_RACE_ROSTER_RUNTIME_GATE_FAIL:missing:$RUNTIME_RACE_DIR" >&2; exit 1; }

# Pinned Original ES2 contract／固定原版來源契約。
grep -Fq '"human",' "$ORIGINAL_LOGIN"
grep -Fq '"avatar",' "$ORIGINAL_LOGIN"
grep -Fq 'case "human":' "$ORIGINAL_LOGIN"
grep -Fq 'case "avatar":' "$ORIGINAL_LOGIN"
grep -Fq 'set ("karma", 5);' "$ORIGINAL_HUMAN"
grep -Fq 'set ("karma", 100);' "$ORIGINAL_AVATAR"
grep -Fq 'random(10000) == 9999' "$ORIGINAL_HUMAN"
grep -Fq 'ob->set_race ("avatar");' "$ORIGINAL_HUMAN"

# ES2M generated Runtime roster／Runtime 種族清單：實際內容另由 race phase2 regression
# 對 12 個 Runtime daemon 與 ES2M snapshot 做逐檔 SHA/內容比對；本閘門不把 Original karma
# 規則套用到 ES2M daemon，避免兩個來源層級互相污染。
mapfile -t race_files < <(find "$RUNTIME_RACE_DIR" -maxdepth 1 -type f -name '*.c' -printf '%f\n' | sort)
expected=("ashura.c" "avatar.c" "blackteeth.c" "dingling.c" "headless.c" "human.c" "jiaojao.c" "malik.c" "rainner.c" "woochan.c" "yaksa.c" "yenhold.c")
test "${race_files[*]}" = "${expected[*]}" || {
  printf 'ES2M_RACE_ROSTER_SOURCE_GATE_REAUDIT:%s\n' "${race_files[*]}" >&2
  exit 1
}

echo 'ORIGINAL_RACE_ROSTER_SOURCE_GATE_PASS:pinned Original source only'
echo 'ES2M_RACE_ROSTER_RUNTIME_GATE_PASS:12 runtime race daemon files present'
echo 'ORIGINAL_AVATAR_DIRECT_CREATION_CONFIRMED:karma=100'
echo 'ORIGINAL_HUMAN_AVATAR_RARE_PATH_CONFIRMED:1/10000'
