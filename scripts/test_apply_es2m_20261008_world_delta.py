#!/usr/bin/env python3
"""Static contract for the ES2M 2026-10-08 safe world delta."""

from pathlib import Path
import ast

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/apply_es2m_20261008_world_delta.py"


def test_script_is_valid_python() -> None:
    ast.parse(SCRIPT.read_text(encoding="utf-8"))


def test_delta_scope_is_restricted() -> None:
    s = SCRIPT.read_text(encoding="utf-8")
    for token in ("snow_board.c", "square_w.c", "d/lee/inn.c"):
        assert token in s
    for forbidden in ("combatd.c", "feature/char/skill.c", "feature/equip.c",
                      "vendor.c", "websocket", "save"):
        assert forbidden not in s.lower()


if __name__ == "__main__":
    test_script_is_valid_python()
    test_delta_scope_is_restricted()
    print("PASS: ES2M 2026-10-08 world delta contract")
