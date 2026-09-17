#!/usr/bin/env bash
set -euo pipefail

DOC="original_es2/research/m23_core_gameplay_integration.md"
test -f "$DOC"
for term in CONFIRMED_RUNTIME UNKNOWN Class Apprentice Skill Enable Study Force Exert Perform Combat 'ES2-KING Expansion'; do
  grep -Fq "$term" "$DOC" || { echo "M23 STATIC FAIL：核心玩法文件缺少 $term"; exit 1; }
done
grep -Fq '觸發→進度→完成→獎勵' "$DOC"
grep -Fq '不為達成 M23 而補造' "$DOC"
echo 'M23 CORE GAMEPLAY STATIC PASS／核心循環與任務 UNKNOWN 邊界正常。'
