#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/es2-king}/mudlib"

# Quest Evidence Gate／任務證據閘門。
# Pinned Original ES2 tree 目前只找到 legacy wizard quest 文件，沒有可驗證的 runtime quest command/daemon。
# 因此明確標示 UNKNOWN，而不是自行建立一套「Original 任務系統」。
LEGACY="$ROOT/../docs/legacy/wiz/quest"
if [[ -f "$LEGACY" ]]; then
  echo "QUEST EVIDENCE UNKNOWN：找到 legacy wizard quest 文件，但沒有足夠 Runtime Evidence 證明完整玩家任務鏈。"
  exit 2
fi

echo "QUEST EVIDENCE UNKNOWN：Pinned Original tree 未提供足夠可驗證的玩家 Quest Runtime Evidence。"
exit 2
