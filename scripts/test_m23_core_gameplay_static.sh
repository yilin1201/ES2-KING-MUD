#!/usr/bin/env bash
set -euo pipefail

DOC="original_es2/research/closure/m23_core_gameplay_integration.md"
test -f "$DOC"
# Evidence State／證據狀態：第五階段 Recovery 已把 Quest 從 UNKNOWN 推進為
# CORROBORATED_RUNTIME_CANDIDATE，但版本世系尚未鎖定，仍不得宣告為目標正式站 Runtime。
for term in CONFIRMED_RUNTIME CORROBORATED_RUNTIME_CANDIDATE Class Apprentice Skill Enable Study Force Exert Perform Combat 'ES2-KING Expansion'; do
  grep -Fq "$term" "$DOC" || { echo "M23 STATIC FAIL：核心玩法文件缺少 $term"; exit 1; }
done
grep -Fq 'Random Task Quest' "$DOC"
grep -Fq '版本世系尚未鎖定為目標正式站' "$DOC"
grep -Fq '不為達成 M23 而搬入未鎖版本內容' "$DOC"
echo 'M23 CORE GAMEPLAY STATIC PASS／核心循環與任務候選證據邊界正常。'
