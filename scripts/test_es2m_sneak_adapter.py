"""ES2M 潛行更新的 KING Expansion 靜態契約測試；不代表 LPC 實機測試通過。"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "es2m_snapshot/mudlib/cmds/std/sneak.c"
ADAPTER = ROOT / "es2_king_expansion/runtime/mudlib/cmds/std/sneak.c"


def test_es2m_sneak_snapshot_is_preserved():
    """確認封存的 ES2M 原始碼保留智力經驗公式呼叫。"""
    source = SOURCE.read_text(encoding="utf-8")
    assert "COMBAT_D->int_formula_exp(me)" in source
    assert 'me->improve_skill("sneak", me->query_attr("int"));' in source


def test_king_sneak_adapter_avoids_missing_original_daemon_api():
    """確認 KING 使用本地相容公式，不修改 Original ES2 combat daemon。"""
    adapter = ADAPTER.read_text(encoding="utf-8")
    assert "private int es2_king_sneak_int_formula_exp(object me)" in adapter
    assert 'me->query_attr("int")' in adapter
    assert "COMBAT_D->int_formula_exp(me)" not in adapter
    assert "es2_king_sneak_int_formula_exp(me)" in adapter


def test_sneak_progression_uses_intelligence_in_preparation_phase():
    """確認小心翼翼階段以悟性值作為技能進步輸入。"""
    adapter = ADAPTER.read_text(encoding="utf-8")
    assert 'me->improve_skill("sneak", me->query_attr("int"));' in adapter
