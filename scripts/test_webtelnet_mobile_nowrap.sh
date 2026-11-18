#!/usr/bin/env bash
set -euo pipefail
HTML="${1:-webtelnet/public/index.html}"
test -f "$HTML"
grep -Fq 'white-space: pre;' "$HTML"
grep -Fq 'overflow-x: auto;' "$HTML"
grep -Fq 'overflow-wrap: normal;' "$HTML"
grep -Fq 'word-break: normal;' "$HTML"
grep -Fq 'const mobileNoWrapMinFontPx = 8' "$HTML"
grep -Fq 'const targetColumns = Math.max(terminalColumns, longestLineColumns);' "$HTML"
grep -Fq 'scheduleMobileFit();' "$HTML"
! grep -Fq 'white-space: pre-wrap' "$HTML"
echo "WEBTELNET_MOBILE_NOWRAP_PASS"
