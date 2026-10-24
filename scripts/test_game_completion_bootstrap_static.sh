#!/usr/bin/env bash
set -euo pipefail

SCRIPT="scripts/bootstrap_game_completion_character.sh"
test -f "$SCRIPT"
grep -Fq '.runtime/game-completion-data' "$SCRIPT"
grep -Fq '.runtime/game-completion-fixture/king' "$SCRIPT"
grep -Fq '不得猜測 Original ES2 save_object 格式' "$SCRIPT"
grep -Fq 'ES2_KING_CLAIM_TOKEN' "$SCRIPT"
grep -Fq 'es2claim1:' "$SCRIPT"

# Safety Gate／安全閘門：不得讓測試 Bootstrap 指向正式 Public save 路徑。
if grep -Fq '/var/lib/es2-king/data' "$SCRIPT"; then
  echo 'GAME COMPLETION BOOTSTRAP STATIC FAIL：不得操作正式 Public save path。' >&2
  exit 1
fi

echo 'GAME COMPLETION BOOTSTRAP STATIC PASS／Developer Bootstrap 與正式 Public/Original 創角路徑隔離。'
