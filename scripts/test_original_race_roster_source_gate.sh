#!/usr/bin/env bash
# Original Race Roster Source Gate：鎖定 pinned Target 的可選種族清單與 Avatar 建角邊界。
# 若日後 Source Recovery 找回更多 Target-compatible race，必須先重新 audit，不得靜默擴充。
set -euo pipefail
ROOT="${1:-${ES2_RUNTIME_DIR:-/opt/es2-king/runtime}}"
LOGIN="$ROOT/mudlib/adm/daemons/logind.c"
HUMAN="$ROOT/mudlib/daemon/race/human.c"
AVATAR="$ROOT/mudlib/daemon/race/avatar.c"

for file in "$LOGIN" "$HUMAN" "$AVATAR"; do
  test -f "$file" || { echo "ORIGINAL_RACE_ROSTER_SOURCE_GATE_FAIL:missing:$file" >&2; exit 1; }
done

grep -Fq '"human",' "$LOGIN"
grep -Fq '"avatar",' "$LOGIN"
grep -Fq 'case "human":' "$LOGIN"
grep -Fq 'case "avatar":' "$LOGIN"
grep -Fq 'set ("karma", 5);' "$HUMAN"
grep -Fq 'set ("karma", 100);' "$AVATAR"
grep -Fq 'random(10000) == 9999' "$HUMAN"
grep -Fq 'ob->set_race ("avatar");' "$HUMAN"

# pinned Target race daemon 只能是 human/avatar；新增 daemon 必須重新 Source Audit。
mapfile -t race_files < <(find "$ROOT/mudlib/daemon/race" -maxdepth 1 -type f -name '*.c' -printf '%f\n' | sort)
expected=("avatar.c" "human.c")
test "${race_files[*]}" = "${expected[*]}" || {
  printf 'ORIGINAL_RACE_ROSTER_SOURCE_GATE_REAUDIT:%s\n' "${race_files[*]}" >&2
  exit 1
}

echo 'ORIGINAL_RACE_ROSTER_SOURCE_GATE_PASS'
echo 'ORIGINAL_RACE_ROSTER_CONFIRMED:human,avatar'
echo 'ORIGINAL_AVATAR_DIRECT_CREATION_CONFIRMED:karma=100'
echo 'ORIGINAL_HUMAN_AVATAR_RARE_PATH_CONFIRMED:1/10000'
