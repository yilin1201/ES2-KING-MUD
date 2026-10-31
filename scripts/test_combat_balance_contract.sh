#!/usr/bin/env bash
# Combat Balance Contract／戰鬥平衡契約：先鎖量測標準，不改 Original 傷害。
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
POLICY="$ROOT/docs/design/COMBAT_BALANCE_STANDARD.md"
SCHEMA="$ROOT/tests/fixtures/combat_balance_standard.json"
test -s "$POLICY"
test -s "$SCHEMA"
grep -Fq 'Lv.50, Lv.100, Lv.150, Lv.200' "$POLICY"
grep -Fq 'KING/Owner Lv.300 is excluded' "$POLICY"
grep -Fq 'damage_p50' "$SCHEMA"
grep -Fq 'damage_p95' "$SCHEMA"
grep -Fq 'post_combat_recovery' "$SCHEMA"
grep -Fq 'measure-before-tune' "$SCHEMA"
echo 'COMBAT_BALANCE_CONTRACT_PASS:ordinary-player-50-100-150-200:king300-excluded:measure-before-tune'
