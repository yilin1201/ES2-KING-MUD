#!/usr/bin/env bash
set -euo pipefail

# M15 Static／靜態回歸：驗證冷梅莊／梅影風只使用已確認 Original ES2 證據，並保留未知欄位。
python3 - <<'PY'
import json
from pathlib import Path

# Machine-readable baseline／機器可讀基線：讓後續 Runtime 重建可直接引用，不必重新猜測歷史設定。
p = Path("original_es2/data/m15_lengmei_mei_yingfeng.json")
data = json.loads(p.read_text(encoding="utf-8"))

assert data["evidence_layer"] == "Original ES2 Research"
assert data["character"]["name_zh_tw"] == "梅影風"
assert data["character"]["mud_display_name"] == "May yin fong"
assert data["character"]["class_route"] == "fighter.lunmay"

# Confirmed martial arts／已確認武學：只鎖定歷史資料已有名稱，不在測試中創造新技能。
arts = {item["name_zh_tw"] for item in data["confirmed_martial_arts"]}
required_arts = {"冷梅劍法", "傲梅暗劍訣", "梅影身法", "七巧如意手", "寒梅心法"}
assert required_arts <= arts

# Evidence boundary／證據邊界：NPC 路徑、HP、技能等級與屬性仍未知，禁止被假裝成 Original 定值。
unknown = set(data["unknown_original_fields"])
for key in {"npc_lpc_path", "hp", "skill_levels", "attributes", "complete_set_skill", "complete_map_skill"}:
    assert key in unknown

# Original / Expansion separation／原版與擴充分離：擴充設定只能保留在分離層。
assert "Expansion" in data["separation_rule_zh_tw"]
assert "不得寫回 Original ES2" in data["separation_rule_zh_tw"]

# Cross-check research note／交叉核對人物考證：避免機器基線與人工考證互相漂移。
research = Path("original_es2/characters/mei_yingfeng.md").read_text(encoding="utf-8")
for token in ["梅影風", "fighter.lunmay", "冷梅劍法", "傲梅暗劍訣", "梅影身法", "七巧如意手", "寒梅心法", "寒霜劍", "冰雪匕"]:
    assert token in research, f"人物考證缺少必要 Original 證據：{token}"

print("M15 PASS：冷梅莊／梅影風 Original ES2 證據基線與分層規則一致。")
PY
