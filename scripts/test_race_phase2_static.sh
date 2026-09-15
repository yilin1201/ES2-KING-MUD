#!/usr/bin/env bash
set -euo pipefail
f=scripts/apply_race_phase2_runtime.sh
for r in headless yaksa ashura rainnar; do grep -q "$r" "$f"; done
grep -q 'write_race "$r" 50' "$f"
grep -q 'write_race "$r" 25' "$f"
grep -q '"cps":$value' "$f"
grep -q '"cor":$value' "$f"
echo 'M6-M9 STATIC PASS'
