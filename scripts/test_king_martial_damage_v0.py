#!/usr/bin/env python3
"""KING 武學傷害 V0：四套武學靜態回歸閘門；非實際戰鬥傷害驗證。"""
from pathlib import Path
import argparse
import re

ROOT = Path(__file__).resolve().parents[1]
SKILLS = {
    "冷梅劍法（含鏡境進階招式）": ("es2_king_expansion/runtime/mudlib/d/arena/skill/lunmay.c", 7),
    "傲梅暗劍訣（左手劍）": ("es2_king_expansion/runtime/mudlib/d/arena/skill/advance_lunmay.c", 1),
    "傲劍訣（七式及劍領風騷六段模板）": ("es2_king_expansion/runtime/mudlib/daemon/skill/au-chan_sword.c", 8),
    "如來神掌": ("es2_king_expansion/runtime/mudlib/d/arena/skill/rulai_shenzhang.c", 11),
}
PATTERN = re.compile(r'"attack":\s*(\d+),\s*"force":\s*(\d+),\s*"defense":\s*(\d+)')
for name, (path, expected) in SKILLS.items():
    source = (ROOT / path).read_text(encoding="utf-8")
    values = [tuple(map(int, x)) for x in PATTERN.findall(source)]
    assert len(values) == expected, f"{name}: expected {expected} V0 templates, got {len(values)}"
    for attack, force, defense in values:
        assert 10 <= attack <= 20, f"{name}: attack {attack} outside V0"
        assert 10 <= force <= 20, f"{name}: force {force} outside V0"
        assert 0 <= defense <= 20, f"{name}: defense {defense} outside V0"
    assert "COMBAT_D->fight(" in source, f"{name}: original combat entry missing"
    print(f"V0_STATIC_PASS {name}: {len(values)} templates")
# 驗證武學實際入口及劍領風騷六段迴圈，避免只有模板係數正確、戰鬥入口卻未使用。
martial = (ROOT / "es2_king_expansion/runtime/mudlib/adm/daemons/kingmartiald.c").read_text(encoding="utf-8")
for learned, loaded in (
    ('actor->set_skill("lunmay", level);', 'load_object("/d/arena/skill/lunmay");'),
    ('actor->set_skill("advance_lunmay", level);', 'load_object("/d/arena/skill/advance_lunmay");'),
    ('actor->set_skill("au-chan sword", level);', 'load_object("/daemon/skill/au-chan_sword");'),
    ('actor->set_skill("rulai shenzhang", level);', 'load_object("/d/arena/skill/rulai_shenzhang");'),
):
    assert learned in martial and loaded in martial, f"V0 martial routing missing: {learned}"

sword = (ROOT / SKILLS["傲劍訣（七式及劍領風騷六段模板）"][0]).read_text(encoding="utf-8")
assert 'i < sizeof(jianling_forms)' in sword and 'COMBAT_D->fight(me, opponent, "sword", action, weapon);' in sword
assert len(re.findall(r'"name":"[忠武義德狂情]"', sword)) == 6, "劍領風騷必須保留六段"
rulai = (ROOT / SKILLS["如來神掌"][0]).read_text(encoding="utf-8")
assert 'COMBAT_D->fight(me, opponent, "unarmed", action);' in rulai
assert 'me->set_temp("rulai/form_index", (index + 1) % sizeof(rulai_actions));' in rulai
print("KING_MARTIAL_V0_ROUTING_STATIC_PASS: four skills registered; six-stage sword and unarmed routes preserved")
# V4：防止模板數量相同、招式名稱或執行入口卻遭替換。
expected_forms = {
    "冷梅劍法（含鏡境進階招式）": ("梅二方劍", "梅四方劍", "梅八方劍", "愛霜恨雪", "寒霜三千里", "傲梅暗劍訣・傲雪藏鋒・逆折寒梅", "冷梅劍法"),
    "傲梅暗劍訣（左手劍）": ("傲梅暗劍訣",),
    "傲劍訣（七式及劍領風騷六段模板）": ("千嬌百媚柔似水", "佳人在殘醉臥君", "了絕紅塵遁山林", "清風送爽墨雲飛", "渺盡人世絕惡意", "天始一乾景初開", "不識江山多嬌媚"),
    "如來神掌": ("佛光初現", "金頂佛燈", "佛動山河", "佛問迦藍", "迎佛西天", "佛光普照", "天佛降世", "佛鎮八荒", "佛法無邊", "九九歸一・萬佛朝宗", "天舞梵輪・萬相歸墟"),
}
for name, forms in expected_forms.items():
    source = (ROOT / SKILLS[name][0]).read_text(encoding="utf-8")
    for form in forms:
        assert f'"name":"{form}"' in source, f"{name}: missing canonical form {form}"
assert 'sizeof(jianling_forms)' in sword and 'jianling_combat_attack(me, target, weapon);' in sword
assert 'actor->map_skill("sword", "lunmay");' in martial, "冷梅預設不可被傲劍訣取代"
assert 'actor->map_skill("secondhand sword", "advance_lunmay");' in martial
assert 'actor->map_skill("unarmed", "rulai shenzhang");' in martial
print("KING_MARTIAL_V4_CANON_STATIC_PASS: forms and default mapping retained")
# V4 Runtime overlay 檔案一致性：避免部署時套用舊版或遺漏 V0 的技能檔。
parser = argparse.ArgumentParser(description="檢查 KING V0 來源及選用的生成 Runtime overlay")
parser.add_argument("--runtime", type=Path, help="生成後的 mudlib 根目錄（僅檔案比對，非實戰）")
args = parser.parse_args()
if args.runtime:
    for name, (relative, _) in SKILLS.items():
        overlay_relative = relative.split("es2_king_expansion/runtime/mudlib/", 1)[1]
        expected = (ROOT / relative).read_bytes()
        deployed_path = args.runtime / overlay_relative
        assert deployed_path.is_file(), f"{name}: missing generated Runtime skill {deployed_path}"
        assert deployed_path.read_bytes() == expected, f"{name}: generated Runtime skill differs from V0 source"
    print("KING_MARTIAL_V4_OVERLAY_STATIC_PASS: four generated Runtime files match source bytes")
print("KING_MARTIAL_DAMAGE_V0_STATIC_PASS (not Runtime or gameplay validation)")
