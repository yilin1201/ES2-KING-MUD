#!/usr/bin/env bash
set -euo pipefail

# Roadmap Regression／路線圖回歸：鎖定兩階段邊界與每個 Milestone 的必要驗收結構。
ROADMAP="ROADMAP_M0_M30.md"
test -f "$ROADMAP"

for milestone in $(seq 21 30); do
  grep -Fq "M${milestone}" "$ROADMAP" || { echo "ROADMAP FAIL：缺少 M${milestone}"; exit 1; }
done

for term in '## M21～M25：Original ES2 完整化' '## M26～M30：ES2-KING Expansion' 'UNKNOWN' 'Runtime Gate' 'Regression Test' 'GitHub Actions' 'PR #13 保持 Open，**禁止 Merge'; do
  grep -Fq "$term" "$ROADMAP" || { echo "ROADMAP FAIL：缺少必要規則：$term"; exit 1; }
done

# 鎖定正式核心主題，避免後續把 Original 與 Expansion 工作跨階段搬移。
for title in 'M21 — 世界內容完整化' 'M22 — 角色／NPC／裝備／物品完整化' 'M23 — 核心玩法完整化' 'M24 — 系統整合與資料完整性' 'M25 — Original ES2 Release Candidate' 'M26 — KING 管理員／創世系統' 'M27 — 天神殿・無極之境' 'M28 — 易筋經＋霸天煉體訣' 'M29 — 渾天寶鑑＋如來神掌／十方佛兵' 'M30 — ES2-KING Alpha'; do
  grep -Fq "$title" "$ROADMAP" || { echo "ROADMAP FAIL：缺少正式主題：$title"; exit 1; }
done

echo 'ROADMAP M21-M30 PASS／階段邊界、驗收結構與開發順序已鎖定。'
