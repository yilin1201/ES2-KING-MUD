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
# ES2M human/avatar daemon contract／最新 ES2M 使用無空格 LPC 呼叫格式，兩族 karma 均為 5。
grep -Eq 'set[[:space:]]*\("karma",[[:space:]]*5\);' "$HUMAN"
grep -Eq 'set[[:space:]]*\("karma",[[:space:]]*5\);' "$AVATAR"
# Latest ES2M race daemons register their own race; do not require the superseded 1/10000 human-to-avatar branch.
grep -Fq 'DAEMON_D->register_race_daemon("human");' "$HUMAN"
grep -Fq 'DAEMON_D->register_race_daemon("avatar");' "$AVATAR"

# Final Runtime 保留玩家可選 ES2M supplemental races，並保留 beast NPC-only daemon。
# beast.c 明確標註不可由玩家建立角色選擇；不加入登入選單。
mapfile -t race_files < <(find "$ROOT/mudlib/daemon/race" -maxdepth 1 -type f -name '*.c' -printf '%f\n' | sort)
expected=("ashura.c" "avatar.c" "beast.c" "blackteeth.c" "dingling.c" "headless.c" "human.c" "jiaojao.c" "malik.c" "rainner.c" "woochan.c" "yaksa.c" "yenhold.c")
test "${race_files[*]}" = "${expected[*]}" || {
  printf 'ES2M_RACE_ROSTER_SOURCE_GATE_REAUDIT:%s\n' "${race_files[*]}" >&2
  exit 1
}
# beast is NPC-only and must not appear in the player-selectable login roster.
! grep -Fq '"beast",' "$LOGIN"

echo 'ORIGINAL_RACE_ROSTER_SOURCE_GATE_PASS'
echo 'ORIGINAL_RACE_ROSTER_CONFIRMED:human,avatar'
echo 'ES2M_RACE_ROSTER_SOURCE_GATE_PASS:blackteeth,yenhold,woochan,dingling,jiaojao,rainner,ashura,headless,yaksa,malik; beast=NPC_ONLY'
echo 'ES2M_HUMAN_AVATAR_DAEMON_REGISTRATION_CONFIRMED:karma=5; independent-race-daemons'
