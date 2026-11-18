#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
STANDARD="$ROOT/ES2_CN_STANDARD.md"

test -f "$STANDARD"

# ES2-CN（繁體中文工程溝通標準）必須保留 Owner 指定的三層解釋與狀態碼。
for text in \
  '繁體中文名稱' \
  'ES2-KING 白話用途' \
  'PASS' \
  'FAIL' \
  'ENVIRONMENT-LIMITATION' \
  'ACTIONS-INFRA-BLOCKED' \
  'PERSISTENCE-HOSTING-LIMITATION' \
  'OWNER DEVICE ACCEPTANCE REQUIRED' \
  'Original ES2 preserved source'; do
  grep -Fq "$text" "$STANDARD"
done

# Original ES2 保存來源不得因本規範而被加入或修改。
test ! -e "$ROOT/original_es2/runtime/ES2_CN_STANDARD.md"

echo 'ES2-CN STANDARD PASS（測試通過）：中文名稱、白話用途、狀態碼與 Original 邊界完整。'
