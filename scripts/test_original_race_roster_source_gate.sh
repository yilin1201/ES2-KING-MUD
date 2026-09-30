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

# Final Runtime 同時保留 pinned Original human/avatar 與已登錄的 ES2M supplemental races。
# 此處只允許已完成 provenance 登錄的 10 個 ES2M daemon，禁止未審核 race 靜默進入部署映像。
mapfile -t race_files < <(find "$ROOT/mudlib/daemon/race" -maxdepth 1 -type f -name '*.c' -printf '%f\n' | sort)
expected=("ashura.c" "avatar.c" "blackteeth.c" "dingling.c" "headless.c" "human.c" "jiaojao.c" "malik.c" "rainner.c" "woochan.c" "yaksa.c" "yenhold.c")
test "${race_files[*]}" = "${expected[*]}" || {
  printf 'ES2M_RACE_ROSTER_SOURCE_GATE_REAUDIT:%s\n' "${race_files[*]}" >&2
  exit 1
}

echo 'ORIGINAL_RACE_ROSTER_SOURCE_GATE_PASS'
echo 'ORIGINAL_RACE_ROSTER_CONFIRMED:human,avatar'
echo 'ES2M_RACE_ROSTER_SOURCE_GATE_PASS:blackteeth,yenhold,woochan,dingling,jiaojao,rainner,ashura,headless,yaksa,malik'
echo 'ORIGINAL_AVATAR_DIRECT_CREATION_CONFIRMED:karma=100'
echo 'ORIGINAL_HUMAN_AVATAR_RARE_PATH_CONFIRMED:1/10000'
