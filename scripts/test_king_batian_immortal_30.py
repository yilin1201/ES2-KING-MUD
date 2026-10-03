#!/usr/bin/env python3
"""霸天煉體訣不滅金身 30% 攻擊強度吸收靜態回歸；非實戰驗證。"""
from pathlib import Path
import sys
root=Path(__file__).resolve().parents[1]
source=(root/"es2_king_expansion/runtime/mudlib/d/arena/skill/batian_lianti_jue.c").read_bytes()
text=source.decode()
assert 'int query_immortal_absorb_percent() { return 30; }' in text
assert 'return strength * query_immortal_absorb_percent() / 100;' in text
assert 'if (!objectp(me) || strength <= 0) return 0;' in text
assert 'me->query_temp("es2_king/batian/immortal_intro")' in text
assert '「 【 霸 天 煉 體 訣 ・ 不 滅 金 身 】 」' in text
if len(sys.argv)>1:
    deployed=Path(sys.argv[1])/"d/arena/skill/batian_lianti_jue.c"
    assert deployed.read_bytes()==source,"BATIAN_RUNTIME_OVERLAY_MISMATCH"
for strength in (0,1,10,100,500,1000):
    expected=strength*30//100
    assert 0<=expected<=strength
print("BATIAN_IMMORTAL_30_STATIC_PASS; actual combat damage NOT verified")
