#!/usr/bin/env bash
# 隔離回歸：確認完整可玩性測試在未安裝 rg 時仍會攔截 Driver 錯誤。
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$ROOT/scripts/test_game_playability_completion_e2e.sh"
bash -n "$TARGET"
grep -Fq 'test -r "$TEMP_ROOT/driver.stdout"' "$TARGET"
grep -Fq "if grep -En '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable|Undefined function'" "$TARGET"
if grep -Eq 'if rg -n' "$TARGET"; then
  echo "FAIL：不可依賴可能未安裝的 rg 掃描遊戲錯誤。" >&2
  exit 1
fi
TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf -- "$TEMP_ROOT"' EXIT
printf '%s\n' 'master object created' 'player entered world' > "$TEMP_ROOT/driver.stdout"
if grep -En '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable|Undefined function' "$TEMP_ROOT/driver.stdout"; then
  echo "FAIL：乾淨 Driver log 被誤判。" >&2
  exit 1
fi
printf '%s\n' 'master object created' 'Runtime error: missing room' > "$TEMP_ROOT/driver.stdout"
if ! grep -En '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable|Undefined function' "$TEMP_ROOT/driver.stdout"; then
  echo "FAIL：有錯誤的 Driver log 未攔截。" >&2
  exit 1
fi
echo "PLAYABILITY_DRIVER_LOG_GUARD_STATIC_PASS (no Driver/Gameplay claim)"
