#!/usr/bin/env bash
set -euo pipefail

# Alpha Static Gate／Alpha 靜態閘門：防止驗收流程縮水成只有編譯或只有文件。
SPEC="original_es2/tests/m20_original_alpha_acceptance.md"
FLOW="scripts/test_m20_original_alpha.py"
test -f "$SPEC"
test -f "$FLOW"

for term in Driver Client Server human commoner 'level 1' look score inventory quit M21 M25 'ES2-KING Expansion'; do
  grep -Fq "$term" "$SPEC" || { echo "M20 STATIC FAIL：驗收規格缺少 $term"; exit 1; }
done

for term in Telnet '127.0.0.1' 4000 look score inventory west east quit 'M20 ALPHA PASS'; do
  grep -Fq "$term" "$FLOW" || { echo "M20 STATIC FAIL：實機流程缺少 $term"; exit 1; }
done

echo 'M20 ORIGINAL ALPHA STATIC PASS／最小可玩旅程與分層邊界完整。'
