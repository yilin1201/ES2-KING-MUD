#!/usr/bin/env bash
set -euo pipefail

# Completion Audit／完成度稽核：避免把 interface/static gate 誤報為完整遊戲 PASS。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
FIXTURE="$REPO_ROOT/.runtime/game-completion-fixture/king"
REPORT="$REPO_ROOT/.runtime/game-completion-audit.txt"
mkdir -p "$(dirname "$REPORT")"

status=0
{
  echo "ES2-KING GAME COMPLETION AUDIT"
  echo "Runtime: $RUNTIME"
  if [[ -x "${ES2_DRIVER_BIN:-}" ]]; then echo "Driver: PRESENT"; else echo "Driver: MISSING"; status=2; fi
  if [[ -f "$FIXTURE/login/king.o" && -f "$FIXTURE/user/king.o" ]]; then echo "Real KING fixture: PRESENT"; else echo "Real KING fixture: MISSING"; status=2; fi
  echo "Quest: UNKNOWN/BLOCKED (insufficient Original runtime evidence)"
  echo "Public Compatibility: SEPARATE RELEASE GATE"
  if [[ $status -eq 0 ]]; then
    echo "Game Completion Runtime evidence: READY FOR JOURNEY"
  else
    echo "Game Completion Runtime evidence: BLOCKED"
  fi
} | tee "$REPORT"
exit "$status"
