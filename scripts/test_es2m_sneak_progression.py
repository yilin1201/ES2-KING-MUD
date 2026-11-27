#!/usr/bin/env python3
"""ES2M sneak progression compatibility gate／潛行成長相容性閘門。"""
from __future__ import annotations

import argparse
from pathlib import Path


def check_source(snapshot: Path, overlay: Path) -> None:
    # ES2M source snapshot is evidence; KING overlay must preserve its intended progression.
    src = snapshot.read_text(encoding="utf-8")
    code = overlay.read_text(encoding="utf-8")
    required_source = [
        'me->improve_skill("sneak", me->query_attr("int"));',
        'COMBAT_D->int_formula_exp(me)',
    ]
    for marker in required_source:
        if marker not in src:
            raise SystemExit(f"ES2M_SNEAK_FAIL: source snapshot missing {marker}")

    # Runtime adapter must use the same ES2M formula without requiring an Original daemon API.
    required_overlay = [
        'me->improve_skill("sneak", me->query_attr("int"));',
        "private int es2_king_sneak_int_formula_exp(object me)",
        'i = (int)me->query_attr("int");',
        "if( i < 1 ) i = 1;",
        "return (random(i) + 1) * (random(i) + 1) + random(i);",
        'me->improve_skill("sneak", es2_king_sneak_int_formula_exp(me));',
    ]
    for marker in required_overlay:
        if marker not in code:
            raise SystemExit(f"ES2M_SNEAK_FAIL: KING overlay missing {marker}")
    if "COMBAT_D->int_formula_exp(me)" in code:
        raise SystemExit("ES2M_SNEAK_FAIL: KING overlay still calls missing Original combatd API")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime", type=Path, help="生成後的 KING Runtime mudlib")
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[1]
    snapshot = root / "es2m_snapshot/mudlib/cmds/std/sneak.c"
    overlay = root / "es2_king_expansion/runtime/mudlib/cmds/std/sneak.c"
    if not snapshot.is_file() or not overlay.is_file():
        raise SystemExit("ES2M_SNEAK_FAIL: missing source snapshot or KING overlay")
    check_source(snapshot, overlay)

    if args.runtime:
        runtime = args.runtime / "cmds/std/sneak.c"
        if not runtime.is_file():
            raise SystemExit(f"ES2M_SNEAK_FAIL: generated Runtime missing {runtime}")
        runtime_code = runtime.read_text(encoding="utf-8")
        for marker in [
            "es2_king_sneak_int_formula_exp",
            'me->improve_skill("sneak", me->query_attr("int"));',
        ]:
            if marker not in runtime_code:
                raise SystemExit(f"ES2M_SNEAK_FAIL: generated Runtime missing {marker}")
        if "COMBAT_D->int_formula_exp(me)" in runtime_code:
            raise SystemExit("ES2M_SNEAK_FAIL: generated Runtime calls missing Original combatd API")

    print("ES2M_SNEAK_PROGRESSION_PASS")


if __name__ == "__main__":
    main()
