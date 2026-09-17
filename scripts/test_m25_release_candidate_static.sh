#!/usr/bin/env bash
set -euo pipefail

DOC="original_es2/research/m25_release_candidate.md"
RESULT="original_es2/runtime/m25_release_candidate_result.md"
ROADMAP="ROADMAP_M0_M30.md"

for file in "$DOC" "$RESULT" "$ROADMAP"; do
  test -f "$file" || { echo "M25 STATIC FAIL：缺少 $file"; exit 1; }
done

for term in 'M25 — Original ES2 Release Candidate' 'M26 — KING 管理員／創世系統' 'M21～M25：Original ES2 完整化' 'M26～M30：ES2-KING Expansion'; do
  grep -Fq "$term" "$ROADMAP" || { echo "M25 STATIC FAIL：Roadmap 缺少 $term"; exit 1; }
done

for term in 'Driver Build' 'Driver Boot' 'Player Journey' Persistence UNKNOWN 'ACTIONS-INFRA-BLOCKED' 'ES2-KING Expansion'; do
  grep -Fq "$term" "$DOC" || { echo "M25 STATIC FAIL：候選規格缺少 $term"; exit 1; }
done

for term in 'WORK-LOCAL PASS' 'CMake configure PASS' 'Driver Boot' 'quit → mlocal 重新進入：PASS' 'M24 DATA INTEGRITY RUNTIME PASS' 'ACTIONS-INFRA-BLOCKED' UNKNOWN; do
  grep -Fq "$term" "$RESULT" || { echo "M25 STATIC FAIL：本機證據缺少 $term"; exit 1; }
done

echo 'M25 RELEASE CANDIDATE STATIC PASS／候選版證據、UNKNOWN 與階段邊界正常。'
