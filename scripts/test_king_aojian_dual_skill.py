#!/usr/bin/env python3
"""KING 傲劍訣／冷梅劍法雙技能與 Original enable 切換靜態契約。"""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
daemon = (root / "es2_king_expansion/runtime/mudlib/adm/daemons/kingmartiald.c").read_text()
skill = (root / "es2_king_expansion/runtime/mudlib/daemon/skill/au-chan_sword.c").read_text()
assert 'actor->set_skill("au-chan sword", level);' in daemon
assert 'actor->set_skill("lunmay", level);' in daemon
assert 'actor->map_skill("sword", "lunmay");' in daemon, "KING 預設必須維持冷梅劍法"
assert 'actor->map_skill("sword", "au-chan sword");' not in daemon, "不可強制取代冷梅"
assert 'load_object("/daemon/skill/au-chan_sword");' in daemon
assert 'CHINESE_D->add_translate("au-chan sword", "傲劍訣");' in daemon
assert 'register_skill_daemon("au-chan sword")' in skill
assert 'usage=="sword"' in skill and 'usage=="twohanded sword"' in skill
print("KING_AOJIAN_DUAL_SKILL_STATIC_PASS: skills learned; default lunmay; enable switch eligible")
