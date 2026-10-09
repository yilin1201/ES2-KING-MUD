#!/usr/bin/env python3
"""ES2-KING 傷害公式規格靜態閘門；不宣稱是真實 Runtime 傷害測試。"""
import argparse
from pathlib import Path

parser = argparse.ArgumentParser(description="ES2M 公式與生成 Runtime 傷害參數靜態檢查")
parser.add_argument("--runtime", type=Path, help="可選：已套用 Expansion 的生成 Runtime mudlib 目錄")
args = parser.parse_args()

ROOT = Path(__file__).resolve().parents[1]
ARCHIVE = ROOT / "source/es2m_updates/20261009_latest/source/upstream/mudlib"
COMBATD = (ARCHIVE / "adm/daemons/combatd.c").read_text(encoding="utf-8")
COMBAT = (ARCHIVE / "feature/char/combat.c").read_text(encoding="utf-8")
SPEC = (ROOT / "king_library/MARTIAL_DAMAGE_FORMULA_V1.md").read_text(encoding="utf-8")
V1 = (ROOT / "king_library/MARTIAL_DAMAGE_V1.md").read_text(encoding="utf-8")

# 確認封存 ES2M 來源仍包含公式所依據的實際運算，不以文件敘述取代程式證據。
for needle in (
    'me->query_strength("attack")',
    'me->query_skill("force") * me->query_stat("kee")',
    '(ratio + action["force"]) / 25',
    'me->query_ability("attack")',
    'action["attack"]',
    'victim->absorb(ability, strength',
    'action["damage_pct"]',
    'action["no_armor"]',
    'elemental_extra(me, victim, action["element"])',
):
    assert needle in COMBATD, f"ES2M combatd.c 缺少公式／參數證據：{needle}"

# 確認 ES2M 的力道轉換、damage_pct、護甲與實際扣血路徑有來源證據。
for needle in (
    'query_attr("str") * query_attr("cor") * 150',
    'query_stat("kee") * 30',
    'damage = 1 + strength/10000 + random(strength/10000)',
    'query_temp("martial_damage_pct")',
    'query_temp("martial_no_armor")',
    'victim->resist_damage(damage, this_object())',
    'victim->receive_damage(damage, this_object(), this_object())',
):
    assert needle in COMBAT, f"ES2M feature/char/combat.c 缺少傷害公式證據：{needle}"

# 防止日後把三種不同用途的係數誤解為可直接相加的傷害值。
for needle in ("action[\"attack\"]", "action[\"force\"]", "action[\"defense\"]",
               "damage_pct", "no_armor", "不是三個可以直接相加的傷害數值"):
    assert needle in SPEC, f"傷害公式規格未說明參數：{needle}"

# 保留 V1 既有係數範圍，不把文件建置誤作武學改版。
assert "20～40" in V1 and "不自動覆蓋已完成或凍結的武學" in V1
print("KING_MARTIAL_DAMAGE_FORMULA_STATIC_PASS: ES2M source formulas and parameter semantics verified")

# 可選檢查生成 Runtime；這是來源程式靜態閘門，不冒充實際傷害 E2E。
if args.runtime:
    runtime = args.runtime.resolve()
    runtime_checks = {
        "adm/daemons/combatd.c": (
            "ES2-KING MARTIAL DAMAGE PARAMS",
            'action["damage_pct"] > 0 ? action["damage_pct"] : 100',
            'me->delete_temp("martial_damage_pct")',
            'me->delete_temp("martial_no_armor")',
        ),
        "feature/char/combat.c": (
            "ES2-KING MARTIAL DAMAGE PCT",
            'query_temp("martial_damage_pct")',
            '!query_temp("martial_no_armor")',
        ),
        "feature/equip.c": (
            "ES2-KING MARTIAL DAMAGE PCT",
            'owner->query_temp("martial_damage_pct")',
            '!owner->query_temp("martial_no_armor")',
        ),
        "d/arena/skill/yijinjing.c": (
            "ES2-KING MARTIAL DAMAGE PCT",
            'attacker->query_temp("martial_damage_pct")',
            '!attacker->query_temp("martial_no_armor")',
        ),
    }
    for relative, needles in runtime_checks.items():
        path = runtime / relative
        assert path.is_file(), f"生成 Runtime 缺少檔案：{relative}"
        content = path.read_text(encoding="utf-8")
        for needle in needles:
            assert needle in content, f"生成 Runtime {relative} 缺少參數處理：{needle}"
    print("KING_MARTIAL_DAMAGE_RUNTIME_SOURCE_PASS: damage_pct/no_armor hooks present in generated Runtime")
else:
    print("KING_MARTIAL_DAMAGE_RUNTIME: NOT CHECKED (pass --runtime to verify generated Runtime)")
